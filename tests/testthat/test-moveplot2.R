climate <- climate_sub()
years <- levels(climate$Year)
bp <- biplot(climate, scaled = TRUE) |> PCA()
out <- no_plot(moveplot2(bp, time.var = "Year", group.var = "Region", move = FALSE))

test_that("moveplot2 fits a separate biplot to every time slice", {
  Vr <- layer_df(out$plot, "GeomSegment")
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
  expect_s3_class(out_cva$within.class.axis.predictivity, "knitr_kable")
  expect_named(out_cva$within.class.sample.predictivity, years)

  # class means of a slice are those of a CVA biplot of that slice only
  slice <- climate[climate$Year == years[2], ]
  cva_slice <- biplot(slice, scaled = TRUE) |> CVA(classes = slice$Region)
  means <- layer_df(out_cva$plot, "GeomPoint")
  expect_equal(as.matrix(means[means$Year == years[2], c("V1", "V2")]), cva_slice$Zmeans, ignore_attr = TRUE)
})

test_that("reflect only reflects the time slices in align.time", {
  refl <- no_plot(moveplot2(bp, time.var = "Year", group.var = "Region", move = FALSE,
                            align.time = years[1], reflect = "xy"))
  Vr <- layer_df(out$plot, "GeomSegment")
  Vr_refl <- layer_df(refl$plot, "GeomSegment")
  first <- Vr$Year == years[1]
  expect_equal(Vr_refl$V1[first], -Vr$V1[first])
  expect_equal(Vr_refl$V2[first], -Vr$V2[first])
  expect_equal(Vr_refl[!first, ], Vr[!first, ])

  # hull vertices, their order changes with the reflection
  Z <- layer_df(out$plot, "GeomPolygon")
  Z_refl <- layer_df(refl$plot, "GeomPolygon")
  first <- Z$Year == years[1]
  expect_equal(sort(Z_refl$V1[Z_refl$Year == years[1]]), sort(-Z$V1[first]))
  expect_equal(sort(Z_refl$V2[Z_refl$Year == years[1]]), sort(-Z$V2[first]))
  expect_equal(Z_refl[Z_refl$Year != years[1], ], Z[!first, ])
})

test_that("reflect follows biplotEZ::reflect(), x reverses the x-axis and y the y-axis", {
  Vr <- layer_df(out$plot, "GeomSegment")
  first <- Vr$Year == years[1]
  refl_x <- layer_df(no_plot(moveplot2(bp, time.var = "Year", group.var = "Region", move = FALSE,
                                       align.time = years[1], reflect = "x"))$plot, "GeomSegment")
  expect_equal(refl_x$V1[first], -Vr$V1[first])
  expect_equal(refl_x$V2[first], Vr$V2[first])

  refl_y <- layer_df(no_plot(moveplot2(bp, time.var = "Year", group.var = "Region", move = FALSE,
                                       align.time = years[1], reflect = "y"))$plot, "GeomSegment")
  expect_equal(refl_y$V1[first], Vr$V1[first])
  expect_equal(refl_y$V2[first], -Vr$V2[first])

  slice <- climate[climate$Year == years[1], ]
  bp_refl <- biplot(slice, scaled = TRUE) |> PCA() |> biplotEZ::reflect("x")
  expect_equal(sign(refl_x$V1[first]), sign(unname(bp_refl$ax.one.unit[, 1])))
})

test_that("every level in align.time is reflected, in the order supplied", {
  Vr <- layer_df(out$plot, "GeomSegment")
  refl <- layer_df(no_plot(moveplot2(bp, time.var = "Year", group.var = "Region", move = FALSE,
                                     align.time = years[c(3, 1)], reflect = c("y", "x")))$plot, "GeomSegment")
  first <- Vr$Year == years[1]
  third <- Vr$Year == years[3]
  expect_equal(refl[first, c("V1", "V2")], transform(Vr[first, c("V1", "V2")], V1 = -V1), ignore_attr = TRUE)
  expect_equal(refl[third, c("V1", "V2")], transform(Vr[third, c("V1", "V2")], V2 = -V2), ignore_attr = TRUE)
  expect_equal(refl[!first & !third, ], Vr[!first & !third, ])
})

test_that("unsuitable align.time and reflect stop with an informative error", {
  expect_error(moveplot2(bp, time.var = "Year", group.var = "Region", move = FALSE,
                         align.time = "1900", reflect = "x"), "align.time must contain levels of time.var")
  expect_error(moveplot2(bp, time.var = "Year", group.var = "Region", move = FALSE,
                         align.time = years[1:2], reflect = "x"), "reflect must be one of")
  expect_error(moveplot2(bp, time.var = "Year", group.var = "Region", move = FALSE,
                         align.time = years[1], reflect = "z"), "reflect must be one of")
})

test_that("time slices with too few observations stop with an informative error", {
  few <- climate[c(1:3, which(climate$Year != years[1])), ]
  bp_few <- biplot(few, scaled = TRUE) |> PCA()
  expect_error(moveplot2(bp_few, time.var = "Year", group.var = "Region", move = FALSE),
               "not enough to construct a biplot")
})
