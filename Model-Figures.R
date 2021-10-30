library(tidyverse)
dat = read_csv("~/Downloads/test.csv")

est_price = approxfun(x = dat$nodes, y = dat$shadowp)
est_
func(76760.00)

ggplot(dat, aes(nodes, shadowp)) + 
  geom_line() + 
  theme_minimal() +
  # geom_vline(xintercept = 108520) + 
  
  # MSY
  annotate("segment", x=76760, xend=76760, yend=func(76760.00), y=9100) +
  annotate("segment", x=0, xend=76760, y=func(76760.00), yend=func(76760.00)) +
  geom_point(aes(x=76760, y=func(76760.00))) +
  annotate("text", x=97760, y=func(76760)+25, label="MSY") +
  
  # Annual Price
  annotate("segment", x=76760, xend=76760, yend=func(76760.00), y=9100) +
  annotate("segment", x=0, xend=76760, y=func(76760.00), yend=func(76760.00)) +
  geom_point(aes(x=76760, y=func(76760.00))) +
  annotate("text", x=97760, y=func(76760)+25, label="MSY") +
  
  ylim(9100, 9650) +
  NULL


