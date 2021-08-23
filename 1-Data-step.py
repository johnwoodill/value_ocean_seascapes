# import databricks.koalas as ks
import numpy as np
import pandas as pd
import urllib.request
import xarray as xr
import glob
import math


def haversine(lat1, lon1, lat2, lon2):
    """
    Calculate the great circle distance between two points
    on the earth (specified in decimal degrees)
    """
    # convert decimal degrees to radians
    lon1, lat1, lon2, lat2 = map(math.radians, [lon1, lat1, lon2, lat2])
    # haversine formula
    dlon = lon2 - lon1
    dlat = lat2 - lat1
    a = math.sin(dlat/2)**2 + math.cos(lat1) * math.cos(lat2) * math.sin(dlon/2)**2
    c = 2 * math.asin(np.sqrt(a))
    r = 6371  # Radius of earth in kilometers. Use 3956 for miles
    return c * r


def download_seascapes(year_):
    url = (f"https://cwcgom.aoml.noaa.gov/thredds/ncss/SEASCAPE_8DAY/SEASCAPES"
           f".nc?var=CLASS&var=P&north=80&west=-180&east=180&south=-80&disable"
           f"ProjSubset=on&horizStride=1&time_start={year_}-01-01T12:00:00Z"
           f"&time_end={year_}-12-31T12:00:00Z&timeStride=1&addLatLon=tru"
           f"e&accept=netcdf")

    # Download classes
    urllib.request.urlretrieve(url, filename=(f"data/seascapes/seascapes_8D_"
                                              f"CLASS_PROB_{year_}.nc"))

    print(f"Saving: data/seascapes/seascapes_8D_CLASS_PROB_{year_}.nc")
    return 0


def proc_gfw():
    # Get GFW data
    files = glob.glob('/data2/GFW_V2/GFW_10d_2012_2020/public/*.csv')

    list_ = []
    for file in files:
        df = pd.read_csv(file)
        df = df.assign(lat=(df['cell_ll_lat'] + 0.05),
                       lon=(df['cell_ll_lon'] + 0.05))
        df = df[['date', 'lat', 'lon', 'mmsi', 'hours', 'fishing_hours']]
        list_.append(df)

    dat = pd.concat(list_, sort=False)
    del list_

    # Load vessel characteristics
    vessel_dat = pd.read_csv(
        '/data2/GFW_V2/GFW_10d_2012_2020/docs/fishing-vessels-v2.csv')

    vessel_dat = vessel_dat.get(['mmsi', 'flag_gfw', 'vessel_class_gfw',
                                 'engine_power_kw_gfw'])

    # Merge on mmsi
    dat = dat.merge(vessel_dat, how='left', on='mmsi')

    dat = dat.assign(lon=np.round(dat['lon'], 2))
    dat = dat.assign(lat=np.round(dat['lat'], 2))

    # Adjust to anti-meridian
    # dat = dat.assign(lon=np.where(dat['lon'] < 0, dat['lon'] + 360, dat['lon']))

    dat = dat.assign(lat_lon=dat['lat'].astype(str) + "_" + dat['lon'].astype(str))

    dat.groupby(['date', 'lat_lon']).agg({'lat': 'mean', 'lon': 'mean',
                                          'mmsi': 'count', 'hours': 'sum',
                                          'fishing_hours': 'sum'}).reset_index(drop=True)

    dat = dat.sort_values('date').reset_index(drop=True)

    # Columns
    # --------------------------------------------------------------------------
    # ['date', 'lat_bin', 'lon_bin', 'mmsi', 'fishing_hours', 'lat', 'lon',
    #  'flag', 'vessel_class_gfw', 'length', 'tonnage', 'engine_power',
    #  'active_2012', 'active_2013', 'active_2014', 'active_2015',
    #  'active_2016', 'year', 'lat_lon'], dtype='object')
    # --------------------------------------------------------------------------

    # GFW 2012-2020
    dat.to_parquet('data/full_GFW_public_10d.parquet')
    print("Saving: data/full_GFW_public_10d.parquet")
    return 0


def get_closest_gfw(lat1, lon1, date):
    indat = gfw_dat[gfw_dat['date'] == date]
    indat = indat[(
        indat['lat'] >= lat1 - 10) & (indat['lat'] <= lat1 + 10)]

    indat = indat[(
        indat['lon'] >= lon1 - 10) & (indat['lon'] <= lon1 + 10)]

    indat = indat.reset_index(drop=True)

    dist = indat.apply(
        lambda x: haversine(lat1, lon1, x['lat'], x['lon']), axis=1)

    indat = indat.assign(dist=dist).sort_values('dist')


# Get GFW data
# gfw_results = proc_gfw()

dat = pd.read_parquet('data/full_GFW_public_10d.parquet')

gfw_dat = pd.read_parquet('data/full_GFW_public_10d.parquet')




# Get Seascape data
years = np.linspace(2012, 2020, 9)
out_results = [download_seascapes(int(year_)) for year_ in years]


file = "data/seascapes/seascapes_8D_CLASS_PROB_2016.nc"
ds = xr.open_dataset(file)
df = ds.to_dataframe()
df = df.reset_index()
df.head()

df = df.assign(date=pd.to_datetime(df['time']))
df.head()


