climate <- climate_sub()
years <- levels(climate$Year)
bp <- biplot(climate, scaled = TRUE) |> PCA()
out <- no_plot(moveplot2(bp, time.var = "Year", group.var = "Region", move = FALSE))

test_that("moveplot2 fits a separate biplot to every time slice", {
  expect_s3_class(out, c("biplot", "PCA"), exact = TRUE)
  expect_s3_class(out$plot, "ggplot")
  expect_equal(geoms(out$plot), c("GeomSegment", "GeomText", "GeomPolygon"))

  Vr <- out$plot$layers[[1]]$data
  expect_equal(nrow(Vr), length(years) * ncol(bp$X))
  expect_equal(levels(Vr$Year), years)

  # variable vectors of a slice are those of a PCA biplot of that slice only
  slice <- climate[climate$Year == years[2], ]
  bp_slice <- biplot(slice, scaled = TRUE) |> PCA()
  expect_equal(as.matrix(Vr[Vr$Year == years[2], c("V1", "V2")]), bp_slice$Vr, ignore_attr = TRUE)
})

test_that("fit measures are reported per time slice", {
  expect_s3_class(out$quality, "knitr_kable")
  expect_s3_class(out$axis.predictivity, "knitr_kable")
  for(y in years)
  {
    expect_true(any(grepl(y, out$quality, fixed = TRUE)))
    expect_true(any(grepl(y, out$axis.predictivity, fixed = TRUE)))
  }
  for(v in colnames(bp$X)) expect_true(any(grepl(v, out$axis.predictivity, fixed = TRUE)))

  slice <- climate[climate$Year == years[1], ]
  qual <- (biplot(slice, scaled = TRUE) |> PCA() |> fit.measures())$quality
  expect_true(any(grepl(format(round(qual, 3), nsmall = 3), out$quality, fixed = TRUE)))
})

test_that("CVA biplots report the within class fit measures", {
  cva <- biplot(climate, scaled = TRUE) |> CVA(classes = climate$Region)
  out_cva <- no_plot(moveplot2(cva, time.var = "Year", group.var = "Region", move = FALSE))
  expect_equal(geoms(out_cva$plot), c("GeomSegment", "GeomText", "GeomPolygon", "GeomPoint"))
  expect_s3_class(out_cva$within.class.axis.predictivity, "knitr_kable")
  expect_named(out_cva$within.class.sample.predictivity, years)
  expect_equal(nrow(out_cva$plot$layers[[4]]$data), length(years) * nlevels(climate$Region))
})

test_that("reflect only reflects the time slices in align.time", {
  refl <- no_plot(moveplot2(bp, time.var = "Year", group.var = "Region", move = FALSE,
                            align.time = years[1], reflect = "xy"))
  Vr <- out$plot$layers[[1]]$data
  Vr_refl <- refl$plot$layers[[1]]$data
  first <- Vr$Year == years[1]
  expect_equal(Vr_refl$V1[first], -Vr$V1[first])
  expect_equal(Vr_refl$V2[first], -Vr$V2[first])
  expect_equal(Vr_refl[!first, ], Vr[!first, ])

  # hull vertices, their order changes with the reflection
  Z <- out$plot$layers[[3]]$data
  Z_refl <- refl$plot$layers[[3]]$data
  first <- Z$Year == years[1]
  expect_equal(sort(Z_refl$V1[Z_refl$Year == years[1]]), sort(-Z$V1[first]))
  expect_equal(sort(Z_refl$V2[Z_refl$Year == years[1]]), sort(-Z$V2[first]))
  expect_equal(Z_refl[Z_refl$Year != years[1], ], Z[!first, ])
})

test_that("time slices with too few observations stop with an informative error", {
  few <- climate[c(1:3, which(climate$Year != years[1])), ]
  bp_few <- biplot(few, scaled = TRUE) |> PCA()
  expect_error(moveplot2(bp_few, time.var = "Year", group.var = "Region", move = FALSE),
               "not enough to construct a biplot")
})
