climate <- climate_sub()
bp <- biplot(climate, scaled = TRUE) |> PCA()

test_that("samples and variables plotted are those of the biplot", {
  out <- no_plot(moveplot(bp, time.var = "Year", group.var = "Region", move = FALSE, hulls = FALSE))
  expect_equal(out$Z, bp$Z)
  expect_equal(as.matrix(layer_df(out$plot, "GeomPoint")[, c("V1", "V2")]), bp$Z, ignore_attr = TRUE)
  expect_equal(as.matrix(layer_df(out$plot, "GeomSegment")[, c("V1", "V2")]), bp$Vr, ignore_attr = TRUE)
})

test_that("which selects groups and label.vars labels the samples", {
  out <- no_plot(moveplot(bp, time.var = "Year", group.var = "Region", move = FALSE, hulls = FALSE,
                          which = c(1, 3), label.vars = c("Region", "Month")))
  keep <- levels(climate$Region)[c(1, 3)]
  pts <- layer_df(out$plot, "GeomPoint")
  expect_equal(levels(pts$Region), keep)
  expect_equal(as.matrix(pts[, c("V1", "V2")]), bp$Z[climate$Region %in% keep, ], ignore_attr = TRUE)
  expect_equal(pts$.label, paste(pts$Region, pts$Month, sep = ":"))
})

test_that("groups too small for a hull are drawn as points", {
  first <- which(climate$Year == levels(climate$Year)[1] & climate$Region == levels(climate$Region)[1])
  few <- climate[-first[-(1:2)], ]
  bp_few <- biplot(few, scaled = TRUE) |> PCA()
  out <- no_plot(moveplot(bp_few, time.var = "Year", group.var = "Region", move = FALSE))
  pts <- layer_df(out$plot, "GeomPoint")
  expect_equal(as.matrix(pts[, c("V1", "V2")]), bp_few$Z[1:2, ], ignore_attr = TRUE)
  # hulls of all other group and time combinations are still constructed
  hulls <- unique(layer_df(out$plot, "GeomPolygon")[, c("Year", "Region")])
  expect_equal(nrow(hulls), nlevels(few$Year) * nlevels(few$Region) - 1)
})

test_that("CVA biplots use the group means per time slice", {
  cva <- biplot(climate, scaled = TRUE) |> CVA(classes = climate$Region)
  out <- no_plot(moveplot(cva, time.var = "Year", group.var = "Region", move = FALSE))
  means <- layer_df(out$plot, "GeomPoint")
  expect_equal(nrow(means), nlevels(climate$Year) * nlevels(climate$Region))
  for(i in c(1, nrow(means)))
  {
    idx <- climate$Year == means$Year[i] & climate$Region == means$Region[i]
    expect_equal(c(means$V1_mean[i], means$V2_mean[i]), unname(colMeans(cva$Z[idx, ])))
  }
  expect_equal(as.matrix(layer_df(out$plot, "GeomSegment")[, c("V1", "V2")]), cva$Mr, ignore_attr = TRUE)
})
