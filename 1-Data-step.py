# import databricks.koalas as ks
import numpy as np
import pandas as pd
import urllib.request
import xarray as xr
import glob
import math
import os



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


def download_monthly_seascapes(year_):
    url = (f"https://cwcgom.aoml.noaa.gov/thredds/ncss/SEASCAPE_MONTH/SEASCAPES"
           f".nc?var=CLASS&var=P&north=80&west=-180&east=180&south=-80&disable"
           f"ProjSubset=on&horizStride=1&time_start={year_}-01-01T12:00:00Z"
           f"&time_end={year_}-12-31T12:00:00Z&timeStride=1&addLatLon=tru"
           f"e&accept=netcdf")

    # Download classes
    urllib.request.urlretrieve(url, filename=(f"data/seascapes/seascapes_MONTHLY_"
                                              f"CLASS_PROB_{year_}.nc"))

    print(f"Saving: data/seascapes/seascapes_MONTHLY_CLASS_PROB_{year_}.nc")
    return 0

file = seascape_files[0]
def proc_seascape_monthly(file):
    print(f"Processing: {file}")
    LAT1 = -60; LON1 = 100
    LAT2 = 60; LON2 = 240

    # Get filename for save
    filename = os.path.splitext(file)[0]
    ds = xr.open_dataset(file)
    df = ds.to_dataframe()
    df = df.reset_index()
    
    # Convert to 0-360
    df = df.assign(lon=np.where(df['lon'] < 0, df['lon'] + 360, df['lon']))

    # Fitlter lat/lon
    df = df[(df['lon'] >= LON1) & (df['lon'] <= LON2)]
    df = df[(df['lat'] >= LAT1) & (df['lat'] <= LAT2)]
    df = df.reset_index(drop=True)
    df = df.assign(month = pd.DatetimeIndex(df['time'].astype(str)).month,
                   year = pd.DatetimeIndex(df['time'].astype(str)).year)

    # Save
    df.to_csv(f"{filename}.csv", index=False)
    print(f"Saving: {filename}.csv")    
    return 0



def download_8D_seascapes(year_):
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



lat_lon1 = ldat_latlon2012[0]
latlon_link = sea_2019
lat_lon1 = '-10.0_115.0_2'

Lat: -30.0 --- Lon: 150.0
lat_lon1 = '-30.0_150.0_1'
6.0-2019 Lat: -50.0 --- Lon: 170.0
lat_lon1 = '-50.0_170.0_6'

def get_latlon(lat_lon1: np.array, latlon_link: pd.DataFrame) -> pd.DataFrame:
    lat1, lon1, month = lat_lon1.split('_')
    lat1 = np.asfarray(lat1, float)
    lon1 = np.asfarray(lon1, float)
    month = np.asfarray(month, int)
    year = latlon_link['year'].iat[0]
    print(f"Processing: {month}-{year} Lat: {lat1} --- Lon: {lon1}")
    indat = latlon_link[latlon_link['month'] == month]

    indat = indat[(indat['lat'] >= lat1 - 10) & (indat['lat'] <= lat1 + 10)]
    indat = indat[(indat['lon'] >= lon1 - 5) & (indat['lon'] <= lon1 + 5)]
    indat = indat.reset_index(drop=True)

    indat = indat.assign(lat_lon = indat['lat'].astype(str) + "_" + indat['lon'].astype(str))

    dist = indat.apply(lambda x: haversine(lon1, lat1, x['lon'], x['lat']), axis=1)
    indat = indat.assign(dist = dist)
    
    link = indat.sort_values('dist')['lat_lon'].iat[0]
    dist = indat.sort_values('dist')['dist'].iat[0]
    retdat = pd.DataFrame({'year': [year], 'month': [month], 'lat': [lat1], 
                           'lon': [lon1], 'link': [link], 'dist': [dist]})
    return retdat





# ----------------------------------------------
# Get GFW data
# gfw_results = proc_gfw()

dat = pd.read_parquet('data/full_GFW_public_10d.parquet')

gfw_dat = pd.read_parquet('data/full_GFW_public_10d.parquet')




# ----------------------------------------------
# Get Seascape data
years = np.linspace(2012, 2020, 9)
out_results = [download_8D_seascapes(int(year_)) for year_ in years]

# Get Monthly Seascape data
years = np.linspace(2012, 2020, 9)
out_results = [download_monthly_seascapes(int(year_)) for year_ in years]


# file = "data/seascapes/seascapes_8D_CLASS_PROB_2016.nc"
# ds = xr.open_dataset(file)
# df = ds.to_dataframe()
# df = df.reset_index()
# df.head()

# df = df.assign(date=pd.to_datetime(df['time']))
# df.head()


# --------------------------------------------
# Link LONGLINE data to Seascape data


# Load data sets
ldat = pd.read_csv('data/LONGLINE_WCPFC_5x5_grid_flag_year_month.CSV')

