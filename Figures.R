library(tidyverse)
library(wesanderson)
library(sf)
library(cowplot)
library(ggnewscale)

setwd("~/Projects/value_ocean_seascapes/")

new_scale <- function(new_aes) {
   structure(ggplot2::standardise_aes_names(new_aes), class = "new_aes")
}

nipy_spectral <- c("#000000", "#6a009d", "#0035dd", "#00a4bb", "#009b0f",
                   "#00e100", "#ccf900", "#ffb000", "#e50000")

seascape_labels <- data.frame(seascape_class = seq(1, 33),
                              seascape_name = c("NORTH ATLANTIC SPRING, ACC TRANSITION",   
                                                "SUBPOLAR TRANSITION",
                                                "TROPICAL SUBTROPICAL TRANSITION",
                                                "Western Warm Pool Subtropical",  #4
                                                "Subtropical Gyre Transition",    #5
                                                "ACC, NUTRIENT STRESS",
                                                "TEMPERATE TRANSITION",
                                                "Indopacific Subtropical Gyre",   #8
                                                "EQUATORIAL TRANSITION",
                                                "HIGHLY OLIGOTROPHIC SUBTROPICAL GYRE",
                                                "TROPICAL/SUBTROPICAL UPWELLING",
                                                "SUBPOLAR",
                                                "SUBTROPICAL GYRE MESOSCALE INFLUENCED",
                                                "TEMPERATE BLOOMS UPWELLING",
                                                "TROPICAL SEAS",
                                                "MEDITTERANEAN RED SEA",
                                                "SUBTROPICAL TRANSITION \n LOW NUTRIENT STRESS",
                                                "MEDITTERANEAN RED SEA",
                                                "ARTIC/ SUBPOLAR SHELVES",
                                                "SUBTROPICAL, FRESH INFLUENCED COASTAL",
                                                "WARM, BLOOMS, HIGH NUTS",
                                                "ARCTIC LATE SUMMER",
                                                "FRESHWATER INFLUENCED POLAR SHELVES",
                                                "ANTARCTIC SHELVES",
                                                "ICE PACK",
                                                "ANTARCTIC ICE EDGE",
                                                "HYPERSALINE EUTROPHIC, \n PERSIAN GULF, RED SEA",
                                                "ARCTIC ICE EDGE","ANTARCTIC",
                                                "ICE EDGE  BLOOM",
                                                "1-30% ICE PRESENT",
                                                "30-80% MARGINAL ICE","PACK ICE"))

dat = read_csv("~/Projects/value_ocean_seascapes/data/wcpo_effort_seascape_2012_2019.csv")
dat = drop_na(dat, 'CLASS')

pdat <- dat %>% 
  group_by(year) %>% 
  mutate(bet_c_total = sum(bet_c),
         yft_c_total = sum(yft_c),
         swo_c_total = sum(swo_c),
         catch_total = sum(bet_c_total, yft_c_total, swo_c_total)) %>% 
  ungroup() %>% 
  group_by(year, CLASS) %>% 
  summarise(CLASS_N = n(), 
            bet_c_sea_total = sum(bet_c),
            bet_c_total = mean(bet_c_total),
            bet_c_sea_perc = (bet_c_sea_total/bet_c_total)*100,

            yft_c_sea_total = sum(yft_c),
            yft_c_total = mean(yft_c_total),
            yft_c_sea_perc = (yft_c_sea_total/yft_c_total)*100,

            swo_c_sea_total = sum(swo_c),
            swo_c_total = mean(swo_c_total),
            swo_c_sea_perc = (swo_c_sea_total/swo_c_total)*100,

            catch_c_sea_total = sum(bet_c_total, yft_c_total, swo_c_total),
            catch_c_total = mean(catch_total),
            catch_c_sea_perc = (catch_c_sea_total/catch_c_total)*100) %>% 
  ungroup() %>% 
  group_by(year) %>% 
  arrange(-CLASS_N) %>% 
  top_n(3, bet_c_sea_perc) %>% 
  mutate(bet_total_perc = sum(bet_c_sea_perc),
         yft_total_perc = sum(yft_c_sea_perc),
         swo_total_perc = sum(swo_c_sea_perc))

# Keep 4, 5, 8 Seascape classes (top 3)
pdat <- filter(pdat, CLASS %in% c(4, 5, 8))

