# Convex hulls per group

Computes the convex hull of each group for a single level of the time
variable. A hull needs at least three non-collinear observations; groups
that do not meet this are left out of the hull data and returned
separately so that they can be drawn as points instead.

## Usage

``` r
chull_moveEZ(Y, group.var, group_levels)
```

## Arguments

- Y:

  tibble of sample coordinates (columns V1, V2) and grouping columns

- group.var:

  group variable

- group_levels:

  levels of group.var to construct hulls for

## Value

A list with `hull`, the rows of `Y` that form the hull vertices of each
group, and `points`, the rows of `Y` for groups with too few
observations to construct a hull.
