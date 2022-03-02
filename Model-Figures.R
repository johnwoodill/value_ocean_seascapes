library(tidyverse)




# https://www.fao.org/3/bi664e/bi664e.pdf
calc_msy <- function(r, K){
  return (0.405*r*K)
}


value_data = ddat
calc_value <- function(value_data){
  msy = unique(value_data$msy)
  est_price = approxfun(x = value_data$nodes, y = value_data$shadowp)
  est_stock = approxfun(x = value_data$shadowp, y = value_data$nodes)
  msy_value = est_price(msy)*msy
  return(c(msy_value, est_price(msy)))
}




setwd("~/Projects/value_ocean_seascapes/")


# ----------------------------------------------------
# Get changes in upper K and msy
# mdat = data.frame(max_y = c(76760.00, 76760.00, 76760.00, 108520.00, 108520.00, 108520.00, 108040.00, 159020.00, 159020.00),
#                   stock_a = c(623121.00, 623121.00, 623121.00, 742967.00, 742967.00, 742967.00, 742967.00, 665441.00, 655441.00),
#                   stock_b = c(1432000.00, 1432000.00, 1432000.00, 2228600.00, 1613855.00, 1613855.00, 1763000.00, 1858775.00, 1858775.00),
#                   year = c(2010, 2011, 2012, 2013, 2014, 2015, 2016, 2017, 2018))
# 
# 
# mdat$max_y/mdat$stock_b
# 
# 
# mdat <- filter(mdat, year != 2013)
# 
# ggplot(mdat, aes(year, stock_b)) + geom_line()
# 
# mod = lm(max_y ~ stock_b + year, data = mdat)
# summary(mod)
# 
# predict(mod) + residuals(mod)
# 
# ggplot(mdat, aes(stock_b, max_y)) + geom_line() + geom_line(data=NULL, aes(stock_b, predict(mod)), color='red') + theme_minimal()
# 
# 
# outdat = data.frame()
# for (i in seq(0.50, 1, 0.01)){
#   test_dat = data.frame(stock_b = 1858775.00*i, year = 2018)
#   indat = data.frame(perc = i, stock_b = 1858775*i, year = 2018, max_y = (predict(mod, test_dat) + last(residuals(mod))))
#   outdat = rbind(outdat, indat)
#   
# }
# 
# ggplot(outdat, aes(stock_b, max_y)) + geom_line()
# 
# write_csv(outdat, "data/est_biomass_msy.csv")

# ----------------------------------------------------





# ----------------------------------------------------
# Price Curve for 2018
dat = read_csv("data/model_results.csv")

ddat = filter(dat, year == 2018)

est_price = approxfun(x = ddat$nodes, y = ddat$shadowp)
est_stock = approxfun(x = ddat$shadowp, y = ddat$nodes)

price = est_price(159020.00)
stock = 159020.00
price

ggplot(ddat, aes(nodes, shadowp)) + 
  geom_line(color="blue", size=2) + 
  theme_minimal(20) +
  labs(x="Stock Size (mt)", y="Natural Capital Price") +
  # MSY
  theme(panel.border = element_rect(colour = "black", fill=NA, size=1)) +
  geom_point(aes(x=stock, y=price), size=3) +
  annotate("text", x=stock + 200000, y=price + 100, label="2018 BET \n Calibration Stock", size=6) +
  annotate("text", x=159020 + 200000, y=price, label=paste("$", round(price, 2)), size=5) +
  annotate("text", x=159020 + 120000, y=9450, label=paste0(stock, " mt"), size=5) +
  
  annotate("segment", x=stock, xend=stock, yend=9400, y=price, linetype="dashed") +
  annotate("segment", x=0, xend=stock, y=price, yend=price, linetype="dashed") +
  scale_x_continuous(expand=c(0, 0)) +
  scale_y_continuous(expand=c(0, 0), limits=c(9400, 10200)) +
  NULL

ggsave("~/Downloads/price_curve.png", width=8, height=6)




# ----------------------------------------------------
# Get changes value time
dat = read_csv("data/model_results.csv")

outdat = data.frame()

for (year_ in unique(dat$year)){
  ddat = dplyr::filter(dat, year == year_)
  vals = calc_value(ddat)[1]
  price = calc_value(ddat)[2]
  indat = data.frame("year" = year_, "msy_val" = vals, "price" = price)
  outdat = rbind(outdat, indat)
}


outdat = outdat %>% group_by(year) %>% summarise(min_val = min(msy_val),
                                                 max_val = max(msy_val),
                                                 mean_val = mean(msy_val)) %>% 
  as.data.frame()

