import pandas as pd
import numpy as np

import dask.dataframe as dd

from lib.proc_envData import *
from lib.spatial import *


# %autoindent 

def proc_data():
    proc_gfw()

    grid_sst(grids)

    grid_chl(grids)

    grid_sea(grids)


lat = 1.0
lon = 195.8
gdat = sst
col_var = 'sst'
def get_closest_grid(gdat, lat, lon, col_var):
    month = gdat['month'].iat[0]
    year = gdat['year'].iat[0]
    gdat = gdat[(gdat['month'] == month) & (gdat['year'] == year)]
    gdat = gdat[(gdat['lat'] >= lat - 0.5) & (gdat['lat'] <= lat + 0.5)]
    gdat['dist'] = gdat.apply(lambda x: haversine(x['lon'], x['lat'], lon, lat), axis=1)
    gdat = gdat.sort_values('dist')
    near_value = gdat[f"{col_var}"].iat[0]
    row_index = gdat.index.values[0]
    # print(lat, lon)
    return near_value



# Get WCPFC data
gfw = pd.read_csv("data/gfw_grid_hawaii.csv")
wdat = pd.read_csv("data/wcpo_effort_seascape_2012_2019.csv")


# Proc grids for gfw
gfw['grid'] = gfw.apply(lambda x: get_grid(x['lon'], x['lat'], grids), axis=1)
gfw = gfw.dropna(subset=['grid']).reset_index(drop=True)

# gfw.to_csv("data/processed/1-gfw_grids.csv", index=False)

gfw = pd.read_csv('data/processed/1-gfw_grids.csv')
sst = pd.read_csv('data/processed/sst_grid_2012_2020.csv')
chl = pd.read_csv('data/processed/chl_grid_2012_2020.csv')
sea = pd.read_csv('data/processed/sea_grid_2012_2020.csv')

# gfw = gfw[(gfw['month'] == 7) & (gfw['year'] == 2016)]
# gfw = gfw.iloc[0:10, :]

gfw['lat'] = np.round(gfw['lat'], 0)
gfw['lon'] = np.round(gfw['lon'], 0)
gfw['lat_lon'] = gfw['lat'].astype(str) + "_" + gfw['lon'].astype(str)

gfw = gfw.groupby(['lat_lon', 'year', 'month', 'grid']).mean().reset_index()

sst_res = gfw.apply(lambda x: get_closest_grid(sst, x['lat'], x['lon'], 'sst'), axis=1)

gfw = gfw.assign(sst = sst_res)
gfw.to_csv("data/processed/1-gfw_grids_sst-test.csv", index=False)

chl_res = gfw.apply(lambda x: get_closest_grid(chl, x['lat'], x['lon'],'chlor_a'), axis=1)

gfw = gfw.assign(chl = chl_res)
gfw.to_csv("data/processed/1-gfw_grids_sst_chl-test.csv", index=False)

sea_res = gfw.apply(lambda x: get_closest_grid(sea, x['lat'], x['lon'],'CLASS'), axis=1)

gfw = gfw.assign(sea = sea_res)
gfw.to_csv("data/processed/1-gfw_grids_sst_chl_sea-test.csv", index=False)

indat = gfw.iloc[[5], :]



month = indat['month'].iat[0]
year = indat['year'].iat[0]
lat = indat['lat'].iat[0]
lon = indat['lon'].iat[0]



gfw['sst'] = gfw.apply(lambda x: get_closest_grid(sst, x['lat'], x['lon'], x['index']), axis=1)

# Proc wcpfc data

grids = create_wcpfc_grids(wdat)

wdat = wdat.assign(lon_short=wdat['lon_short'].str.replace('W', ''))
wdat = wdat.assign(lat_short=wdat['lat_short'].str.replace('N', ''),
                    lon_short=wdat['lon_short'].astype(float) * -1)

wdat['lat_short'] = np.where(wdat['lat_short'].str.contains("S"),
                            wdat['lat_short'].str.replace("S", "").
                            astype(float) * -1, wdat['lat_short'])

wdat = wdat.assign(lat_lon = wdat['lat_short'].astype(str) + "_" + wdat['lon_short'].astype(str))

grids_merge = grids[['grid', 'lat_lon']]

mdat1 = wdat.merge(grids_merge, on='lat_lon', how='left')

mdat2 = gfw.merge(mdat1, on=['year', 'month', 'grid'], how='left')






import xarray as xr



ds = xr.open_dataset('data/O400/woa18_all_o01_01.nc', decode_times=False)
units, reference_date = ds.time.attrs['units'].split('since')
ds['time'] = pd.date_range(start=reference_date, periods=ds.sizes['time'], freq='M')


ds = xr.open_dataset('data/O400/woa18_all_o01_01.nc')
ds = ds.drop_dims(['d2'])
ds = xr.decode_cf(ds, use_cftime=True)


df = ds.to_dataframe().reset_index()