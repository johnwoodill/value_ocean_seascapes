library(tidyverse)




# https://www.fao.org/3/bi664e/bi664e.pdf
calc_msy <- function(r, K){
  return (0.405*r*K)
}


value_data = ddat
calc_value <- function(value_data){
  est_price = approxfun(x = value_data$nodes, y = value_data$shadowp)
  est_stock = approxfun(x = value_data$shadowp, y = value_data$nodes)
  price = est_price(unique(value_data$k))
  stock = unique(value_data$k)
  value = price*stock
  return(c(price, stock, value))
}




setwd("~/Projects/value_ocean_seascapes/")


# ------------------------------------------------------------------------------
# Price Curve for 2018
{
dat = as.data.frame(read_csv("data/model_results.csv"))

ddat = filter(dat, year == 2018)

est_price = approxfun(x = ddat$nodes, y = ddat$shadowp)
est_stock = approxfun(x = ddat$shadowp, y = ddat$nodes)

msy_price = est_price(159020.00)
msy_stock = 159020.00

fstock_price = est_price(655441)
fstock_stock = 655441


ggplot(ddat, aes(nodes, shadowp)) + 
  # geom_line(color="blue", size=2) + 
  geom_line(size=1) +
  theme_minimal(13) +
  labs(x="Stock Size (mt)", y="Natural Capital Price") +
  
  # MSY
  theme(panel.border = element_rect(colour = "black", fill=NA, size=1)) +
  geom_point(aes(x=msy_stock, y=msy_price), size=3) +
  annotate("text", x=msy_stock + 2000, y=msy_price + 600, label="2018 MSY", size=5) +
  annotate("text", x=msy_stock + 2000, y=msy_price + 400, label=paste("$", round(msy_price, 2)), size=4) +
  annotate("text", x=msy_stock + 2000, y=msy_price + 200, label=paste0(msy_stock, " mt"), size=4) +
  annotate("text", x=msy_stock + 2000, y=msy_price + 200, label=paste0(msy_stock, " mt"), size=4) +

  annotate("segment", x=msy_stock, xend=msy_stock, yend=fstock_price - 500, y=msy_price, linetype="dashed") +   # Vertical line
  annotate("segment", x=0, xend=msy_stock, y=msy_price, yend=msy_price, linetype="dashed") +      # Horizontal line
  
  # Full Stock
  theme(panel.border = element_rect(colour = "black", fill=NA, size=1)) +
  geom_point(aes(x=fstock_stock, y=fstock_price), size=3) +
  annotate("text", x=fstock_stock - 30000, y=fstock_price + 700, label="2018 Total \n Stock", size=5) +
  annotate("text", x=fstock_stock - 25000, y=fstock_price + 400, label=paste("$", round(fstock_price, 2)), size=4) +
  annotate("text", x=fstock_stock - 25000, y=fstock_price + 200, label=paste0(fstock_stock, " mt"), size=4) +
  annotate("text", x=fstock_stock - 25000, y=fstock_price + 200, label=paste0(fstock_stock, " mt"), size=4) +
  
  annotate("segment", x=fstock_stock, xend=fstock_stock, yend=fstock_price - 500, y=fstock_price, linetype="dashed") +   # Vertical line
  annotate("segment", x=0, xend=fstock_stock, y=fstock_price, yend=fstock_price, linetype="dashed") +      # Horizontal line
  
  scale_x_continuous(expand=c(0, 0), limits=c(0, fstock_stock + 10000), labels=scales::comma, breaks=seq(0, 655441+1000, 100000)) +
  scale_y_continuous(expand=c(0, 0), limits=c(fstock_price - 500, fstock_price + 2000)) +
  NULL
}

ggsave("figures/Figure-1-Price-Curve.jpg", width=10, height=6)




# ------------------------------------------------------------------------------
# Get changes value time
dat = read_csv("data/model_results.csv")

