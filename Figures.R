library(tidyverse)
library(wesanderson)

setwd("~/Projects/value_ocean_seascapes/")

seascape_labels <- data.frame(seascape_class = seq(1, 33),
                              seascape_name = c("NORTH ATLANTIC SPRING, ACC TRANSITION",
                                                "SUBPOLAR TRANSITION",
                                                "TROPICAL SUBTROPICAL TRANSITION",
                                                "Western Warm Pool Subtropical",
                                                "Subtropical Gyre Transition",
                                                "ACC, NUTRIENT STRESS",
                                                "TEMPERATE TRANSITION",
                                                "Indopacific Subtropical Gyre",
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
  mutate(bet_c_total = sum(bet_c)) %>% 
  ungroup() %>% 
  group_by(year, CLASS) %>% 
  summarise(CLASS_N = n(), 
            bet_c_sea_total = sum(bet_c),
            bet_c_total = mean(bet_c_total),
            bet_c_sea_perc = (bet_c_sea_total/bet_c_total)*100) %>% 
  ungroup() %>% 
group_by(year) %>% 
  top_n(3, bet_c_sea_perc) %>% 
  mutate(total_perc = sum(bet_c_sea_perc))

pdat %>% group_by(year) %>% top_n(3, bet_c_sea_perc) %>% summarise(total_perc = sum(bet_c_sea_perc))

pdat %>% group_by(year) %>% summarise(perc=sum(bet_c_sea_perc))

pdat$bet_c_sea_perc_label <- paste0(round(pdat$bet_c_sea_perc, 1), " %")
pdat$total_perc_label <- paste0(round(pdat$total_perc, 1), " %", "\n Total Effort")

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

total_effort_label <- pdat %>% group_by(year) %>% arrange(-bet_c_sea_perc) %>% 
  summarise(total_perc_label = first(total_perc_label),
            bet_c_sea_total = first(bet_c_sea_total),
            seascape_name = first(seascape_name))
total_effort_label$bet_c_sea_total = 4700
total_effort_label

pal = rev(wes_palette("Darjeeling1", 3))

p1 <- ggplot(pdat, aes(year, bet_c_sea_total, group=seascape_name, fill=factor(seascape_name))) + 
  geom_bar(stat='identity') +
  theme_minimal(15) +
  geom_text(data=pdat, aes(label=bet_c_sea_perc_label), position = position_stack(vjust = 0.5)) +
  geom_text(data=total_effort_label, aes(label = total_perc_label), fontface='bold') +
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

ggsave("figures/effort_seascape_barchart.png", width=12, height=10)

