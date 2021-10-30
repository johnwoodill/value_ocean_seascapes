
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
r = 0.3847                              # intrinsick growth rate
param = pd.DataFrame({'r': [r]})

# Big-eye Tuna population estimates: 569,888 mt
# Minimum price: $8600/mt - $11000/mt
param['k'] = 1613855                # carry capacity (mt)
param['q'] = 0.0008                 # catchability coefficient q = Catch/(Hooks * Biomass)
param['price'] = 4.20*2204.62       # price 
param['cost'] = 1.91*2204.62        # cost

param['alpha'] = 0.5436459179063678         # tech parameter
param['gamma'] = 0.7882                     # pre-ITQ management parameter
param['y'] = 0.15745573410462155            # system equivalence parameter
param['delta'] = 0.03                       # discount rate

param['order'] = 50                         # Cheby polynomial order
param['upperK'] = param['k']                # upper K
param['lowerK'] = 5*10**6                    # lower K
param['nodes'] = 500                        # number of Cheby poly nodes
# ----------------------------------------------------

#%%
def gen_param(k, q, price, cost, alpha, gamma, y, delta, order, upperK, lowerK, nodes):
  '''
  Generate params for estimation
  '''
  param = pd.DataFrame({'r': [r]})
  param['k'] = k                   # carry capacity (mt)
  param['q'] = q                   # catchability coefficient q = Catch/(Hooks * Biomass)
  param['price'] = price           # price 
  param['cost'] = cost             # cost
  param['alpha'] = alpha           # tech parameter
  param['gamma'] = gamma           # pre-ITQ management parameter
  param['y'] = y                   # system equivalence parameter
  param['delta'] = delta           # discount rate
  param['order'] = order           # Cheby polynomial order
  param['upperK'] = param['k']     # upper K
  param['lowerK'] = lowerK         # lower K
  param['nodes'] = nodes           # number of Cheby poly nodes
  return param



## functions from Fenichel & Abbott (2014)
#%%
# Effort function x(s) = ys^gamma
def effort(s, Z):
  return Z['y'][0] * s ** Z['gamma'][0]

# Catch function (harvest) h(s, x) = q(y^alpha)(s^gamma * alpha)
def catch(s, Z):
  return Z['q'][0] * effort(s, Z) ** Z['alpha'][0] * s

# Profit function w(s, x) price * h(s, x) - cost * x(s)
# w(s, x) price * q(y^alpha)(s^gamma * alpha) - cost * ys^gamma
def bet_profit(s, Z):
  return Z['price'][0] * catch(s, Z) - Z['cost'][0] * effort(s, Z)

def yft_profit(s, Z):
  return Z['price'][0] * catch(s, Z) - Z['cost'][0] * effort(s, Z)

def swo_profit(s, Z):
  return Z['price'][0] * catch(s, Z) - Z['cost'][0] * effort(s, Z)

def profit(s, Z):
  return Z['price'][0] * catch(s, Z) - Z['cost'][0] * effort(s, Z)

# Evaluated dst/dt (biological growth function)
def sdot(s, Z):
  return Z['r'][0] * s * (1 - s / Z['k'][0]) - catch(s, Z)

# Evaluated dw/ds (derivate of profit function)
def dwds(s, Z):
  return (Z['gamma'][0] * Z['alpha'][0] + 1) * Z['price'][0] * Z['q'][0] * (Z['y'][0] ** Z['alpha'][0]) * (s ** (Z['gamma'][0] * Z['alpha'][0])) - Z['gamma'][0] * Z['cost'][0] * Z['y'][0] * (s ** (Z['gamma'][0] - 1))  

