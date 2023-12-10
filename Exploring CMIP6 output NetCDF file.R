#install.packages("weathermetrics")
#install.packages("raster")
#install.packages("ggplot2")

library(ncdf4)
library(raster)
library(lattice)
library(RColorBrewer)
library(ncdf4.helpers)
library(PCICt)
library(readr)
library(dplyr)
library(tidyr)
library(ggplot2)
library(ggmap)
library(viridis)
library(weathermetrics)

#IMPORTANDO EL ARCHIVO NetCDF  ======================================
#Puede descargar un archivo de ejemplo usando el siguiente enlace: https://drive.google.com/file/d/1nih40HLDDpbHPQO0KRHe6Tl01GlaL3vx/view?usp=sharing
# Definimos la ruta
file_path <- "G:\\WEBINAR CMIP6 R PYTHON\\pr_day_MPI-ESM1-2-HR_ssp585_r1i1p1f1_gn_20150101-20191231.nc"
var<-"pr"
# Abrimos el archivo NetCDF
nc_data <- nc_open(file_path)

#EXPLORANDO EL ARCHIVO NetCDF  ======================================

print(nc_data)

# Obteniendo coordenadas
lon <- ncvar_get(nc_data,"lon")
nlon <- dim(lon)
head(nlon)

lat <- ncvar_get(nc_data,"lat")
nlat <- dim(lat)
head(nlat)

print(c(nlon,nlat))

nc_data$dim$time$units


#La salida del modelo climático puede vincularse a varios calendarios diferentes, 
#incluido un calendario "no bisiesto", que omite los días bisiestos del calendario,
#un calendario de 360 días, que utiliza meses de 30 días para los 12 meses, y varios 
#otros calendarios.

nc_data$dim$time$calendar

#Obteniendo el paso temporal
time <- ncvar_get(nc_data,"time")
time

pr_time <- nc.get.time.series(nc_data, v = "pr",
                               time.dim.name = "time")
pr_time[c(1:3, length(pr_time) - 2:0)]

tunit <- ncatt_get(nc_data,"time","units")
nt <- dim(time)
nt
tunit

#Puede utilizar la indexación para obtener la precipitación diaria modelada
#en una ubicación y un paso temporal determinados. 
pr <- ncvar_get(nc_data, var)
lon_index <- which.min(abs(lon - 116.4))
lat_index <- which.min(abs(lat - 39.9))
time_index <- which(format(pr_time, "%Y-%m-%d") == "2016-07-15")
pr[lon_index, lat_index, time_index]

#GRÁFICOS ===============================================

#GRÁFICO N°1: Serie de tiempo

#Si sólo desea leer una determinada sección de los datos del netCDF, 
#puede hacerlo utilizando la función nc.get.var.subset.by.axes del 
#paquete ncdf4.helpers. Por ejemplo, para obtener y trazar la serie 
#temporal completa de la temperatura modelada en el punto de la cuadrícula más 
#cercano a un punto, podemos ejecutar:

pr <- nc.get.var.subset.by.axes(nc_data, "pr",
                                 axis.indices = list(X = lon_index,
                                                     Y = lat_index))
data_frame(time = pr_time, 
           pr = as.vector(pr)) %>%
  mutate(time = as.Date(format(time, "%Y-%m-%d"))) %>%
  ggplot(aes(x = time, y = pr)) + 
  geom_line() + xlab("Date") + ylab("Precipitación diaria (mm)") + 
  ggtitle("Precipitación diaria modelada, 2015-2019",
          subtitle = "En un punto en coordenadas geográficas") + 
  theme_classic()

#GRÁFICO N°2: Incluyendo marcas temnporales

time_index <- which(format(pr_time, "%Y-%m-%d") == "2016-07-15")
pr <- nc.get.var.subset.by.axes(nc_data, "pr",
                                 axis.indices = list(T = time_index))
expand.grid(lon, lat) %>%
  rename(lon = Var1, lat = Var2) %>%
  mutate(lon = ifelse(lon > 180, -(360 - lon), lon),
         pr = as.vector(pr)) %>% 
  ggplot() + 
  geom_point(aes(x = lon, y = lat, color = pr),
             size = 0.8) + 
  borders("world", colour="black", fill=NA) + 
  scale_color_viridis(name = "Precipitación diaria (mm)") + 
  theme_void() + 
  coord_quickmap() + 
  ggtitle("Precipitación diaria modelada (mm) - período: 2015-2019",
          subtitle = " modelo MPI-ESM1-2-HR, trayectoria SSP585, r1i1p1 ensemble member") 

#GRÁFICO N°3: Obteniendo una única porción (rebanada temporal) de datos
m<-2
pr <- ncvar_get(nc_data, var)
pr<-pr*86400
pr_array <- pr[,,m]
image(lon,lat,pr_array,col=rev(brewer.pal(10,"RdBu")))


#GRÁFICO N°4: Usando "levelplot" del package "lattice"
grid <- expand.grid(lon=lon, lat=lat)
cutpts <- c(0,5,10,15,20,30,40,50,60)
levelplot(pr_array ~ lon * lat, data=grid, at=cutpts, cuts=11, pretty=T, 
          col.regions=(rev(brewer.pal(10,"RdBu"))))

#GUARDANDO ARCHIVO CSV ===============================================

# Generamos un vector con valores de "pr"
lonlat <- as.matrix(expand.grid(lon,lat))
pr_vec <- as.vector(pr_array)
length(pr_vec)

# Creamos un dataframe y añadimos encabezados
pr_df01 <- data.frame(cbind(lonlat,pr_vec))
names(pr_df01) <- c("lon","lat",paste(var, sep="_"))
head(na.omit(pr_df01), 10)

# Indicamos la ruta y nombre del archivo
csvpath <- "G:\\WEBINAR CMIP6 R PYTHON\\"
csvname <- "pr_1.csv"
csvfile <- paste(csvpath, csvname, sep="")
write.table(na.omit(pr_df01),csvfile, row.names=FALSE, sep=",")
