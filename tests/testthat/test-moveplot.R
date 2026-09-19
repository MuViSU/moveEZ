climate <- climate_sub()
bp <- biplot(climate, scaled = TRUE) |> PCA()

test_that("moveplot returns the biplot object with a faceted hull plot", {
  out <- no_plot(moveplot(bp, time.var = "Year", group.var = "Region", move = FALSE))
  expect_s3_class(out, c("biplot", "PCA"), exact = TRUE)
  expect_s3_class(out$plot, "ggplot")
  expect_equal(out$Z, bp$Z)
  expect_equal(geoms(out$plot), c("GeomSegment", "GeomText", "GeomPolygon"))

  # one arrow per variable in every facet, one facet per level of time.var
  expect_equal(nrow(out$plot$layers[[1]]$data), ncol(bp$X))
  expect_equal(nrow(ggplot2::layer_data(out$plot, 1)), ncol(bp$X) * nlevels(climate$Year))
  expect_equal(nlevels(ggplot2::layer_data(out$plot, 3)$PANEL), nlevels(climate$Year))
})

test_that("hulls = FALSE plots every sample as a point", {
  out <- no_plot(moveplot(bp, time.var = "Year", group.var = "Region", move = FALSE, hulls = FALSE))
  expect_equal(geoms(out$plot), c("GeomSegment", "GeomText", "GeomPoint"))
  expect_equal(nrow(ggplot2::layer_data(out$plot, 3)), nrow(climate))
})

test_that("which selects groups and label.vars labels the samples", {
  out <- no_plot(moveplot(bp, time.var = "Year", group.var = "Region", move = FALSE, hulls = FALSE,
                          which = c(1, 3), label.vars = c("Region", "Month")))
  keep <- levels(climate$Region)[c(1, 3)]
  pts <- out$plot$layers[[3]]$data
  expect_equal(levels(pts$Region), keep)
  expect_equal(nrow(pts), sum(climate$Region %in% keep))

  expect_equal(geoms(out$plot)[4], "GeomText")
  expect_equal(out$plot$layers[[4]]$data$.label,
               paste(pts$Region, pts$Month, sep = ":"))
})

test_that("scale.var scales the variable vectors", {
  out1 <- no_plot(moveplot(bp, time.var = "Year", group.var = "Region", move = FALSE, scale.var = 1))
  out5 <- no_plot(moveplot(bp, time.var = "Year", group.var = "Region", move = FALSE, scale.var = 5))
  expect_equal(ggplot2::layer_data(out5$plot, 1)$xend, 5 * ggplot2::layer_data(out1$plot, 1)$xend)
  # the arrows are repeated in every facet
  expect_equal(ggplot2::layer_data(out1$plot, 1)$xend, rep(unname(bp$Vr[, 1]), nlevels(climate$Year)))
})

test_that("groups too small for a hull are drawn as points", {
  first <- which(climate$Year == levels(climate$Year)[1] & climate$Region == levels(climate$Region)[1])
  few <- climate[-first[-(1:2)], ]
  bp_few <- biplot(few, scaled = TRUE) |> PCA()
  out <- no_plot(moveplot(bp_few, time.var = "Year", group.var = "Region", move = FALSE))
  expect_equal(geoms(out$plot), c("GeomSegment", "GeomText", "GeomPolygon", "GeomPoint"))
  expect_equal(nrow(out$plot$layers[[4]]$data), 2)
  # hulls of all other group and time combinations are still drawn
  hulls <- unique(out$plot$layers[[3]]$data[, c("Year", "Region")])
  expect_equal(nrow(hulls), nlevels(few$Year) * nlevels(few$Region) - 1)
})

test_that("CVA biplots add the group means per time slice", {
  cva <- biplot(climate, scaled = TRUE) |> CVA(classes = climate$Region)
  out <- no_plot(moveplot(cva, time.var = "Year", group.var = "Region", move = FALSE))
  expect_s3_class(out, "CVA")
  expect_equal(geoms(out$plot), c("GeomSegment", "GeomText", "GeomPolygon", "GeomPoint"))
  means <- out$plot$layers[[4]]$data
  expect_equal(nrow(means), nlevels(climate$Year) * nlevels(climate$Region))

  one <- climate$Year == levels(climate$Year)[1] & climate$Region == levels(climate$Region)[1]
  expect_equal(means$V1_mean[1], mean(cva$Z[one, 1]))
})

test_that("move = TRUE builds a gganimate object", {
  skip_on_cran()
  anim <- NULL
  testthat::local_mocked_bindings(animate = function(plot, ...) { anim <<- plot; invisible(NULL) },
                                  .package = "gganimate")
  utils::capture.output(out <- no_plot(moveplot(bp, time.var = "Year", group.var = "Region", move = TRUE)))
  expect_s3_class(anim, "gganim")
  expect_s3_class(out$plot, "gganim")
})
