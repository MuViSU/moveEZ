# Move plot 2

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

## Examples

``` r
data(Africa_climate)
bp <- biplotEZ::biplot(Africa_climate, scaled = TRUE) |> biplotEZ::PCA()
# \donttest{
if(interactive()) {
bp |> moveplot2(time.var = "Year", group.var = "Region", hulls = TRUE, move = TRUE)}# }
```
