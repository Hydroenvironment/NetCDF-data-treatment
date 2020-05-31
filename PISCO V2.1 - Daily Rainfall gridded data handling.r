
##########################################################################
#TRATAMIENTO PRIMARIO DE DATOS PISCO A PARTIR DE ARCHIVO PRINCIPAL NetCDF#
########################################################################## 

#Cargamos ó instalamos librerías principales
library(raster)
library(ggplot2)
library(ncdf4)
library(maptools)

#Fijamos el directorio de trabajo
setwd("C:/TEMPORAL/RSMINERVEWORKMAY2020/NetCDF files")     ## Ubicación de la carpeta donde est?n los archivos *.tif o el *.nc
ts = seq(as.Date("1981-01-01"),as.Date("1982-05-31"),by = "day")## Secuencia de fechas (año%-mes%-día%), puede cambiar "month" por "day" o "year"

##st = stack(list.files(pattern=".tif"))## Si son *.tif
nc = brick("C:/TEMPORAL/RSMINERVEWORKMAY2020/NetCDF files/PISCOpd.nc")## Si es *.nc

##########################################################################
#Caso shapefile de puntos(estaciones) - DATOS DIARIOS!                   #
########################################################################## 

pt = shapefile("C:/TEMPORAL/RSMINERVEWORKMAY2020/SHAPE STATIONS/Mantaro_Geo.shp") ## Si tiene puntos como shp
ext = extract(nc,pt)## Extract, para sacar los puntos
df=data.frame(ext)

#Si deseas obtener datos en un período puntual, debes recurrir a eliminar columnas
#del dataframe formado por los datos diarios desde 1981.
length(ts)
df[length(ts)+1:13149] <- list(NULL)
#Transponemos el dataframe
df <- data.frame(t(df))

#Asignamos nombres a filas y columnas acorde a fechas y estaciones respectivamente
rownames(df) <- ts
estaciones<-c(pt@data[["ESTACIÃ.N"]])
names(df)<-estaciones

#Extraemos datos de una estación
JAUJA<-df[,c("JAUJA")]

#USANDO PLOT() PARA GRAFICAR LA SERIE DE UNA ESTACIÓN DE INTERÉS
#Gráfico simple
df2 = data.frame(ts,JAUJA)                                          
plot(df2,main="PRECIPITACIÓN DIARIA 1981-2018 ESTACIÓN JAUJA",xlab="tiempo(días)", ylab="precipitación (mm)",type = "l")
#Boxplot
boxplot(df2$JAUJA, main="BOXPLOT", xlab="Precipitación diaria (mm)", ylab="JAUJA", horizontal=TRUE,col=terrain.colors(3))

#USANDO GGPLOT2 PARA GRAFICAR LA SERIE DE UNA ESTACIÓN DE INTERÉS
#Graficamos puntos en la estación ACOSTAMBO
ggplot(data = df, mapping = aes(x = ts, 
                                y = ACOSTAMBO))+ geom_line(alpha = 0.5,color = "blue")+labs(x = "tiempo(días)"
                                                                                            ,y="Precipitación (mm)",title = "PRECIPITACIÓN DIARIA 1981-2018 ESTACIÓN JAUJA")

#Guardamos archivo
write.csv(df,"C:/TEMPORAL/RSMINERVEWORKMAY2020/NetCDF files/datoslluvia.csv")  ## Guardar como *.csv

##########################################################################
#Caso Coordenadas                                                        #
########################################################################## 
xy = cbind(-72.93199135377485,  -13.881556230479553)                    ## Introducir coordenadas
ext = extract(nc, xy)                                                   ## Extraer sólo un punto   (nc o tif)   

#Guardamos archivo
write.csv(ext,"C:/TEMPORAL/RSMINERVEWORKMAY2020/NetCDF files/estacionX.csv")   ## Cambia la dirección para guardar

##########################################################################
#Caso polígonos                                                          #
##########################################################################

# Si lo que quiere es sacar una media o sumatoria de un polígono en base a rásters

list<-list.files("C:/TEMPORAL/RSMINERVEWORKMAY2020/raster files","\\.tif$")          ## Lista de archivos *.tif 
Area2 = shapefile("C:/TEMPORAL/RSMINERVEWORKMAY2020/SHAPE CUENCAS/Mantaro_GEO_Cuencast.shp")
mapply(function(i){
  mk = mask(crop(raster(list[i]),Area2),Area2)## corta la imagen o el paquete de imágenes (como un clip)
  a = mean(getValues(mk),na.rm=T)## cambia sum por mean o la función que requiera
  print(i)
  return(a)},1:length(list))
##########################################################################
#Ahora es tu turno!, puedes Mejorar el script!                           #
##########################################################################
                                       