outdat = data.frame()
for (year_ in unique(dat$year)){
  ddat = dplyr::filter(dat, year == year_)
  price = calc_value(ddat)[1]
  stock = calc_value(ddat)[2]
  value = calc_value(ddat)[3]
  indat = data.frame("year" = year_, "value" = value, "price" = price)
  outdat = rbind(outdat, indat)
}


ggplot(outdat, aes(factor(year), value/1000000000, group=factor(year))) + 
  geom_bar(stat='identity') +
  # geom_line(group=1) +
  geom_text(aes(label=paste0("$", round(value/1000000000, 2), "b")), nudge_y = .15, size=5) + 
  theme_minimal(15) +
  labs(x=NULL, y="Estimated Valuation \n ($ billion)") +
  theme(panel.border = element_rect(colour = "black", fill=NA, size=1)) + 
  # scale_x_continuous(breaks = seq(0, 8, 1)) +
  scale_y_continuous(breaks = seq(0, 10), limits=c(0, 10)) +
  NULL

#
ggsave("figures/Figure-2-Value-across-years.jpg", width=10, height=6)





# ----------------------------------------------------------------- 
# Figure - time series of prices
dat = as.data.frame(read_csv("data/model_results.csv"))
year_ = "2012"

outdat = data.frame()
for (year_ in unique(dat$year)){
  ddat = filter(dat, year == year_)
  
  stock = unique(ddat$k)
  msy = unique(ddat$msy)
  
  est_price = approxfun(x = ddat$nodes, y = ddat$shadowp)
  est_stock = approxfun(x = ddat$shadowp, y = ddat$nodes)
  
  msy_price = est_price(msy)
  fstock_price = est_price(stock)
  indat = data.frame(year = year_, stock = stock, msy = msy, msy_price = msy_price, fstock_price = fstock_price)
  outdat = rbind(outdat, indat)
}

range(outdat$fstock_price)

outdat = outdat %>% select(year, msy_price, fstock_price) %>% gather(key = var, value = value, -year)

outdat$var = factor(outdat$var, levels = c("msy_price", "fstock_price"), labels = c("MSY Price", "Total Stock Price"))
outdat$var

ggplot(outdat, aes(year, value, linetype=var)) + 
  geom_line() +
  theme_minimal(14) +
  theme(panel.border = element_rect(colour = "grey", fill=NA, size=1),
        legend.position = "none") +
  labs(x=NULL, y="Natural Capital Price") +
  annotate("text", x=2013, y=12000, label="MSY Price") +
  annotate("text", x=2012.5, y=9000, label="Stock Price") +
  scale_x_continuous(breaks = seq(2010, 2018)) +
  NULL

ggsave("figures/Figure-3-Natural-Capital-Price-Timeseries.jpg", width=10, height=6)




# ------------------------------------------------------------------------------
# Decline in stock change
dat = read_csv("data/stock_change_model_results.csv")


rdat = data.frame()
for (perc_ in c(0.50, 0.75, 1.00, 1.25, 1.50)){
  print(perc_)
  mdat = filter(dat, perc == as.character(perc_))
  
  est_price = approxfun(x = mdat$nodes, y = mdat$shadowp)
  est_stock = approxfun(x = mdat$shadowp, y = mdat$nodes)
  
  price = est_price(655441*perc_)
  stock = 655441*perc_
  cap_ex = price*stock
  
  indat = data.frame(perc = perc_,
                     est_price = price,
                     stock = stock,
                     cap_ex = cap_ex)
  
  rdat = rbind(rdat, indat)
}
rdat


baseline_cap_ex = filter(rdat, perc == 1.00)$cap_ex
rdat$perc_from_baseline = (rdat$cap_ex - baseline_cap_ex) / baseline_cap_ex

rdat$perc = factor(rdat$perc, levels = c(0.5, 0.75, 1, 1.25, 1.50), labels=c("-50%", "-25%", "2018 Baseline", "+25%", "+50%"))

