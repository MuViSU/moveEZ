# moveplot(), moveplot2() and moveplot3() print their plot, keep it off disk
no_plot <- function(expr)
{
  grDevices::pdf(NULL)
  on.exit(grDevices::dev.off())
  force(expr)
}

# data of the first layer of a ggplot drawn with the given geom, e.g. "GeomSegment"
layer_df <- function(p, geom)
{
  is_geom <- vapply(p$layers, function(l) inherits(l$geom, geom), logical(1))
  p$layers[[base::which(is_geom)[1]]]$data
}

# first three years of Africa_climate, enough for a time variable and quick to plot
climate_sub <- function()
{
  utils::data("Africa_climate", package = "moveEZ", envir = environment())
  sub <- Africa_climate[Africa_climate$Year %in% levels(Africa_climate$Year)[1:3], ]
  sub$Year <- droplevels(sub$Year)
  sub
}
