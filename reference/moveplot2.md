# Move plot 2

Create animated biplot on samples and variables in a biplot

Create animated biplot on samples and variables in a biplot

## Usage

``` r
moveplot2(
  bp,
  time.var,
  group.var,
  move = TRUE,
  hulls = TRUE,
  scale.var = 5,
  align.time = NA,
  reflect = NA
)

moveplot2(
  bp,
  time.var,
  group.var,
  move = TRUE,
  hulls = TRUE,
  scale.var = 5,
  align.time = NA,
  reflect = NA
)
```

## Arguments

- bp:

  biplot object from biplotEZ

- time.var:

  time variable

- group.var:

  group variable

- move:

  whether to animate (TRUE) or facet (FALSE) samples and variables,
  according to time.var

- hulls:

  whether to display sample points or convex hulls

- scale.var:

  scaling the vectors representing the variables

- align.time:

  a vector specifying the levels of time.var for which the biplots
  should be aligned. Only biplots corresponding to these time points
  will be used to compute the alignment transformation.

- reflect:

  a character vector specifying the axis of reflection to apply at each
  corresponding time point in align.time. One of FALSE (default), "x"
  for reflection about the x-axis, "y" for reflection about the y-axis
  and "xy" for reflection about both axes.

## Value

- bp:

  Returns the elements of the biplot object `bp` from `biplotEZ`.

- plot:

  An animated or a facet of biplots based on the dynamic frame.

- bp:

  Returns the elements of the biplot object `bp` from `biplotEZ`.

- plot:

  An animated or a facet of biplots based on the dynamic frame.

## Examples

``` r
data(Africa_climate)
bp <- biplot(Africa_climate, scaled = TRUE) |> PCA()
# \donttest{
if(interactive()) {
bp |> moveplot2(time.var = "Year", group.var = "Region", hulls = TRUE, move = TRUE)}# }
data(Africa_climate)
bp <- biplot(Africa_climate, scaled = TRUE) |> PCA()
# \donttest{
if(interactive()) {
bp <- bp |> moveplot2(time.var = "Year", group.var = "Region", hulls = TRUE, move = TRUE)}# }

# Extracting measures of fit
bp <- bp |> moveplot2(time.var = "Year", group.var = "Region", hulls = TRUE, move = FALSE)

bp$quality
#> 
#> 
#> Table: Biplot qualities per time slice
#> 
#> | Time slice | Quality |
#> |:----------:|:-------:|
#> |    1950    |  0.657  |
#> |    1960    |  0.691  |
#> |    1970    |  0.690  |
#> |    1980    |  0.689  |
#> |    1990    |  0.674  |
#> |    2000    |  0.685  |
#> |    2010    |  0.677  |
#> |    2020    |  0.652  |
bp$axis.predictivity
#> 
#> 
#> Table: Axis predictivities per time slice
#> 
#> | Time slice | AccPrec | DailyEva | Temp  | SoilMois | SPI6  | wind  |
#> |:----------:|:-------:|:--------:|:-----:|:--------:|:-----:|:-----:|
#> |    1950    |  0.754  |  0.757   | 0.527 |  0.887   | 0.420 | 0.596 |
#> |    1960    |  0.789  |  0.718   | 0.683 |  0.919   | 0.305 | 0.735 |
#> |    1970    |  0.777  |  0.638   | 0.726 |  0.896   | 0.389 | 0.715 |
#> |    1980    |  0.801  |  0.781   | 0.607 |  0.887   | 0.296 | 0.760 |
#> |    1990    |  0.824  |  0.783   | 0.583 |  0.909   | 0.221 | 0.723 |
#> |    2000    |  0.760  |  0.617   | 0.727 |  0.905   | 0.535 | 0.571 |
#> |    2010    |  0.763  |  0.772   | 0.632 |  0.873   | 0.293 | 0.727 |
#> |    2020    |  0.784  |  0.794   | 0.547 |  0.895   | 0.149 | 0.743 |
```