# Evaluated (d/ds) * (dw/ds)
def dwdss(s, Z):
  return (Z['gamma'][0] * Z['alpha'][0] + 1) * Z['gamma'][0] * Z['alpha'][0] * Z['price'][0] * Z['q'][0] * (Z['y'][0] ** Z['alpha'][0]) * (s ** (Z['gamma'][0] * Z['alpha'][0] - 1)) - Z['gamma'][0] * (Z['gamma'][0] - 1) * Z['cost'][0] * Z['y'][0] * (s ** (Z['gamma'][0] - 2)) 

# Evaluated dsdot/ds
def dsdotds(s, Z):
  return Z['r'][0] - 2 * Z['r'][0] * s / Z['k'][0] - (Z['gamma'][0] * Z['alpha'][0] + 1) * Z['q'][0] * (Z['y'][0] ** Z['alpha'][0]) * (s ** (Z['gamma'][0] * Z['alpha'][0]))

# Evaluated (d/ds) * (dsdot/ds)
def dsdotdss(s, Z):
  return -2 * Z['r'][0] / Z['k'][0] - (Z['gamma'][0] * Z['alpha'][0] + 1) * Z['gamma'][0] * Z['alpha'][0] * Z['q'][0] * (Z['y'][0] ** Z['alpha'][0]) * (s ** ((Z['gamma'][0] * Z['alpha'][0] -1)))



#%%
# Big-eye tuna 

bet_dat = pd.DataFrame({
  'species': 'bet',
  'year': [2010, 2011, 2012, 2013, 2014, 2015, 2016, 2017, 2018],
  'q': 0.3847,
  'k': [623121.00, 623121.00, 623121.00, 742967.00, 742967.00, 742967.00, 742967.00, 665441.00, 655441.00],
  'price': [9127.13, 9193.27, 1846.73, 9171.22, 8311.42, 8862.57, 9259.40, 8179.14, 9479.87],
  'cost': [2.41, 2.86, 3.01, 2.75, 2.62, 2.01, 1.91, 1.76, 2.11]
  })

# INCOMPLETE ----------------------------------
# bet_dat = pd.DataFrame({
#   'species': 'yft',
#   'year': [2010, 2011, 2012, 2013, 2014, 2015, 2016, 2017, 2018],
#   'q': 0.3847,
#   'k': [1881625.00, 1881625.00, 1881625.00, 1994655.00, 1994655.00, 1994655.00, 1994655.00, 1994655.00, 1994655.00],
#   'price': [7231.15, 5709.97, 8443.69, 9105.08, 8201.19, 6283.17, 6239.07, 5952.47, 8664.16],
#   'cost': [2.41, 2.86, 3.01, 2.75, 2.62, 2.01, 1.91, 1.76, 2.11]
#   })

# swo_dat = pd.DataFrame({
#   'species': 'swo',
#   'year': [2010, 2011, 2012, 2013, 2014, 2015, 2016, 2017, 2018],
#   'q': 0.3847,
#   'k': [1881625.00, 1881625.00, 1881625.00, 1994655.00, 1994655.00, 1994655.00, 1994655.00, 1994655.00, 1994655.00],
#   'price': [7231.15, 5709.97, 8443.69, 9105.08, 8201.19, 6283.17, 6239.07, 5952.47, 8664.16],
#   'cost': [2.41, 2.86, 3.01, 2.75, 2.62, 2.01, 1.91, 1.76, 2.11]
#   })
# INCOMPLETE ----------------------------------


# Convert cost to mt
bet_dat = bet_dat.assign(cost = bet_dat['cost']*2204.62)



def proc_vapprox(dat):

retdat = pd.DataFrame()
for year_ in range(2010, 2019):
  dat = bet_dat[bet_dat['year'] == year_]
  param = dat.reset_index(drop=True).copy()
  param['r'] = 0.3847
  param['alpha'] = 0.5436459179063678         # tech parameter
  param['gamma'] = 0.7882                     # pre-ITQ management parameter
  param['y'] = 0.15745573410462155            # system equivalence parameter
  param['delta'] = 0.03                       # discount rate
  param['order'] = 50                         # Cheby polynomial order
  param['upperK'] = param['k']                # upper K
  param['lowerK'] = param['k']*0.05                  # lower K
  param['nodes'] = 500                        # number of Cheby poly nodes

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
    'nodes': nodes,
    'shadowp': GOMSimV['shadowp'].ravel()})

  retdat = pd.concat([retdat, outdat])
  print(f"Complete: {dat['year'].iat[0]}")


