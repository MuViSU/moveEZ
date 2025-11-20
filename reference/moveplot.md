# Move plot

Create animated biplot on samples in a biplot

## Usage

``` r
moveplot(
  bp,
  time.var,
  group.var,
  move = TRUE,
  hulls = TRUE,
  scale.var = 5,
  shadow = FALSE
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

  whether to animate (TRUE) or facet (FALSE) samples, according to
  time.var

- hulls:

  whether to display sample points or convex hulls

- scale.var:

  scaling the vectors representing the variables

- shadow:

  whether the animation will keep past states (only when hulls = FALSE)

## Value

- bp:

  Returns the elements of the biplot object `bp` from `biplotEZ`.

- plot:

  An animated or a facet of biplots based on the dynamic frame.

## Examples

``` r
data(Africa_climate)
bp <- biplotEZ::biplot(Africa_climate, scaled = TRUE) |> biplotEZ::PCA()

# Convex hulls facet plot
bp |> moveplot(time.var = "Year", group.var = "Region", hulls = TRUE, move = FALSE)

#> Object of class biplot, based on 960 samples and 9 variables.
#> 6 numeric variables.
#> 3 categorical variables.

# Samples facet plot
bp |> moveplot(time.var = "Year", group.var = "Region", hulls = FALSE, move = FALSE)

#> Object of class biplot, based on 960 samples and 9 variables.
#> 6 numeric variables.
#> 3 categorical variables.

# Specifying colours with colour palette in biplotEZ
bp <- biplotEZ::biplot(Africa_climate, scaled = TRUE, group.aes = Africa_climate$Region) |>
biplotEZ::PCA() |> biplotEZ::samples(col = RColorBrewer::brewer.pal(10, "Paired"))
bp |> moveplot(time.var = "Year", group.var = "Region", hulls = TRUE, move = FALSE)

#> Object of class biplot, based on 960 samples and 9 variables.
#> 6 numeric variables.
#> 3 categorical variables.

# Specifying plotting characters for grouping variable in biplotEZ
bp <- biplotEZ::biplot(Africa_climate, scaled = TRUE, group.aes = Africa_climate$Region) |>
biplotEZ::PCA() |> biplotEZ::samples(pch = c(19,21,3))
bp |> moveplot(time.var = "Year", group.var = "Region", hulls = TRUE, move = FALSE)

#> Object of class biplot, based on 960 samples and 9 variables.
#> 6 numeric variables.
#> 3 categorical variables.
# Specifying colours manually in biplotEZ
bp <- biplotEZ::biplot(Africa_climate, scaled = TRUE, group.aes = Africa_climate$Region) |>
biplotEZ::PCA() |> biplotEZ::samples(col = c("firebrick4", "indianred3", "tomato", "sandybrown",
 "khaki1", "palegreen1", "darkseagreen2", "mediumaquamarine", "deepskyblue4", "mediumpurple4"))
bp |> moveplot(time.var = "Year", group.var = "Region", hulls = TRUE, move = FALSE)

#> Object of class biplot, based on 960 samples and 9 variables.
#> 6 numeric variables.
#> 3 categorical variables.

# Convex hulls move plot
# \donttest{
if(interactive()) {
bp |> moveplot(time.var = "Year", group.var = "Region", hulls = TRUE, move = TRUE)}# }

# Samples move plot with shadows
# \donttest{
if(interactive()) {
bp |> moveplot(time.var = "Year", group.var = "Region", hulls = FALSE, move = TRUE, shadow = TRUE)}# }
```
