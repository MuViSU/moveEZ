## moveEZ (development version)

`moveplot()`, `moveplot2()` and `moveplot3()` now validate `time.var` and `group.var` before plotting. Both must name factor columns of the data supplied to `biplot()`; a numeric (e.g. integer year), character or misspelt column now stops with an informative error explaining how to fix it, instead of failing downstream. Levels of `time.var` without observations are dropped, which previously caused `moveplot2()` and `moveplot3()` to stop.

The handling of missing values is now documented: `biplot()` removes rows containing `NA` with a warning. `moveplot3()` reports when this is the reason for unequal numbers of observations per time level, and stops if `target` contains missing values.

`moveplot2()` and `moveplot3()` now apply the same convex hull guard as `moveplot()`: groups with fewer than three non-collinear observations at a time level are displayed as points instead of a hull, rather than being passed to `chull()` unconditionally. The guard is documented in the `hulls` argument of all three functions.

## moveEZ 1.3.1

Reduced runtime of moveplot() examples to address CRAN NOTE on example timing.

## moveEZ 1.3.0

New CRAN submission which includes additional arguments for moveplot(), and CVA biplots.

## moveEZ 1.2.0

New CRAN submission which includes aesthetic features. 

## moveEZ 1.1.0

CRAN submission which includes an evaluation function.

## moveEZ 1.0.0

Initial CRAN submission

