
######################################################################################
# {capn} example: Guld of Mexico (GOM)
# Updated: 3/30/2017
# Original script written by Eli Fenichel, 2013 (in MATHEMATICA)
# Updated in R script by Seong Do Yun and Eli Fenichel
# Updated in Python script by A. John Woodill
# Reference: Fenichel & Abbott (2014)
# File location: system.file("demo", "GOM.R", package = "capn")
######################################################################################

import pandas as pd
import numpy as np
import matplotlib.pyplot as plt
from lib.capn import *

plt.style.use('seaborn-whitegrid')

# ----------------------------------------------------
## parameters from Fenichel & Abbott (2014)
# r = 0.3847                              # intrinsick growth rate
# param = pd.DataFrame({'r': [r]})

# # Big-eye Tuna population estimates: 569,888 mt
# # Minimum price: $8600/mt - $11000/mt
# param['k'] = 1613855                # carry capacity (mt)
# param['q'] = 0.0008                 # catchability coefficient q = Catch/(Hooks * Biomass)
# param['price'] = 4.20*2204.62       # price 
# param['cost'] = 1.91*2204.62        # cost

# param['alpha'] = 0.5436459179063678         # tech parameter
# param['gamma'] = 0.7882                     # pre-ITQ management parameter
# param['y'] = 0.15745573410462155            # system equivalence parameter
# param['delta'] = 0.03                       # discount rate

# param['order'] = 50                         # Cheby polynomial order
# param['upperK'] = param['k']                # upper K
# param['lowerK'] = 5*10**6                    # lower K
# param['nodes'] = 500                        # number of Cheby poly nodes
# # ----------------------------------------------------

#%%
# def gen_param(k, q, price, cost, alpha, gamma, y, delta, order, upperK, lowerK, nodes):
#   '''
#   Generate params for estimation
#   '''
#   param = pd.DataFrame({'r': [r]})
#   param['k'] = k                   # carry capacity (mt)
#   param['q'] = q                   # catchability coefficient q = Catch/(Hooks * Biomass)
#   param['price'] = price           # price 
#   param['cost'] = cost             # cost
#   param['alpha'] = alpha           # tech parameter
#   param['gamma'] = gamma           # pre-ITQ management parameter
#   param['y'] = y                   # system equivalence parameter
#   param['delta'] = delta           # discount rate
#   param['order'] = order           # Cheby polynomial order
#   param['upperK'] = param['k']     # upper K
#   param['lowerK'] = lowerK         # lower K
#   param['nodes'] = nodes           # number of Cheby poly nodes
#   return param



## functions from Fenichel & Abbott (2014)
#%%
# Effort function x(s) = ys^gamma
def effort(s, Z):
  return Z['y'][0] * s ** Z['gamma'][0]

# def effort(s, Z):
#   return Z['y'][0] * s

# Catch function (harvest) h(s, x) = q(y^alpha)(s^gamma * alpha)
def catch(s, Z):
  return Z['q'][0] * effort(s, Z) ** Z['alpha'][0] * s

# def catch(s, Z):
#   return Z['q'][0] * effort(s, Z) * s

# Profit function w(s, x) price * h(s, x) - cost * x(s)
def profit(s, Z):
  return Z['price'][0] * catch(s, Z) - Z['cost'][0] * effort(s, Z)

# Evaluated dst/dt (biological growth function)
def sdot(s, Z):
  return Z['r'][0] * s * (1 - s / Z['k'][0]) - catch(s, Z)

# # Evaluated dw/ds (derivate of profit function)
# def dwds(s, Z):
#   return (Z['gamma'][0] * Z['alpha'][0] + 1) * Z['price'][0] * Z['q'][0] * (Z['y'][0] ** Z['alpha'][0]) * (s ** (Z['gamma'][0] * Z['alpha'][0])) - Z['gamma'][0] * Z['cost'][0] * Z['y'][0] * (s ** (Z['gamma'][0] - 1))  

# # Evaluated (d/ds) * (dw/ds)
# def dwdss(s, Z):
#   return (Z['gamma'][0] * Z['alpha'][0] + 1) * Z['gamma'][0] * Z['alpha'][0] * Z['price'][0] * Z['q'][0] * (Z['y'][0] ** Z['alpha'][0]) * (s ** (Z['gamma'][0] * Z['alpha'][0] - 1)) - Z['gamma'][0] * (Z['gamma'][0] - 1) * Z['cost'][0] * Z['y'][0] * (s ** (Z['gamma'][0] - 2)) 

# # Evaluated dsdot/ds
# def dsdotds(s, Z):
#   return Z['r'][0] - 2 * Z['r'][0] * s / Z['k'][0] - (Z['gamma'][0] * Z['alpha'][0] + 1) * Z['q'][0] * (Z['y'][0] ** Z['alpha'][0]) * (s ** (Z['gamma'][0] * Z['alpha'][0]))

# # Evaluated (d/ds) * (dsdot/ds)
# def dsdotdss(s, Z):
#   return -2 * Z['r'][0] / Z['k'][0] - (Z['gamma'][0] * Z['alpha'][0] + 1) * Z['gamma'][0] * Z['alpha'][0] * Z['q'][0] * (Z['y'][0] ** Z['alpha'][0]) * (s ** ((Z['gamma'][0] * Z['alpha'][0] -1)))



