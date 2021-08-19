
import pandas as pd 

test = pd.read_csv('data/LONGLINE_WCPFC_5x5_grid_flag_year_month.csv')

test = test[['yy', 'mm', 'flag_id', 'bet_c', 'bet_n', 'hhooks']]

test = test[test['flag_id'] == 'US']

res = test.groupby('yy').sum()

res

#        mm     bet_c   bet_n
# yy
# 2012  649  4409.387  120506
# 2013  561  3875.900  112838
# 2014  636  4568.294  144833
# 2015  582  5295.965  141348
# 2016  619  5717.836  153474
# 2017  626  4928.621  143239
# 2018  730  4974.651  147463
# 2019  852  5664.003  160841

(res['hhooks']*100*1.10) / res['bet_c']

# Cost per metric ton
# yy
# 2012    101.716130
# 2013    104.962177
# 2014    100.563024
# 2015     93.595797
# 2016     99.142550
# 2017    111.425648
# 2018    117.624116
# 2019    127.491234
# dtype: float64

# Catchability coefficient
# q = Catch/(Effort * Biomass)

# Calc Catability Coefficient
# Catchability Coef = Catch / (effort or intensity -- hours or hooks -- * biomass)
res['bet_c'] / (res['hhooks']*100*569888)


# Calculate MSY
# H = Kr/4

(569888 * 0.3847) /4

# Variable Cost (2012): $320,790
# No. of hooks (2012): 18,086
# Cost per hook (2012): 320790/18086 = $17.74
(17.74*res['hhooks'])/res['bet_c']

# yy
# 2012    1640.403775
# 2013    1692.753647
# 2014    1621.807314
# 2015    1509.444941
# 2016    1598.898944
# 2017    1796.991822
# 2018    1896.956204
# 2019    2056.085896
# dtype: float64

# Metric tons to pounds = 1 = 2204.62 lbs
Revenue = 3*2204.62



