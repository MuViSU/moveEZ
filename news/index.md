# Changelog

## moveEZ (development version)

[`moveplot()`](https://muvisu.github.io/moveEZ/reference/moveplot.md),
[`moveplot2()`](https://muvisu.github.io/moveEZ/reference/moveplot2.md)
and
[`moveplot3()`](https://muvisu.github.io/moveEZ/reference/moveplot3.md)
now validate `time.var` and `group.var` before plotting. Both must name
factor columns of the data supplied to
[`biplot()`](https://rdrr.io/pkg/biplotEZ/man/biplot.html); a numeric
(e.g. integer year), character or misspelt column now stops with an
informative error explaining how to fix it, instead of failing
downstream. Levels of `time.var` without observations are dropped, which
previously caused
[`moveplot2()`](https://muvisu.github.io/moveEZ/reference/moveplot2.md)
and
[`moveplot3()`](https://muvisu.github.io/moveEZ/reference/moveplot3.md)
to stop.

The handling of missing values is now documented:
[`biplot()`](https://rdrr.io/pkg/biplotEZ/man/biplot.html) removes rows
containing `NA` with a warning.
[`moveplot3()`](https://muvisu.github.io/moveEZ/reference/moveplot3.md)
reports when this is the reason for unequal numbers of observations per
time level, and stops if `target` contains missing values.

[`moveplot2()`](https://muvisu.github.io/moveEZ/reference/moveplot2.md)
and
[`moveplot3()`](https://muvisu.github.io/moveEZ/reference/moveplot3.md)
now apply the same convex hull guard as
[`moveplot()`](https://muvisu.github.io/moveEZ/reference/moveplot.md):
groups with fewer than three non-collinear observations at a time level
are displayed as points instead of a hull, rather than being passed to
[`chull()`](https://rdrr.io/r/grDevices/chull.html) unconditionally. The
guard is documented in the `hulls` argument of all three functions.

[`moveplot2()`](https://muvisu.github.io/moveEZ/reference/moveplot2.md)
now reflects every level supplied in `align.time`. Previously only one
level was reflected when `align.time` was a vector. `align.time` values
that are not levels of `time.var`, and a `reflect` that does not match
`align.time`, now stop with an informative error. The documentation of
`reflect` has been clarified: as in
[`biplotEZ::reflect()`](https://rdrr.io/pkg/biplotEZ/man/reflect.html),
`"x"` reverses the direction of the x-axis (horizontal flip) and `"y"`
that of the y-axis (vertical flip).

## moveEZ 1.3.1

Reduced runtime of moveplot() examples to address CRAN NOTE on example
timing.

## moveEZ 1.3.0

CRAN release: 2026-08-26

New CRAN submission which includes additional arguments for moveplot(),
and CVA biplots.

## moveEZ 1.2.0

CRAN release: 2026-05-13

New CRAN submission which includes aesthetic features.

## moveEZ 1.1.0

CRAN release: 2025-08-22

CRAN submission which includes an evaluation function.

## moveEZ 1.0.0

Initial CRAN submission
