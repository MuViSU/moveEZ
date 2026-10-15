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

# time slices of the same latent structure, with the first variable loading less on it at every
# next time level when drift = TRUE
drift_data <- function(drift, n_t = 8, n = 60)
{
  set.seed(2)
  do.call(rbind, lapply(seq_len(n_t), function(t) {
    w1 <- if(drift) cos((t - 1) / (n_t - 1) * pi / 2) else 1
    f <- stats::rnorm(n)
    data.frame(x1 = w1 * f + stats::rnorm(n, sd = 0.4), x2 = f + stats::rnorm(n, sd = 0.4),
               x3 = f + stats::rnorm(n, sd = 0.4), x4 = stats::rnorm(n),
               Time = factor(t, levels = seq_len(n_t)), Group = factor(rep(c("a", "b"), length.out = n)))
  }))
}

# p-values of the drift table, named by quantity
drift_p <- function(ev)
{
  # rows of the table, without the caption, header and separator
  rows <- strsplit(grep("^\\|", ev$drift.tab, value = TRUE)[-(1:2)], "|", fixed = TRUE)
  p <- as.numeric(trimws(sapply(rows, `[`, 4)))
  quant <- trimws(sapply(rows, `[`, 2))
  stats::setNames(p, quant)
}

test_that("moveplot keeps the time and group variables for evaluation", {
  bp <- biplot(climate_sub(), scaled = TRUE) |> PCA()
  out <- no_plot(moveplot(bp, time.var = "Year", group.var = "Region", move = FALSE))
  expect_s3_class(out, "moveplot")
  expect_equal(out$time.var, "Year")
  expect_equal(out$group.var, "Region")
})

test_that("evaluation adds the per time slice structure, three plots and a drift table to a moveplot object", {
  climate <- climate_sub()
  for(cls in c("PCA", "CVA"))
  {
    bp <- biplot(climate, scaled = TRUE)
    bp <- if(cls == "PCA") PCA(bp) else CVA(bp, classes = climate$Region)
    ev <- evaluation(no_plot(moveplot(bp, time.var = "Year", group.var = "Region", move = FALSE)))
    expect_equal(ev$structure$Year, levels(climate$Year))
    expect_named(ev$structure, c("Year", if(cls == "PCA") "pc1_var" else "cv1_var", "angle_deg",
                                 paste0("load1_", colnames(bp$X))))
    for(pl in c("var.plot", "angle.plot", "loadings.plot")) expect_s3_class(ev[[pl]], "ggplot")
    expect_s3_class(ev$drift.tab, "knitr_kable")
    expect_named(drift_p(ev), names(ev$structure)[-1])
    expect_true(all(ev$structure$angle_deg >= 0 & ev$structure$angle_deg <= 90))
  }
})

test_that("the structure of a time slice is that of a PCA biplot of that slice, aligned to all the data", {
  climate <- climate_sub()
  bp <- biplot(climate, scaled = TRUE) |> PCA()
  ev <- evaluation(no_plot(moveplot(bp, time.var = "Year", group.var = "Region", move = FALSE)))
  slice <- climate[climate$Year == levels(climate$Year)[2], ]
  bp_slice <- biplot(slice, scaled = TRUE) |> PCA()
  expect_equal(ev$structure$pc1_var[2], bp_slice$eigenvalues[1] / sum(bp_slice$eigenvalues))
  load1 <- unlist(ev$structure[2, paste0("load1_", colnames(bp$X))])
  expect_equal(abs(load1), abs(bp_slice$Vr[, 1]), ignore_attr = TRUE)
  expect_gte(sum(load1 * bp$Vr[, 1]), 0)
})

test_that("a time slice spanning the plane of all the data has a zero angle and no drift is found", {
  # every time slice is the same data
  dat <- drift_data(drift = FALSE, n_t = 1)
  dat <- do.call(rbind, lapply(1:5, function(t) transform(dat, Time = factor(t, levels = 1:5))))
  bp <- biplot(dat, scaled = TRUE) |> PCA()
  ev <- evaluation(no_plot(moveplot(bp, time.var = "Time", group.var = "Group", move = FALSE)))
  expect_equal(ev$structure$angle_deg, rep(0, 5), tolerance = 1e-5)
  expect_equal(ev$structure$load1_x1, rep(ev$structure$load1_x1[1], 5))
  expect_false(any(grepl("*", ev$drift.tab, fixed = TRUE)))
})

test_that("the drift test detects a monotone change in the loadings, but not a stable structure", {
  bp_drift <- biplot(drift_data(drift = TRUE), scaled = TRUE) |> PCA()
  ev_drift <- evaluation(no_plot(moveplot(bp_drift, time.var = "Time", group.var = "Group", move = FALSE)))
  expect_lt(drift_p(ev_drift)[["load1_x1"]], 0.05)
  expect_true(all(diff(ev_drift$structure$load1_x1) < 0.1))

  bp_stable <- biplot(drift_data(drift = FALSE), scaled = TRUE) |> PCA()
  ev_stable <- evaluation(no_plot(moveplot(bp_stable, time.var = "Time", group.var = "Group", move = FALSE)))
  expect_gte(drift_p(ev_stable)[["load1_x1"]], 0.05)
})