View(filter(pdat, year == 2012))

unique(pdat$CLASS)

pdat %>% group_by(year) %>% top_n(3, bet_c_sea_perc) %>% summarise(total_perc = sum(bet_c_sea_perc))
                                                                   
pdat %>% group_by(year) %>% top_n(3, bet_c_sea_perc) %>% group_by(CLASS) %>% summarise()

pdat %>% group_by(year) %>% top_n(3, yft_c_sea_perc) %>% summarise(total_perc = sum(yft_c_sea_perc))

pdat %>% group_by(year) %>% top_n(3, yft_c_sea_perc) %>% group_by(CLASS) %>% summarise()

pdat %>% group_by(year) %>% top_n(3, swo_c_sea_perc) %>% summarise(total_perc = sum(swo_c_sea_perc))

pdat %>% group_by(year) %>% top_n(3, swo_c_sea_perc) %>% group_by(CLASS) %>% summarise()

pdat %>% group_by(year) %>% summarise(perc=sum(bet_c_sea_perc))

pdat %>% group_by(year) %>% summarise(perc=sum(yft_c_sea_perc))

pdat %>% group_by(year) %>% summarise(perc=sum(swo_c_sea_perc))

pdat$bet_c_sea_perc_label <- paste0(round(pdat$bet_c_sea_perc, 1), " %")
pdat$bet_total_perc_label <- paste0(round(pdat$bet_total_perc, 1), " %", "\n Total Effort")

pdat$yft_c_sea_perc_label <- paste0(round(pdat$yft_c_sea_perc, 1), " %")
pdat$yft_total_perc_label <- paste0(round(pdat$yft_total_perc, 1), " %", "\n Total Effort")

pdat$swo_c_sea_perc_label <- paste0(round(pdat$swo_c_sea_perc, 1), " %")
pdat$swo_total_perc_label <- paste0(round(pdat$swo_total_perc, 1), " %", "\n Total Effort")


pdat <- left_join(pdat, seascape_labels, by=c("CLASS" = "seascape_class"))

pdat

# year     bet_c
# 0  2012  4409.387
# 1  2013  3875.900
# 2  2014  4568.294
# 3  2015  5295.965
# 4  2016  5717.836
# 5  2017  4928.621
# 6  2018  4974.651
# 7  2019  5664.003

total_effort_label <- pdat %>% 
  group_by(year) %>% 
  arrange(-bet_c_sea_perc) %>% 
  summarise(bet_total_perc_label = first(bet_total_perc_label),
            bet_c_sea_total = first(bet_c_sea_total),

            yft_total_perc_label = first(yft_total_perc_label),
            yft_c_sea_total = first(yft_c_sea_total),
            
            swo_total_perc_label = first(swo_total_perc_label),
            swo_c_sea_total = first(swo_c_sea_total),
            seascape_name = first(seascape_name))

# -----------------------------------------------------------------------------
# Bigeye Tuna Percentage across top 3 seascapes
# Set limit
total_effort_label$bet_c_sea_total = 4700
total_effort_label

pal = rev(wes_palette("Darjeeling1", 3))

p1 <- ggplot(pdat, aes(year, bet_c_sea_total, group=seascape_name, fill=factor(seascape_name))) + 
  geom_bar(stat='identity') +
  theme_minimal(15) +
  geom_text(data=pdat, aes(label=bet_c_sea_perc_label), position = position_stack(vjust = 0.5)) +
  geom_text(data=total_effort_label, aes(label = bet_total_perc_label), fontface='bold') +
  labs(fill="Seascape", x=NULL, y="Bigeye Tuna Catch (metric-ton)", title="2012-2019 Western-Central Pacific Bigeye Tuna Catch") +
  scale_fill_manual(values = pal) +
  scale_x_continuous(breaks = seq(2012, 2019, 1), 
                     labels = c("2012", "2013", "2014", "2015", "2016", "2017", "2018", "2019")) +
  scale_y_continuous(breaks = seq(0, 5000, 500), limits = c(0, 5000)) +
  theme(legend.position = "none",
        plot.title = element_text(hjust = 0.5),
        panel.border = element_rect(colour = "black", fill=NA, size=1),
        legend.box.background = element_rect(colour = "black"),
        legend.title.align=0.5) +
  guides(fill = guide_legend(nrow = 1, title.position="top", title.hjust = 0.5)) +
  NULL

