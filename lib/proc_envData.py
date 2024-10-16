import pandas as pd
import glob as glob
import numpy as np
from shapely.geometry import Point
import xarray as xr
import geopandas as gpd

from lib.spatial import *

def create_wcpfc_grids(wcpfc):
    dat = wcpfc[['lon_short', 'lat_short']]
    dat = dat.assign(lon_short=dat['lon_short'].str.replace('W', ''))
    dat = dat.assign(lat_short=dat['lat_short'].str.replace('N', ''),
                     lon_short=dat['lon_short'].astype(float) * -1)

    dat['lat_short'] = np.where(dat['lat_short'].str.contains("S"),
                                dat['lat_short'].str.replace("S", "").
                                astype(float) * -1, dat['lat_short'])
    
    dat = dat.drop_duplicates().reset_index(drop=True)

    dat.columns = ['lon', 'lat']

    lst_ = []
    for i in range(len(dat)):
        lon = dat.loc[i, 'lon']
        lat = dat.loc[i, 'lat']

        p = Point(float(lon) + 2.5, float(lat) + 2.5)
        lst_.append(p.buffer(2.5, cap_style=3))

    points = gpd.GeoDataFrame({'grid': [x for x in range(1, 30)],
                               'lat': dat['lat'],
                               'lon': dat['lon'],
                               'geometry': [x for x in lst_]})

    points.to_file('data/wcpfc_bet_grids.shp')
    return points



def proc_gfw():
    GFW_FILES = glob.glob(
        '/home/server/pi/homes/woodilla/Projects/gfw_v2/data/*.csv')
    lst_ = []
    for file_ in GFW_FILES:
        df = pd.read_csv(file_)
        df['cell_ll_lon'] = np.where(df['cell_ll_lon'] < 0,
                                     df['cell_ll_lon'] + 360,
                                     df['cell_ll_lon'])
        df = df[(df['cell_ll_lon'] >= 100) & (df['cell_ll_lon'] <= 230)]
        df = df[(df['cell_ll_lat'] > 0) & (df['cell_ll_lat'] <= 50)]

        df = df.assign(lat_lon=df['cell_ll_lat'].astype(str) + "_" + df['cell_ll_lon'].astype(str),
            month=pd.to_datetime(df['date']).dt.month,
            year=pd.to_datetime(df['date']).dt.year)
        df = df[df['vessel_class_gfw'] == 'drifting_longlines']
        df = df[df['fishing_hours'] > 0]

        df = df[['month', 'year', 'cell_ll_lat', 'cell_ll_lon',
                 'lat_lon', 'fishing_hours']]

        df = df.groupby(['month', 'year', 'lat_lon']).agg(
            {'cell_ll_lon': 'mean', 'cell_ll_lat': 'mean',
             'fishing_hours': 'sum'}).reset_index()

        lst_.append(df)
        print(file_)
    gfw = pd.concat(lst_)
    gfw = gfw.reset_index(drop=True)
    gfw.columns = ['month', 'year', 'lat_lon', 'lon', 'lat', 'fishing_hours']

    gfw.to_csv("data/gfw_grid_hawaii.csv", index=False)


def get_grid(lon, lat, grids):
    lon = convert_360(lon)
    res = None
    for i in range(0, 29):
        p = Point(lon, lat)
        polygon = grids.geometry[i]
        res = polygon.contains(p)
        if res:
            print(f"Found Point: {p}")
            return grids.loc[i, 'grid']
        


def grid_sst(sdat):
    files = sorted(glob.glob('./env_data/SST_MONTHLY/*.nc'))
    
    lst_ = []
    for file_ in files:
        year_ = file_.split("/")[-1].split(".")[1].split("_")[0][0:4]
        month_ =  file_.split("/")[-1].split(".")[1].split("_")[0][4:6]
        
        ds = xr.open_dataset(file_)
        ds = ds.rio.write_crs("epsg:4326")
        # ds['lon'] = convert_360(ds['lon'])
        ds = ds.where(ds['lon'] <= -140)
        ds = ds['sst']
        
        for i in range(len(sdat)):
            fp = sdat.iloc[[i], :]
            cdat = ds.rio.clip(fp.geometry, fp.crs, all_touched=True, 
                                drop=True, invert=False, from_disk=True) 

            indat = cdat.to_dataframe().reset_index()
            # indat.columns = ['lat', 'lon', '' 'sst']
            indat.insert(0, 'month', month_)
            indat.insert(0, 'year', year_)
            
            # indat = indat[indat['sst'] > -9.969+36]
            indat = indat.dropna()
            lst_.append(indat)
            # print(f"{i} - {file_.split('/')[-1]}")
            print(indat)

    outdat = pd.concat(lst_)        
    outdat.to_csv("./data/processed/sst_grid_2012_2020.csv", index=False)




def grid_chl(sdat):
    files = sorted(glob.glob('./env_data/CHL_MONTHLY/*.nc'))
    
    lst_ = []
    for file_ in files:
        year_ = file_.split("/")[-1].split(".")[0][1:5]
        day_ = file_.split("/")[-1].split(".")[0][5:8]
        month_ = pd.to_datetime(f"{year_}-{day_}", format="%Y-%j").month
        
        ds = xr.open_dataset(file_)
        ds = ds.rio.write_crs("epsg:4326")
        ds = ds.where(ds['lon'] <= -140)
        ds = ds['chlor_a']
        
        for i in range(len(sdat)):
            fp = sdat.iloc[[i], :]
            cdat = ds.rio.clip(fp.geometry, fp.crs, all_touched=True, 
                                drop=True, invert=False, from_disk=True) 

            indat = cdat.to_dataframe().reset_index()
            # indat.columns = ['lat', 'lon', '' 'sst']
            indat.insert(0, 'month', month_)
            indat.insert(0, 'year', year_)
            
            # indat = indat[indat['sst'] > -9.969+36]
            indat = indat.dropna()
            lst_.append(indat)
            # print(f"{i} - {file_.split('/')[-1]}")
            print(indat)

    outdat = pd.concat(lst_)        
    outdat.to_csv("./data/processed/chl_grid_2012_2020.csv", index=False)



def grid_sea(sdat):
    file_ = './env_data/SEA_MONTHLY/Seascapes.nc'
    
    ds = xr.open_dataset(file_)
    ds = ds.rio.write_crs("epsg:4326")
    ds = ds['CLASS']
    
    lst_ = []
    for i in range(len(sdat)):
        fp = sdat.iloc[[i], :]
        cdat = ds.rio.clip(fp.geometry, fp.crs, all_touched=True, 
                            drop=True, invert=False, from_disk=True) 

        indat = cdat.to_dataframe().reset_index()
        month_ = pd.to_datetime(indat['time'], format='%Y-%m-%d H:M:S').dt.month
        year_ = pd.to_datetime(indat['time'], format='%Y-%m-%d H:M:S').dt.year
        indat['time'] = pd.to_datetime(indat['time'], format='%Y-%m-%d H:M:S').dt.strftime("%Y-%m-%d")
        indat.insert(0, 'month', month_)
        indat.insert(0, 'year', year_)
        indat = indat.rename(columns={'time': 'date'})
        indat = indat.dropna()
        
        indat = indat[['date', 'month', 'year', 'lat', 'lon', 'CLASS']]
        
        lst_.append(indat)
        print(indat)

    outdat = pd.concat(lst_)        
    outdat.to_csv("./data/processed/sea_grid_2012_2020.csv", index=False)


