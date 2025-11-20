# moveEZ

Consider a dataset $\mathbf{X}$ comprising $n$ observations and $p$
continuous variables, along with an additional variable representing
“time”. This time variable need not correspond to chronological time; it
could just as well represent another form of ordered index, such as
algorithmic iterations or experimental stages.

A natural approach is to construct separate biplots for each level of
the time variable, enabling the user to explore how samples and variable
relationships evolve across time. However, when the time variable
includes many levels, this quickly results in an overwhelming number of
biplots.

This package addresses that challenge by animating a single biplot
across the levels of the time variable, allowing for dynamic
visualisation of temporal or sequential changes in the data.

The animation of the biplots—currently limited to PCA biplots—is based
on two conceptual frameworks:

1.  Fixed Variable Frame
    [`moveplot()`](https://muvisu.github.io/moveEZ/reference/moveplot.md):
    A biplot is first constructed using the full dataset $\mathbf{X}$,
    and the animation is achieved by slicing the observations according
    to the “time” variable. In this approach, the variable axes remain
    fixed, and only the sample points are animated over time.

2.  Dynamic Frame
    [`moveplot2()`](https://muvisu.github.io/moveEZ/reference/moveplot2.md)
    and
    [`moveplot3()`](https://muvisu.github.io/moveEZ/reference/moveplot3.md):
    Separate biplots are constructed for each time slice of the data.
    Both the sample points and variable axes evolve over time, resulting
    in a fully dynamic animation that reflects temporal changes in the
    underlying data structure. The differences between these functions
    are highlighted in the subsequent sections.

To illustrate the animated biplots, we use a climate dataset included in
the package. This dataset, Africa_climate, contains climate measurements
from 10 African regions over time:

``` r
library(moveEZ) 
data("Africa_climate")
tibble::tibble(Africa_climate)
#> # A tibble: 960 × 9
#>    Year  Month     Region AccPrec DailyEva  Temp SoilMois  SPI6  wind
#>    <fct> <fct>     <fct>    <dbl>    <dbl> <dbl>    <dbl> <dbl> <dbl>
#>  1 1950  January   ARP      0.177  0.0316   14.8    2.75  1.62   4.07
#>  2 1950  February  ARP      0.208 -0.0249   15.4    2.22  1.32   4.24
#>  3 1950  March     ARP      0.306  0.0122   20.9    2.08  0.987  4.04
#>  4 1950  April     ARP      0.196  0.00396  24.8    1.73  0.916  3.72
#>  5 1950  May       ARP      0.590 -0.0448   28.4    2.47  0.691  3.91
#>  6 1950  June      ARP      0.32  -0.00754  30.4    1.17  0.249  4.40
#>  7 1950  July      ARP      1.33   0.00184  30.8    2.00  0.673  4.93
#>  8 1950  August    ARP      1.82  -0.00944  30.5    2.67  0.937  4.45
#>  9 1950  September ARP      0.706 -0.0107   29.7    1.98  1.22   3.67
#> 10 1950  October   ARP      0.102 -0.0259   25.9    0.976 1.65   3.18
#> # ℹ 950 more rows
```

We begin by constructing a standard PCA biplot using the `biplotEZ`
package (Lubbe et al. (2024)). This biplot aggregates all samples across
time and colours them according to their associated region:

``` r
library(biplotEZ)
bp <- biplot(Africa_climate, scaled = TRUE) |> 
  PCA(group.aes = Africa_climate$Region) |> 
  samples(opacity = 0.8, col = scales::hue_pal()(10)) |>
  plot()
```

![](moveEZ_files/figure-html/unnamed-chunk-3-1.png)

## Fixed Variable Frame with `moveplot()`

Using the previously created PCA biplot object `bp`, the
[`moveplot()`](https://muvisu.github.io/moveEZ/reference/moveplot.md)
function enables animation of the sample points over time. This function
is piped with several key arguments:

- `time.var`: Specifies the name of the variable in the dataset that
  represents the temporal or sequential dimension. In this case, the
  variable “Year” relates to the time variable.

- `group.var`: Indicates a grouping variable used for colour-coding. In
  this case, the variable “Region” relates to the group variable.

- `hulls`: A logical flag that determines whether to display individual
  sample points or to draw convex hulls around each group.

`move`: A critical argument that controls whether the biplot is
animated. If set to `TRUE`, the sample points are animated across time.
If set to `FALSE`, the function returns a faceted plot showing a static
biplot for each time level.

This design provides flexibility in exploring temporal dynamics in
multivariate data, with options for both animated and comparative static
visualisations.

### Facet: `move = FALSE`

``` r
bp |> moveplot(time.var = "Year", group.var = "Region", hulls = TRUE, move = FALSE)
```

![](moveEZ_files/figure-html/unnamed-chunk-4-1.png)

    #> Object of class biplot, based on 960 samples and 9 variables.
    #> 6 numeric variables.
    #> 3 categorical variables.

### Animation: `move = TRUE`

![](anim1.gif)

## Dynamic Frame `moveplot2()`

The
[`moveplot2()`](https://muvisu.github.io/moveEZ/reference/moveplot2.md)
function extends the animation to both the sample points and the
variable axes. Unlike
[`moveplot()`](https://muvisu.github.io/moveEZ/reference/moveplot.md),
which keeps the variable axes fixed,
[`moveplot2()`](https://muvisu.github.io/moveEZ/reference/moveplot2.md)
constructs a separate biplot for each time slice, allowing both
components to evolve over time. The function shares the same arguments
as
[`moveplot()`](https://muvisu.github.io/moveEZ/reference/moveplot.md),
with the `move` argument determining whether the animation is shown or
presented as static facets for samples and variables.

### Facet: `move = FALSE`

``` r
bp |> moveplot2(time.var = "Year", group.var = "Region", hulls = TRUE, move = FALSE)
```

![](moveEZ_files/figure-html/unnamed-chunk-6-1.png)

    #> Object of class biplot, based on 960 samples and 9 variables.
    #> 6 numeric variables.
    #> 3 categorical variables.

When `move` is `FALSE`, a faceted plot is returned, showing the biplot
at each time point. Here, both the sample coordinates and variable axes
differ across facets, reflecting temporal changes in the data structure.

There is a noticeable discontinuity in the transition from the year 1950
to 1960. From 1960 onwards, however, the biplots appear well-aligned. To
address such inconsistencies, the
[`moveplot2()`](https://muvisu.github.io/moveEZ/reference/moveplot2.md)
function provides two additional arguments — `align.time` and `reflect`
— which enable alignment and optional axis reflections of the biplots at
specified time points, resulting in smoother and more coherent
animations.

### Animated: `move = TRUE`

![](anim2.gif)

Setting `move` to TRUE produces an animated biplot in which both the
samples and variables transition across time, offering a dynamic view of
structural shifts in the multivariate space.

In the example above, we align the biplot at the 1950 time point and
apply a reflection about the x-axis. Available options include:

- “x” – Reflect about the x-axis

- “y” – Reflect about the y-axis

- “xy” – Reflect about both axes

And of course, both `align.time` and `reflect` can be vectors when
alignment is needed at multiple time points. Each entry in `reflect`
corresponds to a time point in `align.time`, allowing fine-grained
control over the alignment and orientation of biplots across the
animation sequence.

## Dynamic frame with alignment to a `target` with `moveplot3()`

This function shares the same arguments as
[`moveplot()`](https://muvisu.github.io/moveEZ/reference/moveplot.md)
and
[`moveplot2()`](https://muvisu.github.io/moveEZ/reference/moveplot2.md),
with the addition of the `target` argument.
[`moveplot3()`](https://muvisu.github.io/moveEZ/reference/moveplot3.md)
utilises Generalised Orthogonal Procrustes Analysis (GPA) (Gower and
Dijksterhuis (2004)) to align sample points and variable axes to either
a specified target (for example: same measurements at a different time
point) or to a centroid coordinate matrix representing all sample points
and axes across time slices (`target = NULL`). GPA is applied by using
the `GPAbin` package and makes use of admissible transformations
(translation, scaling, rotation and reflection) to optimally align
configurations, while preserving the distances between coordinates. As
with
[`moveplot2()`](https://muvisu.github.io/moveEZ/reference/moveplot2.md)
the `move` argument determines whether the animations of changing sample
points and variables axes are shown or presented as static facets.

To illustrate the use of a fixed target, we use the year 1989 from the
`Africa_climate` data set, which consists of the same variables and
number of observations:

``` r
data("Africa_climate_target")
tibble::tibble(Africa_climate_target)
#> # A tibble: 120 × 9
#>    Year  Month     Region AccPrec DailyEva  Temp SoilMois     SPI6  wind
#>    <fct> <chr>     <chr>    <dbl>    <dbl> <dbl>    <dbl>    <dbl> <dbl>
#>  1 1989  January   ARP     0.0740 -0.00416  14.9    1.11  -1.08     4.06
#>  2 1989  February  ARP     0.235  -0.00161  17.3    1.55  -0.817    4.19
#>  3 1989  March     ARP     0.815  -0.0220   21.5    2.70   0.00329  4.12
#>  4 1989  April     ARP     0.495   0.0508   25.0    2.90   0.226    3.48
#>  5 1989  May       ARP     0.0411 -0.0130   30.1    1.08   0.306    3.96
#>  6 1989  June      ARP     0.0693 -0.0234   31.6    0.633  0.261    4.33
#>  7 1989  July      ARP     0.0833 -0.0164   33.1    0.606  0.527    4.36
#>  8 1989  August    ARP     0.137  -0.0209   32.6    0.685  0.575    4.05
#>  9 1989  September ARP     0.102  -0.0246   30.1    0.656  0.0360   3.56
#> 10 1989  October   ARP     0.0330 -0.0549   26.5    0.449 -0.919    3.45
#> # ℹ 110 more rows
```

### Facet: `move = FALSE` and `target = NULL`

``` r
bp |> moveplot3(time.var = "Year", group.var = "Region", hulls = TRUE, move = FALSE,
                target = NULL)
```

![](moveEZ_files/figure-html/unnamed-chunk-9-1.png)

    #> Object of class biplot, based on 960 samples and 9 variables.
    #> 6 numeric variables.
    #> 3 categorical variables.

The separate biplots per `time.var` are transformed and aligned to the
centroid coordinate matrix of all observed sample points and axes
variables.

### Facet: `move = FALSE` and `target = Africa_climate_target`

``` r
bp |> moveplot3(time.var = "Year", group.var = "Region", hulls = TRUE, move = FALSE, 
                target = Africa_climate_target)
```

![](moveEZ_files/figure-html/unnamed-chunk-10-1.png)

    #> Object of class biplot, based on 960 samples and 9 variables.
    #> 6 numeric variables.
    #> 3 categorical variables.

Now, the separate biplots per `time.var` are transformed and aligned to
the sample points and axes variables of the 1989 `Africa_climate`
dataset. **Take note**: the target biplot is not shown. This example
showcases the difference between each the observations and variables for
each year in `Africa_climate` compared to 1989.

### Animated: `move = TRUE` and `target = NULL`

![](anim3.gif)

Here the animated view of the biplots over time are illustrated after
aligning the visualisation to the centroid configuration.

### Animated: `move = TRUE` and `target = Africa_climate_target`

![](anim4.gif)

Finally, the animated biplots illustrate the transformations towards a
specified target dataset. Again, the focus is on the movement that
changes between the variables and sample representation as the target is
set to a specific year compared to the movement observed in the previous
example where `target = NULL`. Therefore, these animations expose the
*jumps* that occur from 1989 to each of the years in `Africa_climate`
from 1950 to 2020 (in increments of 10 years).

## Evaluation

This function can only be used in conjunction with
[`moveplot3()`](https://muvisu.github.io/moveEZ/reference/moveplot3.md).
Five measures of comparison are calculated to establish the differences
between each individual biplot and the chosen `target` configuration as
specified in
[`moveplot3()`](https://muvisu.github.io/moveEZ/reference/moveplot3.md).
The measures are based on Orthogonal Procrustes analysis between the
target and the specific individual biplot. There are three bias related
measures: Absolute Mean Bias (AMB), Mean Bias (MB) and the Root Mean
Squared Bias (RMSB). There are two fit measures: Procrustes Statistic
(PS) and Congruence Coefficient (CC). For more information on these
metrics refer to Nienkemper-Swanepoel, Roux, and Gardner-Lubbe (2023).

The evaluation measures can be extracted as follows:

``` r
results <- bp |> moveplot3(time.var = "Year", group.var = "Region", hulls = TRUE, 
                           move = FALSE, target = NULL) |> evaluation()
```

![](moveEZ_files/figure-html/unnamed-chunk-13-1.png)

``` r
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
```

To ease interpretation, especially when there is a large number of time
points, separate line plots are available for the fit and bias measures.

### The fit measures

The Procrustes Statistics(PS) and Congruence Coefficient (CC) is bounded
by zero and one. A small PS value (close to zero) and a large CC value
(close to one) indicate good fit. These measures express the magnitude
of changes that has to be made for a particular biplot to match the
target visualisation. Therefore, they measure how *close* the
coordinates of the two configurations are.

``` r
results$fit.plot
```

![](moveEZ_files/figure-html/unnamed-chunk-15-1.png)

The line plot shows that the biplot of 2000 results in a lower CC and
larger PS value compared to the other years. This means that there is a
noticeable difference between the year 2000 and the average across years
and the measurements of 2000 should be investigated in more detail to
understand the cause of this difference.

### The bias measures

Low values for the Absolute Mean Bias (AMB), Mean Bias (MB) and the Root
Mean Squared Bias (RMSB) reflect unbiased representation between a
biplot and the target it is being matched to.

``` r
results$bias.plot
```

![](moveEZ_files/figure-html/unnamed-chunk-16-1.png)

The line plot shows that the initial bias is high, but decreases and
stabilises from 1960 with an increase in both the AMB and RMSB occurring
for 2000. This is in agreement with the fit measures. The MB stays
constant and close to zero for all comparisons.

## Still to Come!

We are actively working to develop and enhance the dynamic plotting
capabilities of these functions to expose and detect changes in
observations and variables over time.

Stay tuned for updates!

## References

Gower, J. C., and G. B. Dijksterhuis. 2004. *Procrustes Problems*. Book.
Oxford: Oxford University Press.

Lubbe, Sugnet, Niël le Roux, Johané Nienkemper-Swanepoel, Raeesa Ganey,
Ruan Buys, Zoë-Mae Adams, and Peter Manefeldt. 2024. *biplotEZ:
EZ-to-Use Biplots*. <https://doi.org/10.32614/CRAN.package.biplotEZ>.

Nienkemper-Swanepoel, J., N. J. le Roux, and S. Gardner-Lubbe. 2023.
“GPAbin: Unifying Visualizations of Multiple Imputations for Missing
Values.” *Communications in Statistics - Simulation and Computation* 52
(6): 2666–85. <https://doi.org/10.1080/03610918.2021.1914089>.
