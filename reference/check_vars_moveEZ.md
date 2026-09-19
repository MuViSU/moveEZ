# Check the time and group variables

Validates `time.var` and `group.var` before any plotting is attempted,
so that unsuitable input stops with an informative error instead of
failing downstream. Both must name factor columns of the data supplied
to [`biplotEZ::biplot()`](https://rdrr.io/pkg/biplotEZ/man/biplot.html),
without missing values.

## Usage

``` r
check_vars_moveEZ(bp, time.var, group.var)
```

## Arguments

- bp:

  biplot object from biplotEZ

- time.var:

  time variable

- group.var:

  group variable

## Value

`bp`, with unused levels of `time.var` dropped from `bp$raw.X`.
