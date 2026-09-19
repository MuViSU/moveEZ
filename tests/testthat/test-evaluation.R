# evaluation() only uses the target, the configurations and the time levels
fake_moveplot3 <- function(target, coord_set)
  structure(list(G.target = target, coord_set = coord_set, iter_levels = as.character(seq_along(coord_set))),
            class = c("biplot", "PCA", "moveplot3"))

# measures as plotted, since eval.tab is a formatted table
measures <- function(ev)
{
  df <- rbind(ev$fit.plot$layers[[1]]$data, ev$bias.plot$layers[[1]]$data)
  tab <- tapply(df$Value, list(df$Year, df$Measure), identity)
  tab[, c("PS", "CC", "AMB", "MB", "RMSB"), drop = FALSE]
}

set.seed(1)
target <- scale(matrix(rnorm(40), ncol = 2), TRUE, FALSE)
theta <- pi / 3
rotation <- matrix(c(cos(theta), sin(theta), -sin(theta), cos(theta)), 2)

test_that("a configuration identical to the target fits perfectly", {
  ev <- evaluation(fake_moveplot3(target, list(target)))
  expect_equal(unname(measures(ev)[1, ]), c(0, 1, 0, 0, 0))
})

test_that("PS and CC are invariant to rotation and scaling of the testee", {
  ev <- evaluation(fake_moveplot3(target, list(target %*% rotation, 3 * target %*% rotation)))
  m <- measures(ev)
  expect_equal(unname(m[, "PS"]), c(0, 0))
  expect_equal(unname(m[, "CC"]), c(1, 1))
  # bias measures compare the coordinates as they are
  expect_gt(m[1, "RMSB"], 0)
  expect_gt(m[2, "RMSB"], m[1, "RMSB"])
})

test_that("an unrelated configuration fits worse than a noisy copy of the target", {
  noisy <- target + matrix(rnorm(40, sd = 0.05), ncol = 2)
  unrelated <- matrix(rnorm(40), ncol = 2)
  m <- measures(evaluation(fake_moveplot3(target, list(noisy, unrelated))))
  expect_lt(m[1, "PS"], m[2, "PS"])
  expect_gt(m[1, "CC"], m[2, "CC"])
  expect_true(all(m[, "PS"] >= 0 & m[, "PS"] <= 1))
  expect_true(all(m[, "CC"] >= 0 & m[, "CC"] <= 1))
})

test_that("centring removes a translation of the testee", {
  shifted <- fake_moveplot3(target, list(target + 1))
  expect_equal(unname(measures(evaluation(shifted))[1, ]), c(0, 1, 0, 0, 0))
  m <- measures(evaluation(shifted, centring = FALSE))
  expect_equal(unname(m[1, c("AMB", "MB", "RMSB")]), c(1, -1, 1))
})

test_that("evaluation adds a table and two plots to a moveplot3 object", {
  climate <- climate_sub()
  bp <- biplot(climate, scaled = TRUE) |> PCA()
  out <- no_plot(moveplot3(bp, time.var = "Year", group.var = "Region", move = FALSE))
  ev <- evaluation(out)
  expect_s3_class(ev, "moveplot3")
  expect_s3_class(ev$eval.tab, "knitr_kable")
  expect_s3_class(ev$fit.plot, "ggplot")
  expect_s3_class(ev$bias.plot, "ggplot")
  for(y in levels(climate$Year)) expect_true(any(grepl(paste("Target vs.", y), ev$eval.tab, fixed = TRUE)))
  expect_setequal(ev$fit.plot$layers[[1]]$data$Measure, c("PS", "CC"))
  expect_setequal(ev$bias.plot$layers[[1]]$data$Measure, c("AMB", "MB", "RMSB"))
  expect_equal(rownames(measures(ev)), levels(climate$Year))
})

test_that("objects not created by moveplot3 are returned unchanged", {
  bp <- biplot(climate_sub(), scaled = TRUE) |> PCA()
  expect_output(res <- evaluation(bp), "can only be applied for moveplot3")
  expect_identical(res, bp)
})
