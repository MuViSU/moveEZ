## moveEZ (development version)

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

