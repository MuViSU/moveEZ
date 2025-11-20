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

- eval.list:

  Returns a list containing the measures of comparison for each level of
  the time variable.

- fit.plot:

  Returns a line plot with the fit measures that are bounded between
  zero and one: PS and CC. A small PS value and large CC value indicate
  good fit.

- bias.plot:

  Returns a line plot with bias measures taht are unbounded: AMB, MB and
  RMSB. Small values indicate low bias.

## Examples

``` r
data(Africa_climate)
data(Africa_climate_target)
bp <- biplotEZ::biplot(Africa_climate, scaled = TRUE) |> biplotEZ::PCA()
results <- bp |> moveplot3(time.var = "Year", group.var = "Region", hulls = TRUE,
move = FALSE, target = NULL) |> evaluation()

results$eval.list
#> [[1]]
#>      Target vs. 1950
#> PS            0.1323
#> CC            0.9697
#> AMB           1.2717
#> MB            0.0000
#> RMSB          1.8506
#> 
#> [[2]]
#>      Target vs. 1960
#> PS            0.0982
#> CC            0.9763
#> AMB           0.4414
#> MB            0.0000
#> RMSB          0.5779
#> 
#> [[3]]
#>      Target vs. 1970
#> PS            0.0925
#> CC            0.9798
#> AMB           0.4373
#> MB            0.0000
#> RMSB          0.5701
#> 
#> [[4]]
#>      Target vs. 1980
#> PS            0.0771
#> CC            0.9813
#> AMB           0.3903
#> MB            0.0000
#> RMSB          0.5501
#> 
#> [[5]]
#>      Target vs. 1990
#> PS            0.0812
#> CC            0.9793
#> AMB           0.4177
#> MB            0.0000
#> RMSB          0.5446
#> 
#> [[6]]
#>      Target vs. 2000
#> PS            0.1604
#> CC            0.9636
#> AMB           0.5263
#> MB            0.0000
#> RMSB          0.6564
#> 
#> [[7]]
#>      Target vs. 2010
#> PS            0.0797
#> CC            0.9813
#> AMB           0.4337
#> MB            0.0000
#> RMSB          0.5428
#> 
#> [[8]]
#>      Target vs. 2020
#> PS            0.0695
#> CC            0.9814
#> AMB           0.3914
#> MB            0.0000
#> RMSB          0.5069
#> 
results$fit.plot

results$bias.plot


data(Africa_climate)
data(Africa_climate_target)
bp <- biplotEZ::biplot(Africa_climate, scaled = TRUE) |> biplotEZ::PCA()
results <- bp |> moveplot3(time.var = "Year", group.var = "Region", hulls = TRUE,
move = FALSE, target = Africa_climate_target) |> evaluation()

results$eval.list
#> [[1]]
#>      Target vs. 1950
#> PS            0.2112
#> CC            0.9556
#> AMB           0.4976
#> MB            0.0000
#> RMSB          0.6549
#> 
#> [[2]]
#>      Target vs. 1960
#> PS            0.1738
#> CC            0.9559
#> AMB           1.6285
#> MB            0.0000
#> RMSB          2.3374
#> 
#> [[3]]
#>      Target vs. 1970
#> PS            0.2047
#> CC            0.9521
#> AMB           1.6469
#> MB            0.0000
#> RMSB          2.3450
#> 
#> [[4]]
#>      Target vs. 1980
#> PS            0.1570
#> CC            0.9604
#> AMB           1.5816
#> MB            0.0000
#> RMSB          2.3185
#> 
#> [[5]]
#>      Target vs. 1990
#> PS            0.1698
#> CC            0.9603
#> AMB           1.6250
#> MB            0.0000
#> RMSB          2.3322
#> 
#> [[6]]
#>      Target vs. 2000
#> PS            0.2472
#> CC            0.9451
#> AMB           1.6976
#> MB            0.0000
#> RMSB          2.3489
#> 
#> [[7]]
#>      Target vs. 2010
#> PS            0.1618
#> CC            0.9635
#> AMB           1.6034
#> MB            0.0000
#> RMSB          2.3178
#> 
#> [[8]]
#>      Target vs. 2020
#> PS            0.1277
#> CC            0.9712
#> AMB           1.5778
#> MB            0.0000
#> RMSB          2.2826
#> 
results$fit.plot

results$bias.plot

```
