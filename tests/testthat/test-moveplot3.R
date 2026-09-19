climate <- climate_sub()
years <- levels(climate$Year)
bp <- biplot(climate, scaled = TRUE) |> PCA()
n_slice <- nrow(climate) / length(years)
out <- no_plot(moveplot3(bp, time.var = "Year", group.var = "Region", move = FALSE))

test_that("moveplot3 returns the configurations before and after GPA", {
  expect_s3_class(out, c("biplot", "PCA", "moveplot3"), exact = TRUE)
  expect_equal(out$iter_levels, years)

  expect_length(out$coord_set, length(years))
  expect_length(out$GPA_list, length(years))
  # samples followed by variables
  for(i in seq_along(years))
  {
    expect_equal(dim(out$coord_set[[i]]), c(n_slice + ncol(bp$X), 2))
    expect_equal(dim(out$GPA_list[[i]]), c(n_slice + ncol(bp$X), 2))
  }
  expect_equal(dim(out$G.target), c(n_slice + ncol(bp$X), 2))
})

test_that("coord_set holds the PCA biplot of every time slice", {
  slice <- climate[climate$Year == years[2], ]
  bp_slice <- biplot(slice, scaled = TRUE) |> PCA()
  expect_equal(as.matrix(out$coord_set[[2]]), rbind(bp_slice$Z, bp_slice$Vr), ignore_attr = TRUE)
})

test_that("GPA moves the configurations closer to the target", {
  ss <- function(X) sum((as.matrix(X) - out$G.target)^2)
  before <- sum(sapply(out$coord_set, ss))
  after <- sum(sapply(out$GPA_list, ss))
  expect_lt(after, before)

  # the plotted variable vectors are the GPA transformed ones
  Vr <- layer_df(out$plot, "GeomSegment")
  expect_equal(as.matrix(Vr[Vr$Year == years[1], c("V1", "V2")]),
               out$GPA_list[[1]][-(1:n_slice), ], ignore_attr = TRUE)
})

test_that("a supplied target is used as the target configuration", {
  data(Africa_climate_target)
  out_t <- no_plot(moveplot3(bp, time.var = "Year", group.var = "Region", move = FALSE,
                             target = Africa_climate_target))
  bp_target <- biplot(Africa_climate_target, scaled = TRUE) |> PCA()
  expect_equal(out_t$G.target, rbind(bp_target$Z, bp_target$Vr), ignore_attr = TRUE)
  expect_equal(out_t$coord_set, out$coord_set)
  expect_false(isTRUE(all.equal(out_t$GPA_list, out$GPA_list)))
})

test_that("unequal numbers of observations per time slice stop with an informative error", {
  bp_uneq <- biplot(climate[-1, ], scaled = TRUE) |> PCA()
  expect_error(moveplot3(bp_uneq, time.var = "Year", group.var = "Region", move = FALSE),
               "number of observations per time.var level should be equal")
})