#%%
# Big-eye tuna 
# WCPFC
bet_dat = pd.DataFrame({
  'species': 'bet',
  'year': [2010, 2011, 2012, 2013, 2014, 2015, 2016, 2017, 2018],
  'q': 0.1834659424,
  'k': [623121, 623121, 623121, 742967, 742967, 742967, 742967, 665441, 655441], 
  'price': [9127.13, 9193.27, 10846.73, 9171.22, 8311.42, 8862.57, 9259.40, 8179.14, 9479.87],
  'cost': [2.41, 2.86, 3.01, 2.75, 2.62, 2.01, 1.91, 1.76, 2.11],
  'msy': [76760, 76760, 76760, 108520, 108520, 108520, 108040, 159020, 159020]
  })


# Convert cost kg to mt
bet_dat = bet_dat.assign(cost = bet_dat['cost']*2204.62)

# def proc_vapprox(dat):
retdat = pd.DataFrame()
# for alpha_ in np.arange(0.25, 0.75, 0.05):
for year_ in range(2010, 2019):
  dat = bet_dat[bet_dat['year'] == year_]
  # dat = dat.assign(k = dat['k']*5)
  param = dat.reset_index(drop=True).copy()
  param['r'] = 0.201
  # param['alpha'] = 0.5436459179063678         # tech parameter
  # param['alpha'] = 0.2         # tech parameter
  param['alpha'] = 0.84         # tech parameter
  param['gamma'] = 0.74                   # pre-ITQ management parameter
  # param['y'] = 0.15745573410462155            # system equivalence parameter
  param['y'] = 0.00514            # system equivalence parameter
  param['delta'] = 0.03                       # discount rate
  param['order'] = 50                         # Cheby polynomial order
  param['upperK'] = param['k']*1.01                # upper K
  param['lowerK'] = param['k']*0.01           # lower K
  param['nodes'] = 500                        # number of Cheby poly nodes
  param['msy'] = dat['msy'].iat[0]
  
  # prepare capN
  Aspace = approxdef(param['order'],
                     param['lowerK'],
                     param['upperK'],
                     param['delta']) #defines the approximation space

  nodes = chebnodegen(param['nodes'],
                       param['lowerK'],
                       param['upperK']) #define the nodes

  # prepare for simulation
  simuDataV = pd.DataFrame({
    'nodes': nodes,
    'sdot': sdot(nodes, param), 
    'profit': profit(nodes, param)})

  # Calculate V-approximationg coefficients
  vC = vapprox(Aspace, simuDataV)  #the approximated coefficent vector for prices

  GOMSimV = vsim(vC,
    simuDataV.iloc[:, 0],
    profit(nodes, param))

  outdat = pd.DataFrame({
    'year': dat['year'].iat[0],
    'k': param['k'].iat[0],
    'nodes': nodes,
    'shadowp': GOMSimV['shadowp'].ravel(),
    'upperK': param['upperK'].iat[0],
    'msy': param['msy'].iat[0]})

  retdat = pd.concat([retdat, outdat])
  print(f"Complete: {dat['year'].iat[0]}")


retdat.to_csv('data/model_results.csv', index=False)







#%%
# Get changes in management with decreases in biomass
current_stock = 655441
stock_dat = pd.DataFrame()
for i in [0.25, 0.50, 0.75, 1.00, 1.25, 1.50, 1.75]:
  indat = pd.DataFrame({'prop': [i], 'stock': [current_stock*i]})
  stock_dat = pd.concat([stock_dat, indat]).reset_index(drop=True)
  

# def proc_vapprox(dat):
lst_ = []
for i in range(len(stock_dat)):
  dat = bet_dat[bet_dat['year'] == 2018]
  # dat = dat.assign(k = dat['k']*5)
  param = dat.reset_index(drop=True).copy()
  param['r'] = 0.201
  param['alpha'] = 0.84         # tech parameter
  param['gamma'] = 0.74                     # pre-ITQ management parameter
  param['y'] = 0.00514            # system equivalence parameter
  param['delta'] = 0.03                       # discount rate
  param['order'] = 50                         # Cheby polynomial order
  param['upperK'] = stock_dat.loc[i, 'stock']*1.01               # upper K
  param['lowerK'] = stock_dat.loc[i, 'stock']*0.01                  # lower K
  param['nodes'] = 500                        # number of Cheby poly nodes
  param['msy'] = stock_dat.loc[i, 'stock']/2
  param['perc'] = stock_dat.loc[i, 'prop']

  # prepare capN
  Aspace = approxdef(param['order'],
                     param['lowerK'],
                     param['upperK'],
                     param['delta']) #defines the approximation space

  nodes = chebnodegen(param['nodes'],
                       param['lowerK'],
                       param['upperK']) #define the nodes

  # prepare for simulation
  simuDataV = pd.DataFrame({
    'nodes': nodes,
    'sdot': sdot(nodes, param), 
    'profit': profit(nodes, param)})

  # Calculate V-approximationg coefficients
  vC = vapprox(Aspace, simuDataV)  #the approximated coefficent vector for prices

  GOMSimV = vsim(vC,
    simuDataV.iloc[:, 0],
    profit(nodes, param))

  indat = pd.DataFrame({
    'year': dat['year'].iat[0],
    'nodes': nodes,
    'shadowp': GOMSimV['shadowp'].ravel(),
    'upperK': param['upperK'].iat[0],
    'msy': param['msy'].iat[0],
    'perc': param['perc'].iat[0],
    'r': param['r'].iat[0]})

  lst_.append(indat)
  print(i)


stock_retdat = pd.concat(lst_)
stock_retdat.to_csv('data/stock_change_model_results.csv', index=False)