pdat %>% group_by(year, CLASS) %>% summarise(total = sum(bet_c_sea_perc))

p2 <- ggplot(pdat, aes(year, bet_c_sea_perc, group=seascape_name, color=seascape_name)) + 
  geom_line(size=1.25) + 
  geom_point(shape=15, size=2) +
  theme_minimal(16) +
  labs(color="Seascape", x=NULL, y="% Total Effort") +
  scale_x_continuous(breaks = seq(2012, 2019, 1),
                   labels = c("2012", "2013", "2014", "2015", "2016", "2017", "2018", "2019")) +
  scale_color_manual(values = pal) +
  scale_y_continuous(labels=function(x) paste0(x,"%"), breaks = seq(0, 80, 20), limits=c(0, 80)) +
  theme(legend.position = "bottom",
        plot.title = element_text(hjust = 0.5),
        panel.border = element_rect(colour = "black", fill=NA, size=1),
        legend.box.background = element_rect(colour = "black"),
        legend.title.align=0.5,
        legend.text=element_text(size=17),
        legend.title = element_text(size=17),
        legend.spacing.x = unit(0.25, 'cm'),
        legend.margin = margin(5, 17, 5, 17)) +   #(top, right, bottom, left)
  guides(color = guide_legend(nrow = 1, title.position="top", title.hjust = 0.5, override.aes = list(linetype=NULL, size=8))) +
  NULL

plot_grid(p1, p2, ncol=1, rel_heights = c(3, 1))

ggsave("figures/BET_effort_seascape_barchart.png", width=12, height=10)


# -----------------------------------------------------------------------------
# Yellowfin Tuna Percentage across top 3 seascapes
total_effort_label$yft_c_sea_total = 2000
total_effort_label

pal = rev(wes_palette("Darjeeling1", 3))

p1 <- ggplot(pdat, aes(year, yft_c_sea_total, group=seascape_name, fill=factor(seascape_name))) + 
  geom_bar(stat='identity') +
  theme_minimal(15) +
  geom_text(data=pdat, aes(label=yft_c_sea_perc_label), position = position_stack(vjust = 0.5)) +
  geom_text(data=total_effort_label, aes(label = yft_total_perc_label), fontface='bold') +
  labs(fill="Seascape", x=NULL, y="Yellowfin Tuna Catch (metric-ton)", title="2012-2019 Western-Central Pacific Yellowfin Tuna Catch") +
  scale_fill_manual(values = pal) +
  scale_x_continuous(breaks = seq(2012, 2019, 1), 
                     labels = c("2012", "2013", "2014", "2015", "2016", "2017", "2018", "2019")) +
  scale_y_continuous(breaks = seq(0, 2000, 500), limits = c(0, 2000)) +
  theme(legend.position = "none",
        plot.title = element_text(hjust = 0.5),
        panel.border = element_rect(colour = "black", fill=NA, size=1),
        legend.box.background = element_rect(colour = "black"),
        legend.title.align=0.5) +
  guides(fill = guide_legend(nrow = 1, title.position="top", title.hjust = 0.5)) +
  NULL

pdat %>% group_by(year, CLASS) %>% summarise(total = sum(yft_c_sea_perc))

p2 <- ggplot(pdat, aes(year, yft_c_sea_perc, group=seascape_name, color=seascape_name)) + 
  geom_line(size=1.25) + 
  geom_point(shape=15, size=2) +
  theme_minimal(16) +
  labs(color="Seascape", x=NULL, y="% Total Effort") +
  scale_x_continuous(breaks = seq(2012, 2019, 1),
                   labels = c("2012", "2013", "2014", "2015", "2016", "2017", "2018", "2019")) +
  scale_color_manual(values = pal) +
  scale_y_continuous(labels=function(x) paste0(x,"%"), breaks = seq(0, 80, 20), limits=c(0, 80)) +
  theme(legend.position = "bottom",
        plot.title = element_text(hjust = 0.5),
        panel.border = element_rect(colour = "black", fill=NA, size=1),
        legend.box.background = element_rect(colour = "black"),
        legend.title.align=0.5,
        legend.text=element_text(size=17),
        legend.title = element_text(size=17),
        legend.spacing.x = unit(0.25, 'cm'),
        legend.margin = margin(5, 17, 5, 17)) +   #(top, right, bottom, left)
  guides(color = guide_legend(nrow = 1, title.position="top", title.hjust = 0.5, override.aes = list(linetype=NULL, size=8))) +
  NULL