# Index(['yy', 'mm', 'flag_id', 'lat_short', 'lon_short', 'cwp_grid', 'hhooks',
#        'alb_c', 'alb_n', 'yft_c', 'yft_n', 'bet_c', 'bet_n', 'mls_c', 'mls_n',
#        'blm_c', 'blm_n', 'bum_c', 'bum_n', 'swo_c', 'swo_n', 'bsh_n', 'fal_n',
#        'mak_n', 'ocs_n', 'thr_n', 'ham_n', 'por_n', 'oth_c', 'oth_n'],
#       dtype='object')

# For each longline grid in each year, find closests Seascape

# Convert short names to -/+
ldat = ldat.assign(lat_dir = ldat['lat_short'].str.slice(-1),
                   lon_dir = ldat['lon_short'].str.slice(-1),
                   lat = ldat['lat_short'].str[:-1],
                   lon = ldat['lon_short'].str[:-1])

ldat = ldat.assign(lat = ldat['lat'].astype(float),
                   lon = ldat['lon'].astype(float))

ldat = ldat.assign(lat = np.where(ldat['lat_dir'] == "N", ldat['lat'], ldat['lat']*-1),
                   lon = np.where(ldat['lon_dir'] == "E", ldat['lon'], ldat['lon']*-1))

ldat = ldat.assign(lon = np.where(ldat['lon'] < 0, ldat['lon'] + 360, ldat['lon']))

ldat = ldat.rename(columns={'yy': 'year', 'mm': 'month'})

# Get unique longline grids
ldat = ldat.assign(lat_lon_month = ldat['lat'].astype(str) + "_" + ldat['lon'].astype(str) + "_" + ldat['month'].astype(str))
ldat = ldat.assign(lat_lon = ldat['lat'].astype(str) + "_" + ldat['lon'].astype(str))

# Test plot
test = ldat[ldat['year'] == 2013]
plt.scatter('lon', 'lat', data=test)
plt.show()


# Load Seascape data
seascape_files = sorted(glob.glob('data/seascapes/*MONTHLY*.nc'))
sea_res = [proc_seascape_monthly(file_) for file_ in seascape_files]

sea_2012 = pd.read_csv('data/seascapes/seascapes_MONTHLY_CLASS_PROB_2012.csv')
sea_2013 = pd.read_csv('data/seascapes/seascapes_MONTHLY_CLASS_PROB_2013.csv')
sea_2014 = pd.read_csv('data/seascapes/seascapes_MONTHLY_CLASS_PROB_2014.csv')
sea_2015 = pd.read_csv('data/seascapes/seascapes_MONTHLY_CLASS_PROB_2015.csv')
sea_2016 = pd.read_csv('data/seascapes/seascapes_MONTHLY_CLASS_PROB_2016.csv')
sea_2017 = pd.read_csv('data/seascapes/seascapes_MONTHLY_CLASS_PROB_2017.csv')
sea_2018 = pd.read_csv('data/seascapes/seascapes_MONTHLY_CLASS_PROB_2018.csv')
sea_2019 = pd.read_csv('data/seascapes/seascapes_MONTHLY_CLASS_PROB_2019.csv')

# Drop na
sea_2012 = sea_2012[sea_2012['P'] > 0]
sea_2013 = sea_2013[sea_2013['P'] > 0]
sea_2014 = sea_2014[sea_2014['P'] > 0]
sea_2015 = sea_2015[sea_2015['P'] > 0]
sea_2016 = sea_2016[sea_2016['P'] > 0]
sea_2017 = sea_2017[sea_2017['P'] > 0]
sea_2018 = sea_2018[sea_2018['P'] > 0]
sea_2019 = sea_2019[sea_2019['P'] > 0]

# Get lat_lon
sea_2012 = sea_2012.assign(lat_lon = sea_2012['lat'].astype(str) + "_" + sea_2012['lon'].astype(str))
sea_2013 = sea_2013.assign(lat_lon = sea_2013['lat'].astype(str) + "_" + sea_2013['lon'].astype(str))
sea_2014 = sea_2014.assign(lat_lon = sea_2014['lat'].astype(str) + "_" + sea_2014['lon'].astype(str))
sea_2015 = sea_2015.assign(lat_lon = sea_2015['lat'].astype(str) + "_" + sea_2015['lon'].astype(str))
sea_2016 = sea_2016.assign(lat_lon = sea_2016['lat'].astype(str) + "_" + sea_2016['lon'].astype(str))
sea_2017 = sea_2017.assign(lat_lon = sea_2017['lat'].astype(str) + "_" + sea_2017['lon'].astype(str))
sea_2018 = sea_2018.assign(lat_lon = sea_2018['lat'].astype(str) + "_" + sea_2018['lon'].astype(str))
sea_2019 = sea_2019.assign(lat_lon = sea_2019['lat'].astype(str) + "_" + sea_2019['lon'].astype(str))





# Get individual year lat/lon and link to closests
#%%
ldat_latlon2012 = sorted(ldat[ldat['year'] == 2012]['lat_lon_month'].unique())
sea_2012_link = [get_latlon(x, sea_2012) for x in ldat_latlon2012]
sea_2012_linkdf = pd.concat(sea_2012_link)

