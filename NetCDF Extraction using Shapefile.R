#EXTRACCIÓN DE INFORMACIÓN A PARTIR DE ARCHIVOS NETCDF USANDO SHAPEFILES======================
#CASO: MODELOS DE CIRCULACIÓN GENERAL (GCM'S) DE LA FASE CMIP5-IPCC===========================

#1. Configuramos el directorio de trabajo
setwd("C:/Users/Julio/Desktop/DATOS CMIP5/IPSL-CM5A-MR")

#2. Apertura de librerías a usar
library(raster)
library(ggplot2)
library(ncdf4)
library(maptools)
library(sf)
library(rgdal)

#3. Damos lectura al archivo shapefile (puntos de estaciones)
pt = shapefile("C:/Users/Julio/Desktop/DATOS CMIP5/Estaciones_CORDEX_Catchira_GEO.shp")
pt@coords <- pt@coords[, 1:2]
data <- st_read("C:/Users/Julio/Desktop/DATOS CMIP5/Estaciones_CORDEX_Catchira_GEO.shp")
head(data)

#NOTA: Tener en cuenta que el archivo shapefile debe estar en COORDENADAS GEOGRÁFICAS (WGS84 GEO, ambas con signo negativo) 
#y a la coordenada de longitud original se le debe de sumar 360 grados

#4. Definimos series de tiempo a escala diaria para acoplarlas a los dataframes
#ts1 = seq(as.Date("1951-01-01"),as.Date("1955-12-30"),by = "day")
ts2 = seq(as.Date("1956-01-01"),as.Date("1960-12-31"),by = "day")
#ts3 = seq(as.Date("1961-01-01"),as.Date("1965-12-31"),by = "day")
#ts4 = seq(as.Date("1966-01-01"),as.Date("1970-12-31"),by = "day")
#ts5 = seq(as.Date("1971-01-01"),as.Date("1975-12-31"),by = "day")
#.....
#....
#Seguir colocando ts's si se necesitase.

#5. Definimos bricks para archivos NetCDF para el período histórico y RCP's

#Datos históricos del modelo GCM
nc1 = brick("C:/Users/Julio/Desktop/DATOS CMIP5/IPSL-CM5A-MR/pr_SAM-44_IPSL-IPSL-CM5A-MR_historical_r1i1p1_SMHI-RCA4_v3_day_19510101-19551231.nc",na.rm = TRUE)
nc2 = brick("C:/Users/Julio/Desktop/DATOS CMIP5/IPSL-CM5A-MR/pr_SAM-44_IPSL-IPSL-CM5A-MR_historical_r1i1p1_SMHI-RCA4_v3_day_19560101-19601231.nc",na.rm = TRUE)
nc3 = brick("C:/Users/monte/Desktop/DATOS CMIP5/IPSL-CM5A-MR/pr_SAM-44_IPSL-IPSL-CM5A-MR_historical_r1i1p1_SMHI-RCA4_v3_day_19610101-19651231.nc",na.rm = TRUE)
nc4 = brick("C:/Users/monte/Desktop/DATOS CMIP5/IPSL-CM5A-MR/pr_SAM-44_IPSL-IPSL-CM5A-MR_historical_r1i1p1_SMHI-RCA4_v3_day_19660101-19701231.nc",na.rm = TRUE)
nc5 = brick("C:/Users/monte/Desktop/DATOS CMIP5/IPSL-CM5A-MR/pr_SAM-44_IPSL-IPSL-CM5A-MR_historical_r1i1p1_SMHI-RCA4_v3_day_19710101-19751231.nc",na.rm = TRUE)
#.....
#....
#Seguir colocando nc's si se necesitase.

#Datos proyectactos RCP2.6
nc12 = brick("C:/Users/monte/Desktop/DATOS CMIP5/IPSL-CM5A-MR/pr_SAM-44_IPSL-IPSL-CM5A-MR_rcp45_r1i1p1_SMHI-RCA4_v3_day_20060101-20101231.nc",na.rm = TRUE)
nc13 = brick("C:/Users/monte/Desktop/DATOS CMIP5/IPSL-CM5A-MR/pr_SAM-44_IPSL-IPSL-CM5A-MR_rcp45_r1i1p1_SMHI-RCA4_v3_day_20110101-20151231.nc",na.rm = TRUE)
nc14 = brick("C:/Users/monte/Desktop/DATOS CMIP5/IPSL-CM5A-MR/pr_SAM-44_IPSL-IPSL-CM5A-MR_rcp45_r1i1p1_SMHI-RCA4_v3_day_20160101-20201231.nc",na.rm = TRUE)
nc15 = brick("C:/Users/monte/Desktop/DATOS CMIP5/IPSL-CM5A-MR/pr_SAM-44_IPSL-IPSL-CM5A-MR_rcp45_r1i1p1_SMHI-RCA4_v3_day_20210101-20251231.nc",na.rm = TRUE)
#.....
#....
#Seguir colocando nc's si se necesitase.

