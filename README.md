
<!-- README.md is generated from README.Rmd. Please edit that file -->

# moveEZ <img src="logo.png" align="right" width="150" alt="" />

<!-- badges: start -->

<!-- badges: end -->

The goal of moveEZ is to create animated biplots.

## Installation

You can install the development version of moveEZ from
[GitHub](https://github.com/) with:

``` r
# install.packages("pak")
pak::pak("MuViSU/moveEZ")
```

Consider a dataset ${\bf{X}}$ comprising $n$ observations and $p$
continuous variables, along with an additional variable representing
“time.” This time variable need not correspond to chronological time; it
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

1.  Fixed Variable Frame `moveplot()`: A biplot is first constructed
    using the full dataset ${\bf{X}}$, and the animation is achieved by
    slicing the observations according to the “time” variable. In this
    approach, the variable axes remain fixed, and only the sample points
    are animated over time.

2.  Dynamic Frame `moveplot2()`: Separate biplots are constructed for
    each time slice of the data. Both the sample points and variable
    axes evolve over time, resulting in a fully dynamic animation that
    reflects temporal changes in the underlying data structure.

To illustrate the animated biplots, we use a climate dataset included in
the package. This dataset, Africa_climate, contains climate measurements
from 10 African regions over time:

``` r
library(moveEZ)
data("Africa_climate")
```

We begin by constructing a standard PCA biplot using the `biplotEZ`
package. This biplot aggregates all samples across time and colours them
according to their associated region:

``` r
library(biplotEZ)
bp <- biplot(Africa_climate, scaled = TRUE) |> 
  PCA(group.aes = Africa_climate$Region) |> 
  samples(opacity = 0.8,col = scales::hue_pal()(10)) |>
  plot()
```

<img src="man/figures/README-unnamed-chunk-3-1.png" width="100%" />

# 1. Fixed Variable Frame with `moveplot()`

``` r
# Facet Z
bp |> moveplot(time.var = "Year", group.var = "Region", hulls = TRUE, move = FALSE)
```

<img src="man/figures/README-unnamed-chunk-4-1.png" width="100%" />

``` r
# Animated Z
bp |> moveplot(time.var = "Year", group.var = "Region", hulls = TRUE, move = TRUE)
```

<img src="man/figures/README-unnamed-chunk-5-1.gif" width="100%" />

# 2. Dynamic Frame `moveplot2()`

``` r
# Facet Z, V
bp |> moveplot2(time.var = "Year", group.var = "Region", hulls = TRUE, move = FALSE)
```

``` r
# Animated Z, V
bp |> moveplot2(time.var = "Year", group.var = "Region", hulls = TRUE, move = TRUE)
```
