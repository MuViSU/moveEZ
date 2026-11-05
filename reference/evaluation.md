# Measures of comparison for move plot 3

This function calculates measures of comparison after generalised
orthogonal Procrustes Analysis is performed in `moveplot3`. Orthogonal
Procrustes Analysis is used to compare a target to a testee
configuration. The following measures are calculate: Procrustes
Statistic (PS), Congruence Coefficient (CC), Absolute Mean Bias (AMB),
Mean Bias (MB) and Root Mean Squared Bias (RMSB).

## Usage

``` r
evaluation(bp, centring = TRUE)
```

## Arguments

- bp:

  biplot object from `moveEZ`

- centring:

  logical argument to apply centring or not (default is `TRUE`)

## Value

- eval.tab:

  Returns a table of the measures of comparison for each level of the
  time variable compared to the target.

- fit.plot:

  Returns a line plot with the fit measures that are bounded between
  zero and one: PS and CC. A small PS value and large CC value indicate
  good fit.

- bias.plot:

  Returns a line plot with bias measures that are unbounded: AMB, MB and
  RMSB. Small values indicate low bias.

- structure:

  For `moveplot`, a data frame with the proportion of variance of the
  first dimension, the principal angle and the loadings on the first
  dimension for each level of the time variable.

- var.plot:

  For `moveplot`, a line plot of the proportion of variance of the first
  dimension over time.

- angle.plot:

  For `moveplot`, a line plot of the principal angle with the biplot of
  all the data over time.

- loadings.plot:

  For `moveplot`, a line plot of the loadings of the variables on the
  first dimension over time.

- drift.tab:

  For `moveplot`, a table of the Spearman rank correlations (rho) of
  each quantity with time, their p-values and whether they are
  significant at the 5% level (\*).

## Details

For `moveplot`, the function evaluates whether the fixed frame of
[`moveplot()`](https://muvisu.github.io/moveEZ/reference/movefixed.md),
where the variable vectors are computed once on all the data, is
adequate, or whether a biplot should be constructed for each time slice
with
[`moveplot2()`](https://muvisu.github.io/moveEZ/reference/movedynamic.md)
or
[`moveplot3()`](https://muvisu.github.io/moveEZ/reference/movegpa.md). A
PCA (or CVA) biplot is fitted to each level of the time variable and
compared with the biplot of all the data, see Details.

For `moveplot`, the following are computed for each level of the time
variable, in the order of its levels:

- the proportion of variance explained by the first dimension of the
  biplot of that time slice,

- the largest principal angle (in degrees) between the two dimensional
  subspace of the biplot of that time slice and that of the biplot of
  all the data. Zero means that the time slice spans the same plane,

- the loadings of the variables on the first dimension. The sign of each
  eigenvector is arbitrary, so the dimensions of each time slice are
  reflected to point in the same direction as those of the biplot of all
  the data (as `auto.align` in
  [`moveplot2()`](https://muvisu.github.io/moveEZ/reference/movedynamic.md))
  before the loadings are compared.

A Spearman rank correlation test between the order of the time levels
and each of these quantities tests for a monotone drift over time. A
p-value of 0.05 or more fails to reject zero correlation: there is no
evidence that the structure of the biplot changes over time, the fixed
frame of
[`moveplot()`](https://muvisu.github.io/moveEZ/reference/movefixed.md)
is adequate, and
[`moveplot2()`](https://muvisu.github.io/moveEZ/reference/movedynamic.md)
or [`moveplot3()`](https://muvisu.github.io/moveEZ/reference/movegpa.md)
are not needed. A p-value below 0.05 indicates a drift, and a biplot
should be constructed for each time slice. The test only detects
monotone trends; large but non-monotone changes are visible in the
plots.

## Examples

``` r
data(Africa_climate)
data(Africa_climate_target)
bp <- biplotEZ::biplot(Africa_climate, scaled = TRUE) |> biplotEZ::PCA()
results <- bp |> moveplot3(time.var = "Year", group.var = "Region", hulls = TRUE,
move = FALSE, target = NULL) |> evaluation()

#> [1] "Evaluation measures can only be applied for moveplot() and moveplot3()."
results$eval.tab
#> NULL
results$fit.plot
#> NULL
results$bias.plot
#> NULL

data(Africa_climate)
data(Africa_climate_target)
bp <- biplotEZ::biplot(Africa_climate, scaled = TRUE) |> biplotEZ::PCA()
results <- bp |> moveplot3(time.var = "Year", group.var = "Region", hulls = TRUE,
move = FALSE, target = Africa_climate_target) |> evaluation()

#> [1] "Evaluation measures can only be applied for moveplot() and moveplot3()."
results$eval.tab
#> NULL
results$fit.plot
#> NULL
results$bias.plot
#> NULL

# Should a biplot be constructed for each time slice?
bp <- biplotEZ::biplot(Africa_climate, scaled = TRUE) |> biplotEZ::PCA()
results <- bp |> moveplot(time.var = "Year", group.var = "Region", hulls = TRUE,
move = FALSE) |> evaluation()

results$drift.tab
#> 
#> 
#> Table: Spearman drift test
#> 
#> |Quantity       |  rho   |   p   | sig |
#> |:--------------|:------:|:-----:|:---:|
#> |pc1_var        | -0.738 | 0.046 |  *  |
#> |angle_deg      | 0.119  | 0.793 |  -  |
#> |load1_AccPrec  | 0.405  | 0.327 |  -  |
#> |load1_DailyEva | 0.190  | 0.665 |  -  |
#> |load1_Temp     | -0.238 | 0.582 |  -  |
#> |load1_SoilMois | 0.524  | 0.197 |  -  |
#> |load1_SPI6     | -0.524 | 0.197 |  -  |
#> |load1_wind     | -0.071 | 0.882 |  -  |
results$var.plot

results$angle.plot

results$loadings.plot

```
