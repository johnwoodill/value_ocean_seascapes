import pandas as pd 
import numpy as np
import xarray as xr
import glob

LAT1 = -60
LON1 = 120

LAT2 = 60
LON2 = 240

# Get list of seascape csvs
files = sorted(glob.glob('data/seascapes/*MONTHLY*.nc'))

files

file = files[4]
file
ds = xr.open_dataset(file)
df = ds.to_dataframe()
df = df.reset_index()

# Remove no classification
df = df[df['P'] > 0]

# Convert to 0-360
df = df.assign(lon=np.where(df['lon'] < 0, df['lon'] + 360, df['lon']))

# Fitlter lat/lon
df = df[(df['lon'] >= LON1) & (df['lon'] <= LON2)]
df = df[(df['lat'] >= LAT1) & (df['lat'] <= LAT2)]
df = df.reset_index(drop=True)


df.to_csv('data/seascape_2016.csv', index=False)
print(f"Saved: 'data/seascape_2016.csv'")
# # Issues with zero being letter O in seascape data
# df['date'] = df['time'].apply(lambda x: f"{x.year}" + f"-{x.month}".zfill(3) + f"-{x.day}".zfill(3))
# df = df[['date', 'lon', 'lat', 'CLASS', 'P']]
# df.columns = ['date', 'lon', 'lat', 'seascape_class', 'seascape_prob']


