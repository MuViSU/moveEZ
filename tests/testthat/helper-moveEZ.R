# moveplot(), moveplot2() and moveplot3() print their plot, keep it off disk
no_plot <- function(expr)
{
  grDevices::pdf(NULL)
  on.exit(grDevices::dev.off())
  force(expr)
}

# geom of each layer of a ggplot
geoms <- function(p) unname(vapply(p$layers, function(l) class(l$geom)[1], character(1)))

# first three years of Africa_climate, enough for a time variable and quick to plot
climate_sub <- function()
{
  utils::data("Africa_climate", package = "moveEZ", envir = environment())
  sub <- Africa_climate[Africa_climate$Year %in% levels(Africa_climate$Year)[1:3], ]
  sub$Year <- droplevels(sub$Year)
  sub
}
