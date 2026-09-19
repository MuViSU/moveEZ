Y <- data.frame(V1 = c(0, 1, 0, 1, 0.5, 5, 6, 0, 1, 2),
                V2 = c(0, 0, 1, 1, 0.5, 5, 6, 3, 4, 5),
                g = factor(rep(c("a", "b", "c"), c(5, 2, 3))))

test_that("hull vertices are returned for groups with at least three non-collinear points", {
  out <- chull_moveEZ(Y, "g", levels(Y$g))
  expect_named(out, c("hull", "points"))
  expect_equal(as.character(unique(out$hull$g)), "a")
  # interior point (0.5, 0.5) is not a vertex
  expect_equal(nrow(out$hull), 4)
  expect_false(any(out$hull$V1 == 0.5))
})

test_that("groups that are too small or collinear are returned as points", {
  out <- chull_moveEZ(Y, "g", levels(Y$g))
  expect_equal(as.character(out$points$g), rep(c("b", "c"), c(2, 3)))
  expect_equal(nrow(out$hull) + nrow(out$points), nrow(Y) - 1)
})

test_that("column structure is kept when no hull, or no points, are returned", {
  none <- chull_moveEZ(Y, "g", c("b", "c"))
  expect_equal(nrow(none$hull), 0)
  expect_named(none$hull, names(Y))

  all_hulls <- chull_moveEZ(Y, "g", "a")
  expect_equal(nrow(all_hulls$points), 0)
  expect_named(all_hulls$points, names(Y))
})

test_that("only the requested group levels are used", {
  out <- chull_moveEZ(Y, "g", "b")
  expect_equal(nrow(out$hull), 0)
  expect_equal(as.character(out$points$g), c("b", "b"))
})