ldat_latlon2013 = ldat[ldat['year'] == 2013]['lat_lon_month'].unique()
sea_2013_link = [get_latlon(x, sea_2013) for x in ldat_latlon2013]
sea_2013_linkdf = pd.concat(sea_2013_link)

ldat_latlon2014 = ldat[ldat['year'] == 2014]['lat_lon_month'].unique()
sea_2014_link = [get_latlon(x, sea_2014) for x in ldat_latlon2014]
sea_2014_linkdf = pd.concat(sea_2014_link)

ldat_latlon2015 = ldat[ldat['year'] == 2015]['lat_lon_month'].unique()
sea_2015_link = [get_latlon(x, sea_2015) for x in ldat_latlon2015]
sea_2015_linkdf = pd.concat(sea_2015_link)

ldat_latlon2016 = ldat[ldat['year'] == 2016]['lat_lon_month'].unique()
sea_2016_link = [get_latlon(x, sea_2016) for x in ldat_latlon2016]
sea_2016_linkdf = pd.concat(sea_2016_link)

ldat_latlon2017 = ldat[ldat['year'] == 2017]['lat_lon_month'].unique()
sea_2017_link = [get_latlon(x, sea_2017) for x in ldat_latlon2017]
sea_2017_linkdf = pd.concat(sea_2017_link)

ldat_latlon2018 = ldat[ldat['year'] == 2018]['lat_lon_month'].unique()
sea_2018_link = [get_latlon(x, sea_2018) for x in ldat_latlon2018]
sea_2018_linkdf = pd.concat(sea_2018_link)

ldat_latlon2019 = ldat[ldat['year'] == 2019]['lat_lon_month'].unique()
sea_2019_link = [get_latlon(x, sea_2019) for x in ldat_latlon2019]
sea_2019_linkdf = pd.concat(sea_2019_link)

sea_linkdf = pd.concat([sea_2012_linkdf, sea_2013_linkdf, sea_2014_linkdf, sea_2015_linkdf,
                        sea_2016_linkdf, sea_2017_linkdf, sea_2018_linkdf, sea_2019_linkdf])

sea_linkdf.to_csv('data/lookups/seascape_wcpgrids_link.csv', index=False)
#%%


# Link seascape data to WCP grids

# Get lookup table
sea_linkdf = pd.read_csv('data/lookups/seascape_wcpgrids_link.csv')
sea_linkdf = sea_linkdf.assign(lat_lon = sea_linkdf['lat'].astype(str) + "_" + sea_linkdf['lon'].astype(str)).drop(columns=['lat', 'lon'])
sea_linkdf = sea_linkdf[['year', 'month', 'link', 'dist', 'lat_lon']]

# Keep within grid
sea_linkdf = sea_linkdf[sea_linkdf['dist'] <= 5]

# Merge lookup table  with longline data
mdat = ldat.merge(sea_linkdf, on=['year', 'month', 'lat_lon'])

# Keep only US fleets
mdat = mdat[mdat['flag_id'] == 'US']

#    year     bet_c
# 0  2012  4409.387
# 1  2013  3875.900
# 2  2014  4568.294
# 3  2015  5295.965
# 4  2016  5717.836
# 5  2017  4928.621
# 6  2018  4974.651
# 7  2019  5664.003


# Remove lat/lon not in seascape from sea_linkdf
sea_linkdf_latlon = sea_linkdf.link.unique()

sea_2012 = sea_2012[sea_2012['lat_lon'].isin(sea_linkdf_latlon)]
sea_2013 = sea_2013[sea_2013['lat_lon'].isin(sea_linkdf_latlon)]
sea_2014 = sea_2014[sea_2014['lat_lon'].isin(sea_linkdf_latlon)]
sea_2015 = sea_2015[sea_2015['lat_lon'].isin(sea_linkdf_latlon)]
sea_2016 = sea_2016[sea_2016['lat_lon'].isin(sea_linkdf_latlon)]
sea_2017 = sea_2017[sea_2017['lat_lon'].isin(sea_linkdf_latlon)]
sea_2018 = sea_2018[sea_2018['lat_lon'].isin(sea_linkdf_latlon)]
sea_2019 = sea_2019[sea_2019['lat_lon'].isin(sea_linkdf_latlon)]

# Merge with seascape data
all_seas = [sea_2012, sea_2013, sea_2014, sea_2015, sea_2016, sea_2017, sea_2018, sea_2019]
all_seas_df = pd.concat(all_seas).drop(columns=['lat', 'lon', 'time']).reset_index(drop=True)

mdat2 = mdat.merge(all_seas_df, left_on = ['year', 'month', 'link'], right_on = ['year', 'month', 'lat_lon'])
mdat2

mdat2.CLASS.unique()

mdat2.to_csv('data/wcpo_effort_seascape_2012_2019.csv', index=False)
