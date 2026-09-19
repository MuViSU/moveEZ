data(Africa_climate)
bp <- biplot(Africa_climate, scaled = TRUE) |> PCA()

test_that("non-factor time.var and group.var stop with an informative error", {
  int_year <- Africa_climate
  int_year$Year <- as.integer(as.character(int_year$Year))
  bp_int <- biplot(int_year, scaled = TRUE) |> PCA()
  for(f in list(moveplot, moveplot2, moveplot3))
    expect_error(f(bp_int, time.var = "Year", group.var = "Region", move = FALSE),
                 "must be a factor, not integer.*before calling biplot")

  chr_region <- Africa_climate
  chr_region$Region <- as.character(chr_region$Region)
  bp_chr <- biplot(chr_region, scaled = TRUE) |> PCA()
  for(f in list(moveplot, moveplot2, moveplot3))
    expect_error(f(bp_chr, time.var = "Year", group.var = "Region", move = FALSE),
                 "group.var = \"Region\" must be a factor, not character")
})

test_that("missing or malformed column names stop with an informative error", {
  expect_error(moveplot(bp, time.var = "year", group.var = "Region", move = FALSE),
               "time.var = \"year\" is not a column")
  expect_error(moveplot(bp, time.var = "Year", group.var = "region", move = FALSE),
               "group.var = \"region\" is not a column")
  expect_error(moveplot(bp, time.var = "Year", group.var = NULL, move = FALSE),
               "group.var must be a single column name")
  expect_error(moveplot(bp, time.var = c("Year", "Month"), group.var = "Region", move = FALSE),
               "time.var must be a single column name")
  expect_error(moveplot(Africa_climate, time.var = "Year", group.var = "Region"),
               "must be a biplot object")
})

test_that("missing values introduced after biplot() are caught", {
  bp_na <- bp
  bp_na$raw.X$Year[1] <- NA
  expect_error(check_vars_moveEZ(bp_na, "Year", "Region"), "contains missing values")
})

test_that("unused levels of time.var are dropped", {
  sub <- Africa_climate[Africa_climate$Year != levels(Africa_climate$Year)[1], ]
  bp_sub <- suppressWarnings(biplot(sub, scaled = TRUE)) |> PCA()
  out <- check_vars_moveEZ(bp_sub, "Year", "Region")
  expect_equal(levels(out$raw.X$Year), levels(Africa_climate$Year)[-1])
})

test_that("moveplot3 reports rows removed by biplot() and NAs in target", {
  with_na <- Africa_climate
  with_na[[which(sapply(with_na, is.numeric))[1]]][7] <- NA
  bp_na <- suppressWarnings(biplot(with_na, scaled = TRUE)) |> PCA()
  expect_error(moveplot3(bp_na, time.var = "Year", group.var = "Region", move = FALSE),
               "removed 1 row")

  data(Africa_climate_target)
  target_na <- Africa_climate_target
  target_na[[which(sapply(target_na, is.numeric))[1]]][1] <- NA
  expect_error(moveplot3(bp, time.var = "Year", group.var = "Region", move = FALSE, target = target_na),
               "target contains missing values")
})
