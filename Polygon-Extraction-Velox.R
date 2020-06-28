##########################################################################
#EXTRACCIÓN DE DATOS DE ARCHIVOS NETCDF A PARTIR DE UN ARCHIVO SHAPE     #
#VERSION TRADICIONAL                                                     #
########################################################################## 

# Configurar primero el directorio de trabajo:
#setwd("C:/TEMPORAL/RSMINERVEWORKMAY2020/NetCDF files")    

#Cargamos ó instalamos librerías principales

library(dplyr)
library(ncdf4)
library(raster)
library(rgdal)
library(devtools)

## VERSION TRADICIONAL
# Funciones de estadisticas zonales
##-------------------------------------------------------------------------
myZonal <- function (x, z, stat, digits = 0, na.rm = TRUE, ...) {
  library(data.table)
  fun <- match.fun(stat) 
  vals <- getValues(x) 
  zones <- round(getValues(z), digits = digits) 
  rDT <- data.table(vals, z=zones) 
  setkey(rDT, z) 
  rDT[, lapply(.SD, fun, na.rm = TRUE), by=z] 
} 

ZonalPipe<- function (zone.in, raster.in, shp.out=NULL, stat){
  require(raster)
  require(rgdal)
  require(plyr)
  
  r <- stack(raster.in)
  shp <- readOGR(zone.in)
  shp <- spTransform(shp, crs(r))
  
  shp@data$ID<-c(1:length(shp@data[,1]))
  
  r <- crop(r, extent(shp))	
  zone <- rasterize(shp, r, field="ID", dataType = "INT1U") # Cambiar dataType si nrow(shp) > 255 a INT2U o INT4U
  
  Zstat<-data.frame(myZonal(r, zone, stat))
  colnames(Zstat)<-c("ID", paste0(names(r), "_", c(1:(length(Zstat)-1)), "_",stat))
  
  shp@data <- plyr::join(shp@data, Zstat, by="ID")
  
  if (is.null(shp.out)){
    return(shp)
  }else{
    writeOGR(shp, shp.out, layer= sub("^([^.]*).*", "\\1", basename(zone.in)), driver="ESRI Shapefile")
  }
}
##-------------------------------------------------------------------------

ppbrick = brick("C:/TEMPORAL/RSMINERVEWORKMAY2020/NetCDF files/PISCOpd.nc")
shp     = shapefile("C:/TEMPORAL/RSMINERVEWORKMAY2020/SHAPE CUENCAS/Chicama_UTM_Cuenca.shp")
shpRp   = spTransform(shp, proj4string(ppbrick))

ppcrop  = crop(ppbrick, shpRp) # Cortando el area de estudio
ppmask  = mask(ppcrop, shpRp)
writeRaster(ppmask, "C:/TEMPORAL/RSMINERVEWORKMAY2020/NetCDF files/ppMask.tif")


# Hallar las estadísticas zonales
zone.in   = "C:/TEMPORAL/RSMINERVEWORKMAY2020/SHAPE CUENCAS/Mantaro_UTM_Cuencas.shp"
raster.in = "C:/TEMPORAL/RSMINERVEWORKMAY2020/NetCDF files/ppMask.tif"
shp.out   = "C:/TEMPORAL/RSMINERVEWORKMAY2020/NetCDF files/ppZonal.shp"

shp = ZonalPipe(zone.in, raster.in, stat="mean")
tbpp = write.csv(shp,"C:/TEMPORAL/RSMINERVEWORKMAY2020/NetCDF files/tablaPP.csv", header = T, sep = ",")

# Media para cada subcuenca
# len = nlayers(ppmask)
# 
# lista = c()
# for(i in c(1:len)){
#   a = mean(getValues(ppmask[[i]]), na.rm=T)
#   lista = c(lista,a)
# }
# 
# serie = seq(as.Date(""), as.Date(""),by = "monthly") #
# df  = data.frame(serie,lista)

-----------------------------------------------------------------------------------------------------

##########################################################################
#EXTRACCIÓN DE DATOS DE ARCHIVOS NETCDF A PARTIR DE UN ARCHIVO SHAPE     #
#VERSION USANDO LIBRERÍA VELOX                                           #
##########################################################################


library(velox)

#RECOMENDADA: INSTALAR RTOOL40S Y POSTERIORMENTE LA LIBRERÍA VELOX
#Descargar e instalar Rtools40: https://cran.r-project.org/bin/windows/Rtools/index.html
#writeLines('PATH="${RTOOLS40_HOME}\\usr\\bin;${PATH}"', con = "~/.Renviron")
#Sys.which("make")
## "C:\\rtools40\\usr\\bin\\make.exe"
#Ejemplo de instalación de librerría para verificar si Rtools40 está funcionando correctamente.
#install.packages("jsonlite", type = "source")

#OTRAS FORMAS:
#install.packages("Rtools")
#install.packages("remotes")
#remotes::install_github("hunzikp/velox")
#install.packages("devtools")
#install_github("hunzikp/velox")
#packageurl <- "https://cran.r-project.org/src/contrib/Archive/velox/velox_0.1.0.tar.gz"
#install.packages(packageurl, repos=NULL, type="source")


ppbrick = brick("C:/TEMPORAL/RSMINERVEWORKMAY2020/NetCDF files/PISCOpd.nc")

shp     = shapefile("C:/TEMPORAL/RSMINERVEWORKMAY2020/SHAPE CUENCAS/Subcuencas_Piura.shp")
shpmask   = spTransform(shp, proj4string(ppbrick))

e <- extent(shpmask@bbox)  #Regular el tamaño acorde al factor aplicado aquí (ejem. 1.084)
e <- as(e,"SpatialPolygons")
plot(shp)
plot(e, add= T)

#CORTANDO ARCHIVO NETCDF PARA CREAR UN RÁSTER MULTIBANDA
ppcrop  = crop(ppbrick,e) # area de estudio ligeramente ampliada
ppmask  = mask(ppcrop, e) # obrenemos un archivo ráster multibanda de la zona rectangular ampliada de la cuenca
writeRaster(ppmask, "C:/TEMPORAL/RSMINERVEWORKMAY2020/NetCDF files/ppMask.tif", overwrite=TRUE)  # Guardamos ráster multibanda
plot(ppmask)
plot(shpmask)

vx = velox("C:/TEMPORAL/RSMINERVEWORKMAY2020/NetCDF files/ppMask.tif") # El ráster multibanda se transforma a objeto velox
vxe = vx$extract(shpmask, fun=function(x){mean(x, na.rm=T)}) # Extraer información del elemento velox acorde al archivo shape de subcuencas

write.csv(t(vxe), "C:/TEMPORAL/RSMINERVEWORKMAY2020/NetCDF files/vxe.csv") # Guardamos archivo .csv con datos diarios acorde al área de cada subcuenca (en columnas)
#Cada elemento dentro del archivo shape (polígono de subcuenca) tiene un ID en la tabla de atributos por defecto
#Velox usa dicho índice ID para colocar en columnas los valores diarios por cada subcuenca.




