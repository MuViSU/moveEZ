# Move plot 3

Create animated biplot on samples and variables in a biplot with a given
target

## Usage

``` r
moveplot3(
  bp,
  time.var,
  group.var,
  move = TRUE,
  hulls = TRUE,
  scale.var = 5,
  target = NULL
)
```

## Arguments

- bp:

  biplot object from biplotEZ

- time.var:

  name of the time variable, given as a character string. Must be a
  factor column of the data supplied to
  [`biplot()`](https://rdrr.io/pkg/biplotEZ/man/biplot.html); the order
  of its levels gives the order of the time slices and levels without
  observations are dropped. A numeric (e.g. integer year) or character
  column stops with an error, see Details.

- group.var:

  name of the group variable, given as a character string. Must be a
  factor column of the data supplied to
  [`biplot()`](https://rdrr.io/pkg/biplotEZ/man/biplot.html).

- move:

  whether to animate (TRUE) or facet (FALSE) samples and variables,
  according to time.var

- hulls:

  whether to display sample points or convex hulls. A hull requires at
  least three non-collinear observations per group per level of
  `time.var`; groups with fewer are displayed as points instead.

- scale.var:

  scaling the vectors representing the variables

- target:

  Target data set to which all biplots should be matched consisting of
  the the same dimensions. If not specified, the centroid of all
  available biplot sample coordinates from `time.var` will be used.
  Default `NULL`.

## Value

- bp:

  Returns the elements of the biplot object `bp` from `biplotEZ`.

- iter_levels:

  The levels of the time variable.

- coord_set:

  The coordinates of the configurations before applying Generalised
  Orthogonal Procrustes Analysis.

- GPA_list:

  The coordinates of the configurations after applying Generalised
  Orthogonal Procrustes Analysis.

- plot:

  An animated or a facet of biplots based on the dynamic frame.

## Details

`time.var` and `group.var` must both be factors.
[`biplot()`](https://rdrr.io/pkg/biplotEZ/man/biplot.html) treats every
numeric column as a variable of the biplot, so a time variable stored as
a number (e.g. an integer year) has to be converted with
[`factor()`](https://rdrr.io/r/base/factor.html) before
[`biplot()`](https://rdrr.io/pkg/biplotEZ/man/biplot.html) is called,
not afterwards.

Missing values are handled by
[`biplot()`](https://rdrr.io/pkg/biplotEZ/man/biplot.html), which
removes every row containing an `NA` in any column (including `time.var`
and `group.var`) with a warning. The plot is constructed from the
remaining rows. Since `moveplot3()` requires the same number of
observations at every level of `time.var`, removed rows will usually
cause it to stop; impute the missing values, or remove the affected
samples at every time level, beforehand. The same applies to `target`,
which may not contain missing values.

## Examples

``` r
data(Africa_climate)
data(Africa_climate_target)
bp <- biplot(Africa_climate, scaled = TRUE) |> PCA()
bp |> moveplot3(time.var = "Year", group.var = "Region", hulls = TRUE,
move = FALSE, target = NULL)

#> Object of class biplot, based on 960 samples and 9 variables.
#> 6 numeric variables.
#> 3 categorical variables.
# \donttest{
if(interactive()) {
bp |> moveplot3(time.var = "Year", group.var = "Region", hulls = TRUE,
move = TRUE, target = NULL)}# }
bp |> moveplot3(time.var = "Year", group.var = "Region", hulls = TRUE,
move = FALSE, target = Africa_climate_target)

#> Object of class biplot, based on 960 samples and 9 variables.
#> 6 numeric variables.
#> 3 categorical variables.
```