plot_grid(p1, p2, ncol=1, rel_heights = c(3, 1))

ggsave("figures/YFT_effort_seascape_barchart.png", width=12, height=10)






# -----------------------------------------------------------------------------
# Swordfish Percentage across top 3 seascapes
total_effort_label$swo_c_sea_total = 650
total_effort_label

pal = rev(wes_palette("Darjeeling1", 3))

p1 <- ggplot(pdat, aes(year, swo_c_sea_total, group=seascape_name, fill=factor(seascape_name))) + 
  geom_bar(stat='identity') +
  theme_minimal(15) +
  geom_text(data=pdat, aes(label=swo_c_sea_perc_label), position = position_stack(vjust = 0.5)) +
  geom_text(data=total_effort_label, aes(label = swo_total_perc_label), fontface='bold') +
  labs(fill="Seascape", x=NULL, y="Swordfish Catch (metric-ton)", title="2012-2019 Western-Central Pacific Swordfish Catch") +
  scale_fill_manual(values = pal) +
  scale_x_continuous(breaks = seq(2012, 2019, 1), 
                     labels = c("2012", "2013", "2014", "2015", "2016", "2017", "2018", "2019")) +
  scale_y_continuous(breaks = seq(0, 650, 100), limits = c(0, 650)) +
  theme(legend.position = "none",
        plot.title = element_text(hjust = 0.5),
        panel.border = element_rect(colour = "black", fill=NA, size=1),
        legend.box.background = element_rect(colour = "black"),
        legend.title.align=0.5) +
  guides(fill = guide_legend(nrow = 1, title.position="top", title.hjust = 0.5)) +
  NULL

pdat %>% group_by(year, CLASS) %>% summarise(total = sum(swo_c_sea_perc))

p2 <- ggplot(pdat, aes(year, swo_c_sea_perc, group=seascape_name, color=seascape_name)) + 
  geom_line(size=1.25) + 
  geom_point(shape=15, size=2) +
  theme_minimal(16) +
  labs(color="Seascape", x=NULL, y="% Total Effort") +
  scale_x_continuous(breaks = seq(2012, 2019, 1),
                   labels = c("2012", "2013", "2014", "2015", "2016", "2017", "2018", "2019")) +
  scale_color_manual(values = pal) +
  scale_y_continuous(labels=function(x) paste0(x,"%"), breaks = seq(0, 100, 20), limits=c(0, 100)) +
  theme(legend.position = "bottom",
        plot.title = element_text(hjust = 0.5),
        panel.border = element_rect(colour = "black", fill=NA, size=1),
        legend.box.background = element_rect(colour = "black"),
        legend.title.align=0.5,
        legend.text=element_text(size=17),
        legend.title = element_text(size=17),
        legend.spacing.x = unit(0.25, 'cm'),
        legend.margin = margin(5, 17, 5, 17)) +   #(top, right, bottom, left)
  guides(color = guide_legend(nrow = 1, title.position="top", title.hjust = 0.5, override.aes = list(linetype=NULL, size=8))) +
  NULL

plot_grid(p1, p2, ncol=1, rel_heights = c(3, 1))

ggsave("figures/SWO_effort_seascape_barchart.png", width=12, height=10)








# World polygons from the maps package
world_shp <- sf::st_as_sf(maps::map("world", wrap = c(0, 360), plot = FALSE, fill = TRUE))

# Load EEZ polygons
eezs <- read_sf("~/Projects/World-fishing-rich-diver-equit/data/World_EEZ_v11_20191118_HR_0_360/", layer = "eez_v11_0_360") %>% 
  filter(POL_TYPE == '200NM') # select the 200 nautical mile polygon layer

mpas <- read_sf('~/Projects/World-fishing-rich-diver-equit/data/mpa_shapefiles/vlmpa.shp')
mpas <- st_shift_longitude(mpas)

rfmos <- read_sf('~/Projects/World-fishing-rich-diver-equit/data/RFMO_shapefile/RFMO_coords.shp')