#Datos proyectados RCP4.5
nc31 = brick("C:/Users/monte/Desktop/DATOS/DATOS CMIP5/IPSL-CM5A-MR/pr_SAM-44_IPSL-IPSL-CM5A-MR_rcp45_r1i1p1_SMHI-RCA4_v3_day_20060101-20101231.nc",na.rm = TRUE)
nc32 = brick("C:/Users/monte/Desktop/DATOS/DATOS CMIP5/IPSL-CM5A-MR/pr_SAM-44_IPSL-IPSL-CM5A-MR_rcp45_r1i1p1_SMHI-RCA4_v3_day_20110101-20151231.nc",na.rm = TRUE)
nc33 = brick("C:/Users/monte/Desktop/DATOS/DATOS CMIP5/IPSL-CM5A-MR/pr_SAM-44_IPSL-IPSL-CM5A-MR_rcp45_r1i1p1_SMHI-RCA4_v3_day_20160101-20201231.nc",na.rm = TRUE)
nc34 = brick("C:/Users/monte/Desktop/DATOS/DATOS CMIP5/IPSL-CM5A-MR/pr_SAM-44_IPSL-IPSL-CM5A-MR_rcp45_r1i1p1_SMHI-RCA4_v3_day_20210101-20251231.nc",na.rm = TRUE)
nc35 = brick("C:/Users/monte/Desktop/DATOS/DATOS CMIP5/IPSL-CM5A-MR/pr_SAM-44_IPSL-IPSL-CM5A-MR_rcp45_r1i1p1_SMHI-RCA4_v3_day_20260101-20301231.nc",na.rm = TRUE)
#.....
#....
#Seguir colocando nc's si se necesitase.

#Datos proyectados RCP8.5
nc50 = brick("C:/Users/monte/Desktop/DATOS CMIP5/IPSL-CM5A-MR/pr_SAM-44_IPSL-IPSL-CM5A-MR_rcp85_r1i1p1_SMHI-RCA4_v3_day_20060101-20101231.nc",na.rm = TRUE)
nc51 = brick("C:/Users/monte/Desktop/DATOS CMIP5/IPSL-CM5A-MR/pr_SAM-44_IPSL-IPSL-CM5A-MR_rcp85_r1i1p1_SMHI-RCA4_v3_day_20110101-20151231.nc",na.rm = TRUE)
nc52 = brick("C:/Users/monte/Desktop/DATOS CMIP5/IPSL-CM5A-MR/pr_SAM-44_IPSL-IPSL-CM5A-MR_rcp85_r1i1p1_SMHI-RCA4_v3_day_20160101-20201231.nc",na.rm = TRUE)
nc53 = brick("C:/Users/monte/Desktop/DATOS CMIP5/IPSL-CM5A-MR/pr_SAM-44_IPSL-IPSL-CM5A-MR_rcp85_r1i1p1_SMHI-RCA4_v3_day_20210101-20251231.nc",na.rm = TRUE)
#.....
#....
#Seguir colocando nc's si se necesitase.



#6. Ahora usamos la función "ext" para extraer los datos de los archivos NetCDF
ext1 = extract(nc1, pt)
ext2 = extract(nc2, pt)
ext3 = extract(nc3, pt)
ext4 = extract(nc4, pt)
ext5 = extract(nc5, pt)
#.....
#....
#Seguir colocando ext's si se necesitase.


#7. Ploteamos como prueba un resultado
plot(ext1[2,],type = "l")

#8.Obteniendo una columna con fechas acorde al archivo NetCDF
idx <- getZ(nc2)

#9. Generamos los data frames para cada información extraída de cada archivo NetCDF
df1 = data.frame(t(ext1)-273,15); colnames(df2) <- data$ESTACIÓN
df2 = data.frame(t(ext2)-273,15); colnames(df2) <- data$ESTACIÓN
df3 = data.frame(t(ext3)-273,15); colnames(df2) <- data$ESTACIÓN
df4 = data.frame(t(ext4)-273,15); colnames(df2) <- data$ESTACIÓN
df5 = data.frame(t(ext5)-273,15); colnames(df2) <- data$ESTACIÓN
#.....
#....
#Seguir colocando df's si se necesitase.

#10. Guardamos en un archivo .csv el dataframe que deseamos
write.table(df2,file="C:/Users/Julio/Desktop/DATOS CMIP5/df2.csv",row.names=idx, col.names=NA, sep=",")  
#.....
#....
#Seguir colocando df's si se necesitase.