retdat.to_csv('data/model_results.csv', index=False)

results = [proc_vapprox(dat = bet_dat.iloc[[i], :]) for i in range(len(bet_dat))]

outdat.to_csv("~/Downloads/test.csv", index=False)




pd.DataFrame(GOMSimV)









simuDataP = pd.DataFrame({
  'nodes': nodes, 
  'sdot': sdot(nodes, param), 
  'dsdotds': dsdotds(nodes, param),
  'dwds': dwds(nodes, param)})


simuDataPdot = pd.DataFrame({
  'nodes': nodes, 
  'sdot': sdot(nodes, param), 
  'dsdotds': dsdotds(nodes, param),
  'dsdotdss': dsdotdss(nodes, param),
  'dwds': dwds(nodes, param),
  'dwdss': dwdss(nodes, param)})


# Calculate V-approximationg coefficients
vC = vapprox(Aspace, simuDataV)  #the approximated coefficent vector for prices

pC = papprox(Aspace,
             simuDataP.iloc[:, 0],
             simuDataP.iloc[:, 1],
             simuDataP.iloc[:, 2],
             simuDataP.iloc[:, 3])  #the approximated coefficent vector for prices


pdotC = pdotapprox(Aspace,
             simuDataPdot.iloc[:, 0],
             simuDataPdot.iloc[:, 1],
             simuDataPdot.iloc[:, 2],
             simuDataPdot.iloc[:, 3],
             simuDataPdot.iloc[:, 4],
             simuDataPdot.iloc[:, 5])  #the approximated coefficent vector for prices


GOMSimV = vsim(vC,
  simuDataV.iloc[:, 0],
  profit(nodes, param))



GOMSimP = psim(pC,
                simuDataP.iloc[:, 0],
                profit(nodes, param),
                simuDataP.iloc[:, 1])


GOMSimPdot = pdotsim(pdotC,
                      simuDataPdot.iloc[:, 0],
                      simuDataPdot.iloc[:, 1],
                      simuDataPdot.iloc[:, 2],
                      profit(nodes,param),
                      simuDataPdot.iloc[:, 4])


# Plot shadow prices
#%%
fig, axs = plt.subplots(3)
fig.subplots_adjust(hspace=.5)
axs[0].plot(nodes, GOMSimV['shadowp'], color='blue');
axs[1].plot(nodes, GOMSimP['shadowp'], color='red');
axs[2].plot(nodes, GOMSimPdot['shadowp'], color='green');
axs[0].title.set_text('Value Approximation')
axs[1].title.set_text('Price Approximation')
axs[2].title.set_text('P-dot Approximation')
fig.supxlabel('Stock Size')
fig.supylabel('Shadow Price ($)')
plt.show()

#%%
fig = plt.figure()
ax = plt.axes()
# ax.ticklabel_format(useOffset=False)
ax.set_ylim([0, 8000])
ax.plot(nodes/1000, GOMSimV['shadowp'], color='blue');
fig.supxlabel('Stock Size (1k mt)')
fig.supylabel('Shadow Price ($)')
plt.ticklabel_format(style='plain')
plt.show()


#%%
fig = plt.figure()
ax = plt.axes()
# ax.ticklabel_format(useOffset=False)
ax.set_ylim([0, 2000])
ax.plot(nodes/1000, GOMSimV['shadowp'], color='blue');
fig.supxlabel('Stock Size (1k mt)')
fig.supylabel('Shadow Price ($)')
plt.ticklabel_format(style='plain')
plt.show()