seascape = read_csv("data/seascapes/seascapes_MONTHLY_CLASS_PROB_2018.csv")
# seascapedat = filter(seascape, CLASS %in% c(4, 5, 8) & month == 10 & year == 2018)
seascapedat2 = filter(seascape, CLASS %in% c(4, 5, 8))
seascapedat2$lat_lon = paste0(seascapedat2$lat, "_", seascapedat2$lon)

# -----------------------------------------------------------------------------
# Map of Seascape class density
dat$lat_lon <- paste0(dat$lat, "_", dat$lon)

pndat <- dat %>% 
  filter(CLASS %in% c(4, 5, 8)) %>% 
  group_by(year, CLASS, lat_lon) %>% 
  summarise(lat = mean(lat),
            lon = mean(lon),
            bet_c_total = sum(bet_c),
            yft_c_total = sum(yft_c),
            swo_c_total = sum(swo_c),
            catch_total = sum(bet_c_total, yft_c_total, swo_c_total)) 


seascapedat3 <- seascapedat2 %>% 
  group_by(year, lat_lon, CLASS) %>% 
  summarise(lat = mean(lat),
            lon = mean(lon),
            CLASS_n = n()) 

pndat <- left_join(pndat, seascape_labels, by=c("CLASS" = "seascape_class"))

seascapedat3 <- left_join(seascapedat3, seascape_labels, by=c("CLASS" = "seascape_class"))

seascapedat4 = filter(seascapedat3, year == 2018 & ( (lon <= 210 & lat >= -10) | (lon <= 230 & lat < -10)))


ggplot() + 
  annotate("segment", x = 140, xend = 210, y = 50, yend = 50, colour = "black", linetype="dashed") +
  annotate("segment", x = 210, xend = 210, y = 50, yend = -10, colour = "black", linetype="dashed") +
  annotate("segment", x = 210, xend = 230, y = -10, yend = -10, colour = "black", linetype="dashed") +
  annotate("segment", x = 230, xend = 230, y = -10, yend = -60, colour = "black", linetype="dashed") +
  annotate("segment", x = 140, xend = 230, y = -60, yend = -60, colour = "black", linetype="dashed") +
  annotate("segment", x = 140, xend = 140, y = -60, yend = -35, colour = "black", linetype="dashed") +
  annotate("segment", x = 130, xend = 130, y = -20, yend = -8, colour = "black", linetype="dashed") +
  annotate("segment", x = 130, xend = 100, y = -8, yend = -8, colour = "black", linetype="dashed") +
  annotate("segment", x = 100, xend = 100, y = -8, yend = 50, colour = "black", linetype="dashed") +
  geom_contour_filled(data=seascapedat4, aes(lon, lat, z=(CLASS_n)), alpha=0.8, show.legend = FALSE) +
  scale_fill_viridis_d() + 
  new_scale_fill() +
  labs(x=NULL, y=NULL, fill="log(Catch)") +
  geom_tile(data = filter(pndat, year == 2018), aes(lon, lat, fill=log(catch_total)), inherit.aes = FALSE) +
  scale_fill_gradient2(low = "orange", high = "red", limits = c(0, 7), breaks = seq(0, 7, 1)) +
  theme_minimal(14) + 
  geom_sf(data = world_shp, fill = 'black', color = 'black',  size = 0.1, inherit.aes = FALSE)  +
  theme(panel.border = element_rect(colour = "black", fill=NA, size=1),
        legend.position = c(0.525, 0.24),
        legend.direction = "vertical",
        legend.title = element_blank()) +
  guides(fill=guide_colourbar(title.hjust = 0.5, barwidth = 0.5, barheight = 12, frame.colour = "black")) +
  coord_sf(ylim=c(-30, 50), xlim=c(120, 240)) +
  facet_wrap(~seascape_name, ncol=2)

ggsave("figures/Map_Seascape_class_density.png", width=10, height=6)
#





