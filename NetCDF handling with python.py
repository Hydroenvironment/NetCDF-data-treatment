############################################
#TRATAMIENTO DE DATOS NETCDF USANDO PYTHON #
############################################
'''
Código original y créditos: Chris Slocum, CSU, EEUU
http://schubert.atmos.colostate.edu/~cslocum/netcdf_example.html#down
netcdf4-python -- http://code.google.com/p/netcdf4-python/
Fuente de datos: NCEP/NCAR Reanalysis -- Kalnay et al. 1996
http://dx.doi.org/10.1175/1520-0477(1996)077<0437:TNYRP>2.0.CO;2
'''
import datetime as dt  # Python standard library datetime  module
import numpy as np
from netCDF4 import Dataset  # http://code.google.com/p/netcdf4-python/
import matplotlib.pyplot as plt
from mpl_toolkits.basemap import Basemap, addcyclic, shiftgrid
import os

os.chdir("C:\\Users\\Julio\\Documents\\EVENTOS\\UNSCH-Julio 2020\\NetCDF")

def ncdump(nc_fid, verb=True):
    '''
    ncdump extrae dimensiones, variables e información de atributos.
    La información que se extrae es muy similar que usando ncdump (NCAR) .
    ncdump requiere una instancia válida del dataset a usar.

    Parámetros:
    ----------
    nc_fid : netCDF4.Dataset
        A netCDF4 dateset object
    verb : Boolean
        whether or not nc_attrs, nc_dims, and nc_vars are printed

    Returns
    -------
    nc_attrs : list
        A Python list of the NetCDF file global attributes
    nc_dims : list
        A Python list of the NetCDF file dimensions
    nc_vars : list
        A Python list of the NetCDF file variables
    '''
    def print_ncattr(key):
        """
        Prints the NetCDF file attributes for a given key

        Parameters
        ----------
        key : unicode
            a valid netCDF4.Dataset.variables key
        """
        try:
            print ("\t\ttype:", repr(nc_fid.variables[key].dtype))
            for ncattr in nc_fid.variables[key].ncattrs():
                print ('\t\t%s:' % ncattr,\
                      repr(nc_fid.variables[key].getncattr(ncattr)))
        except KeyError:
            print ("\t\tWARNING: %s does not contain variable attributes" % key)

    # Atributos globales del archivo NetCDF
    nc_attrs = nc_fid.ncattrs()
    if verb:
        print ("NetCDF Global Attributes:")
        for nc_attr in nc_attrs:
            print ('\t%s:' % nc_attr, repr(nc_fid.getncattr(nc_attr)))
    nc_dims = [dim for dim in nc_fid.dimensions]  # list of nc dimensions
    # información geoespacial.
    if verb:
        print ("NetCDF dimension information:")
        for dim in nc_dims:
            print ("\tName:", dim )
            print ("\t\tsize:", len(nc_fid.dimensions[dim]))
            print_ncattr(dim)
    # Información de variables.
    nc_vars = [var for var in nc_fid.variables]  # list of nc variables
    if verb:
        print ("NetCDF variable information:")
        for var in nc_vars:
            if var not in nc_dims:
                print ('\tName:', var)
                print ("\t\tdimensions:", nc_fid.variables[var].dimensions)
                print ("\t\tsize:", nc_fid.variables[var].size)
                print_ncattr(var)
    return nc_attrs, nc_dims, nc_vars

nc_f = ('PISCOpd.nc')  # Nombre de archivo
nc_fid = Dataset(nc_f, 'r')  # Aquí abriremos el archivo
                             # y crearemos la instancia del tipo ncCDF4
nc_attrs, nc_dims, nc_vars = ncdump(nc_fid)
# Extraemos data del archivo NetCDF
lats = nc_fid.variables['latitude'][:]  # extraemos/copiamos la data
lons = nc_fid.variables['longitude'][:]
time = nc_fid.variables['time'][:]
air = nc_fid.variables['z'][:]  # generamos variables time, lat, lon

time_idx = 237  # elegimos un día particular el 2012
# Configuramos tiempo
offset = dt.timedelta(hours=48)
# Generamos objetos "datetime" con todas las fechas
dt_time = [dt.date(1, 1, 1) + dt.timedelta(hours=t) - offset\
           for t in time]
cur_time = dt_time[time_idx]

# Graficamos temperatura en un día
fig = plt.figure()
fig.subplots_adjust(left=0., right=1., bottom=0., top=0.9)
# Configuramos mapa, mayores detalles: http://matplotlib.org/basemap/users/mapsetup.html
# Para otras proyecciones.
m = Basemap(projection='tmerc', llcrnrlat=-90, urcrnrlat=90,\
            llcrnrlon=0, urcrnrlon=360, resolution='c', lon_0=0)
m.drawcoastlines()
m.drawmapboundary()
# Hacemos el gráfico continuo
air_cyclic, lons_cyclic = addcyclic(air[time_idx, :, :], lons)
# Cambiamos el grid para visuzaliar desde -180 to 180 en vez de 0 a 360.
air_cyclic, lons_cyclic = shiftgrid(180., air_cyclic, lons_cyclic, start=False)
# Creamos arrays 2D lat/lon para Basemap
lon2d, lat2d = np.meshgrid(lons_cyclic, lats)
# Transformamos lat/lon en coordenadas del gráfico
x, y = m(lon2d, lat2d)
# Graficamos temperatura del aire con 11 intervalos
cs = m.contourf(x, y, air_cyclic, 11, cmap=plt.cm.Spectral_r)
cbar = plt.colorbar(cs, orientation='horizontal', shrink=0.5)
cbar.set_label("%s (%s)" % (nc_fid.variables['air'].var_desc,\
                            nc_fid.variables['air'].units))
plt.title("%s on %s" % (nc_fid.variables['air'].var_desc, cur_time))