ggplot(rdat, aes(factor(perc), cap_ex/1000000000)) + 
  theme_minimal(14) + 
  geom_bar(stat='identity') +
  labs(x="Change from baseline stock", y="Total Capital Expenditure ($ Billion)") +
  theme(panel.border = element_rect(colour = "grey", fill=NA, size=1)) +
  geom_text(aes(label=paste0("$", round(cap_ex/1000000000, 2), "b")), nudge_y = .35, size=5) + 
  NULL


ggsave("figures/Figure-3-Change-from-baseline.jpg", width=10, height=6)



# Sensitivity around years

dat = read_csv("data/model_results.csv")

outdat = data.frame()
for (year_ in unique(dat$year)){
  ddat = filter(dat, year == year_)
  stock = unique(ddat$k)
  msy = unique(ddat$msy)
  
  est_price = approxfun(x = ddat$nodes, y = ddat$shadowp)
  est_stock = approxfun(x = ddat$shadowp, y = ddat$nodes)
  
  msy_price = est_price(msy)
  fstock_price = est_price(stock)
  indat = data.frame(year = year_, stock = stock, msy = msy, msy_price = msy_price, fstock_price = fstock_price)
  outdat = rbind(outdat, indat)
  
}

ggplot(dat, aes(nodes, shadowp)) + 
  geom_point(data=outdat, aes(stock, fstock_price)) +
  geom_point(data=outdat, aes(msy, msy_price)) +
  geom_text(data=outdat, aes(msy, msy_price, label=paste0("MSY \n $", round(msy_price, 0))), inherit.aes = FALSE, nudge_x = 100000, nudge_y=1000) +
  geom_text(data=outdat, aes(stock, fstock_price, label=paste0("Stock \n $", round(fstock_price, 0))), inherit.aes = FALSE, nudge_x=-30000, nudge_y = 1000) +
  geom_line(size=1) +
  theme_minimal(13) +
  theme(panel.border = element_rect(colour = "grey", fill=NA, size=1)) +
  labs(x="Stock Size (mt)", y="Natural Capital Asset Price") +
  xlim(0, 750000) +
  ylim(8000, 14000) +
  facet_wrap(~year)

ggsave("figures/Figure-4-Annual-price-curves.jpg", width=10, height=8)

#



# ---- NOT WORKING
# Aggregate results

ddat = as.data.frame(read_csv("data/agg_model_results.csv"))

est_price = approxfun(x = ddat$nodes, y = ddat$shadowp)
est_stock = approxfun(x = ddat$shadowp, y = ddat$nodes)

price = est_price(unique(ddat$upperK))
stock = unique(ddat$upperK)

price
stock

ggplot(ddat, aes(nodes, shadowp)) + 
  geom_line(color="blue", size=2) +
  # geom_line(size=1) +
  theme_minimal(13) +
  labs(x="Stock Size (mt)", y="Natural Capital Price") +
  # MSY
  theme(panel.border = element_rect(colour = "black", fill=NA, size=1)) +
  geom_point(aes(x=stock, y=price), size=3, color='red') +
  annotate("text", x=stock + 2000, y=price + 700, label="2018 BET \n Stock", size=5) +
  annotate("text", x=stock + 2000, y=price + 400, label=paste("$", round(price, 2)), size=4) +
  annotate("text", x=stock + 2000, y=price + 200, label=paste0(stock, " mt"), size=4) +
  annotate("text", x=stock + 2000, y=price + 200, label=paste0(stock, " mt"), size=4) +
  
  # 9479.87
  
  annotate("segment", x=stock, xend=stock, yend=price - 500, y=price, linetype="dashed") +   # Vertical line
  annotate("segment", x=0, xend=stock, y=price, yend=price, linetype="dashed") +      # Horizontal line
  scale_x_continuous(expand=c(0, 0), limits=c(0, stock + 100000)) +
  scale_y_continuous(expand=c(0, 0), limits=c(price - 100, price + 2000)) +
  NULL

  #











# ----------------------------------------------------------------
# Climate change results ---- not in use

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