ggplot(outdat, aes(factor(year), mean_val/1000000000, group=factor(year))) + 
  geom_bar(stat='identity') +
  # geom_line(group=1) +
  geom_text(aes(label=paste0("$", round(mean_val/1000000000, 2), "b")), nudge_y = .15, size=5) + 
  theme_minimal(15) +
  labs(x=NULL, y="Estimated Valuation \n ($ billion)") +
  theme(panel.border = element_rect(colour = "black", fill=NA, size=1)) + 
  # scale_x_continuous(breaks = seq(0, 8, 1)) +
  ylim(0, 2) +
  NULL

#
ggsave("~/Downloads/value_bars.png", width=10, height=6)




# ----------------------------------------------------
cc_dat = read_csv('data/climate_change_model_results.csv')
# cc_dat = filter(cc_dat, perc %in% c(1, 0.5))

ggplot(cc_dat, aes(nodes, shadowp, color=(perc))) + 
  geom_line()

# test = filter(cc_dat, perc == 0.5)
# unique(test$msy)

# ----------------------------------------------------
# Get change in value at MSY
outdat = data.frame()
for (perc_ in unique(cc_dat$perc)){
  print(perc_)
  ddat = dplyr::filter(cc_dat, perc == perc_)
  vals = calc_value(ddat)[1]
  price = calc_value(ddat)[2]
  indat = data.frame("perc" = perc_, "msy_val" = vals, "price" = price)
  outdat = rbind(outdat, indat)
}

baseline_val = 42225348
outdat = outdat %>% arrange(-perc) %>% mutate(val_change = (msy_val - first(msy_val)) / first(msy_val),
                                            price_change = (price - first(price)) / first(price),
                                            diff_base = round((msy_val - baseline_val)/1000000, 2))

outdat


outdat$group <- 1
outdat$group <- ifelse(outdat$perc >= 0.9, "100-90%", outdat$group)
outdat$group <- ifelse(outdat$perc >= 0.8, ifelse(outdat$perc < 0.9, "90-80%", outdat$group), outdat$group)
outdat$group <- ifelse(outdat$perc >= 0.7, ifelse(outdat$perc < 0.8, "80-70%", outdat$group), outdat$group)
outdat$group <- ifelse(outdat$perc >= 0.6, ifelse(outdat$perc < 0.7, "70-60%", outdat$group), outdat$group)
outdat$group <- ifelse(outdat$perc >= 0.5, ifelse(outdat$perc < 0.6, "60-50%", outdat$group), outdat$group)

outdat$group <- factor(outdat$group, levels = c("100-90%", "90-80%", "80-70%", "70-60%", "60-50%"))

diff_labels = outdat %>% group_by(group) %>% summarise(diff_base_label = round(mean(diff_base), 2),
                                                       val_change = mean(val_change))

diff_labels$diff_base_label = paste0("$", diff_labels$diff_base_label, "m")

ggplot(outdat, aes(x=group, val_change, group=factor(group))) + 
  # geom_tufteboxplot() +
  geom_boxplot(width=.4) +
  geom_text(data = diff_labels, aes(group, val_change, group=factor(group), label=diff_base_label), 
            inherit.aes = FALSE, nudge_x=.4, color="blue") +
  theme_minimal(16) +
  labs(x="Change in Stock Assesstment", y="% Change in Valuation") +
  theme(panel.border = element_rect(colour = "black", fill=NA, size=1)) + 
  NULL




# -----------------------------------------------------------------------------
# Map of Seascape class density
dat = as.data.frame(read_csv("~/Projects/value_ocean_seascapes/data/2018_seascape_proportions.csv"))

eezs <- read_sf("~/Projects/World-fishing-rich-diver-equit/data/World_EEZ_v11_20191118_HR_0_360/", layer = "eez_v11_0_360") %>% 
  filter(POL_TYPE == '200NM') # select the 200 nautical mile polygon layer

mpas <- read_sf('~/Projects/World-fishing-rich-diver-equit/data/mpa_shapefiles/vlmpa.shp')
mpas <- st_shift_longitude(mpas)

dat$dist_prop = (dat$prop*9558.14*159020)/1000

1519935423