ggplot() +
  theme_minimal(14) + 
  labs(x=NULL, y=NULL) +
  annotate("segment", x = 140, xend = 210, y = 50, yend = 50, colour = "red") +
  annotate("segment", x = 210, xend = 210, y = 50, yend = -10, colour = "red") +
  annotate("segment", x = 210, xend = 230, y = -10, yend = -10, colour = "red") +
  annotate("segment", x = 230, xend = 230, y = -10, yend = -60, colour = "red") +
  annotate("segment", x = 140, xend = 230, y = -60, yend = -60, colour = "red") +
  annotate("segment", x = 140, xend = 140, y = -60, yend = -35, colour = "red") +
  annotate("segment", x = 130, xend = 130, y = -20, yend = -8, colour = "red") +
  annotate("segment", x = 130, xend = 100, y = -8, yend = -8, colour = "red") +
  annotate("segment", x = 100, xend = 100, y = -8, yend = 50, colour = "red") +
  geom_sf(data = world_shp, fill = 'black', color = 'black',  size = 0.1, inherit.aes = FALSE) +
  NULL

# -----------------------------------------------------------------------------





sdat <- dat %>% group_by(year) %>% mutate(total_catch = )

sdat = filter(dat, CLASS %in% c(4, 5, 8))


ggplot() +
  # geom_sf(data = eezs, color = 'grey', alpha = 0.5, fill = NA, size = 0.2) +
  # geom_hex(data = seascapedat, aes(lon, lat, fill=factor(CLASS)), alpha = 0.8) +
  # geom_bin2d(data = seascapedat, aes(lon, lat, fill=factor(CLASS)), alpha = 0.8) +
  geom_point(data = sdat, aes(lon, lat, color=log(1 + bet_c)), alpha = 0.8, shape=17, size=5) +
  geom_point(data = sdat, aes(lon, lat, color=log(1 + yft_c)), alpha = 0.8, shape=18, size=5) +
  geom_point(data = sdat, aes(lon, lat, color=log(1 + swo_c)), alpha = 0.8, shape=15, size=5) +
  geom_sf(data = world_shp, fill = 'black', color = 'black',  size = 0.1)  +
  # geom_sf(data = mpas, color = 'grey', alpha = 0.05, fill = NA, size = 0.1) +
  scale_fill_viridis_d(direction = -1) +
  coord_sf(xlim = c(120, 250), ylim = c(-40, 40), expand = FALSE) +
  # scale_color_gradientn(colors = nipy_spectral, limits = c(0, 6), breaks = seq(0, 6, 1)) +
  theme_minimal() +
  labs(x=NULL, y=NULL, fill=NULL) +
  # theme(plot.title = element_text(hjust = 0.5),
  #       legend.position = "right",
  #       legend.title.align=0.5,
  #       panel.spacing = unit(0.5, "lines"),
  #       panel.border = element_rect(colour = "black", fill=NA, size=.5)) +
  # guides(fill = guide_colorbar(title.position = "top", 
  #                            direction = "vertical",
  #                            frame.colour = "black",
  #                            barwidth = .5,
  #                            barheight = 17)) +
  NULL




# -----------------------------------------------------------------------------
# Map of Seascape class density
dat = as.data.frame(read_csv("~/Projects/value_ocean_seascapes/data/2018_seascape_proportions"))

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
  labs(x=NULL, y=NULL, fill=NULL, title="2018 Stock Capitalization Value of US Longline Bigeye Tuna \n ($1.52 trillon)") + 
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



# Map of Hawaii with fishing effort
ggplot(filter(pndat, year == 2018)) + 
  scale_fill_viridis_c() +
  new_scale_fill() +
  labs(x=NULL, y=NULL, fill="log(Catch)") +
  geom_tile(aes(lon, lat, fill=log(bet_c_total)), inherit.aes = FALSE) +
  # geom_text(aes(lon, lat, label=round(log(bet_c_total), 1)), inherit.aes = FALSE) +
  scale_fill_gradient2(low = "orange", high = "red", limits = c(0, 7), breaks = seq(0, 7, 1)) +
  theme_nothing(14) + 
  geom_sf(data = world_shp, fill = 'black', color = 'black',  size = 0.1, inherit.aes = FALSE)  +
  theme(panel.border = element_rect(colour = "white", fill=NA, size=1),
        legend.position ="none",
        legend.direction = "vertical",
        legend.title = element_blank()) +
  # guides(fill=guide_colourbar(title.hjust = 0.5, barwidth = 0.5, barheight = 12, frame.colour = "black")) +
  coord_sf(ylim=c(10, 30), xlim=c(185, 210)) +
  NULL

ggsave("~/Downloads/hawaii1.png", height=6, width=6)

