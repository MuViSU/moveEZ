
library(devtools)
load_all()

library(biplotEZ) ; library(ggplot2) ; library(gganimate)
load("data/Africa_climate.rda")
Africa_climate$Year <- droplevels(Africa_climate$Year)
bp <- biplot(Africa_climate) |> PCA(group.aes = Africa_climate$Region)

|> moveplot()