ggplot(dat, aes(lon, lat, fill=dist_prop)) + 
  geom_tile(alpha=0.95) + 
  # geom_sf(data=eezs, color="grey", fill=NA, inherit.aes = FALSE) +
  geom_sf(data = world_shp, fill = 'black', color = 'black',  size = 0.1, inherit.aes = FALSE)  +
  scale_fill_viridis_c(limits = c(0, 600), breaks = seq(0, 600, 100), labels=paste0("$", seq(0, 600, 100), "k")) +
  annotate("segment", x = 140, xend = 210, y = 50, yend = 50, colour = "black") +
  annotate("segment", x = 210, xend = 210, y = 50, yend = -10, colour = "black") +
  annotate("segment", x = 210, xend = 230, y = -10, yend = -10, colour = "black") +
  annotate("segment", x = 230, xend = 230, y = -10, yend = -60, colour = "black") +
  annotate("segment", x = 140, xend = 230, y = -60, yend = -60, colour = "black") +
  annotate("segment", x = 140, xend = 140, y = -60, yend = -35, colour = "black") +
  annotate("segment", x = 130, xend = 130, y = -20, yend = -8, colour = "black") +
  annotate("segment", x = 130, xend = 100, y = -8, yend = -8, colour = "black") +
  annotate("segment", x = 100, xend = 100, y = -8, yend = 50, colour = "black") +
  coord_sf(xlim=c(100, 230), ylim=c(-60, 55), expand = FALSE) +
  theme_minimal() +
  labs(x=NULL, y=NULL, fill=NULL, title="2018 Stock Capitalization Value of US Longline Bigeye Tuna \n ($1.55 billon)") + 
  theme(legend.title = element_text("asdf"),
        legend.position = "right",
        plot.title = element_text(hjust = 0.5),
                panel.spacing = unit(0.5, "lines"),
        panel.border = element_rect(colour = "black", fill=NA, size=.5)) +
  guides(fill = guide_colorbar(title.position = "top", 
                             direction = "vertical",
                             frame.colour = "black",
                             barwidth = .75,
                             barheight = 20)) +
  NULL

ggsave("~/Projects/value_ocean_seascapes/figures/map_total_value_us_big.png", width=6, height=5)



# Climate change
price = est_price(159020.00*.75)
stock = 159020.00*.75
value = price*stock

dat$dist_prop_cc = (dat$prop*price*stock)/1000
dat$diff = dat$dist_prop_cc - dat$dist_prop

ggplot(dplyr::filter(dat, diff < 0), aes(lon, lat, fill=diff)) + 
  geom_tile(alpha=0.95) + 
  # geom_sf(data=eezs, color="grey", fill=NA, inherit.aes = FALSE) +
  geom_sf(data = world_shp, fill = 'black', color = 'black',  size = 0.1, inherit.aes = FALSE)  +
  scale_fill_viridis_c(limits = c(-130, 0), breaks = seq(-130, 0, 10), labels=paste0("$", seq(-130, 0, 10), "k"), 
                       direction = -1, option = "plasma") +
  annotate("segment", x = 140, xend = 210, y = 50, yend = 50, colour = "black") +
  annotate("segment", x = 210, xend = 210, y = 50, yend = -10, colour = "black") +
  annotate("segment", x = 210, xend = 230, y = -10, yend = -10, colour = "black") +
  annotate("segment", x = 230, xend = 230, y = -10, yend = -60, colour = "black") +
  annotate("segment", x = 140, xend = 230, y = -60, yend = -60, colour = "black") +
  annotate("segment", x = 140, xend = 140, y = -60, yend = -35, colour = "black") +
  annotate("segment", x = 130, xend = 130, y = -20, yend = -8, colour = "black") +
  annotate("segment", x = 130, xend = 100, y = -8, yend = -8, colour = "black") +
  annotate("segment", x = 100, xend = 100, y = -8, yend = 50, colour = "black") +
  coord_sf(xlim=c(100, 230), ylim=c(-60, 55), expand = FALSE) +
  theme_minimal() +
  labs(x=NULL, y=NULL, fill=NULL, title="Stock Capitalization Value Loss from Climate Change \n ($1.17 billion -- loss of $380 million)") + 
  theme(legend.title = element_text("asdf"),
        legend.position = "right",
        plot.title = element_text(hjust = 0.5),
                panel.spacing = unit(0.5, "lines"),
        panel.border = element_rect(colour = "black", fill=NA, size=.5)) +
  guides(fill = guide_colorbar(title.position = "top", 
                             direction = "vertical",
                             frame.colour = "black",
                             barwidth = .75,
                             barheight = 20)) +
  NULL

ggsave("~/Projects/value_ocean_seascapes/figures/cc_map_total_value_us_big.png", width=6, height=5)

