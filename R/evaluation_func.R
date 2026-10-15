#' Measures of comparison for move plot 3
#'
#' This function calculates measures of comparison after generalised orthogonal Procrustes Analysis
#' is performed in \code{moveplot3}. Orthogonal Procrustes Analysis is used to compare a target to a testee configuration.
#' The following measures are calculate: Procrustes Statistic (PS), Congruence Coefficient (CC), Absolute Mean Bias (AMB),
#' Mean Bias (MB) and Root Mean Squared Bias (RMSB).
#'
#' For \code{moveplot}, the function evaluates whether the fixed frame of \code{moveplot()}, where the variable
#' vectors are computed once on all the data, is adequate, or whether a biplot should be constructed for each time
#' slice with \code{moveplot2()} or \code{moveplot3()}. A PCA (or CVA) biplot is fitted to each level of the time
#' variable and compared with the biplot of all the data, see Details.
#'
#'
#' @param bp biplot object from \code{moveEZ}
#' @param centring logical argument to apply centring or not (default is \code{TRUE})
#'
#' @details
#' For \code{moveplot}, the following are computed for each level of the time variable, in the order of its levels:
#' \itemize{
#'   \item the proportion of variance explained by the first dimension of the biplot of that time slice,
#'   \item the largest principal angle (in degrees) between the two dimensional subspace of the biplot of that time
#'     slice and that of the biplot of all the data. Zero means that the time slice spans the same plane,
#'   \item the loadings of the variables on the first dimension. The sign of each eigenvector is arbitrary, so the
#'     dimensions of each time slice are reflected to point in the same direction as those of the biplot of all the
#'     data (as \code{auto.align} in \code{moveplot2()}) before the loadings are compared.
#' }
#' A Spearman rank correlation test between the order of the time levels and each of these quantities tests for a
#' monotone drift over time. A p-value of 0.05 or more fails to reject zero correlation: there is no evidence that
#' the structure of the biplot changes over time, the fixed frame of \code{moveplot()} is adequate, and
#' \code{moveplot2()} or \code{moveplot3()} are not needed. A p-value below 0.05 indicates a drift, and a biplot
#' should be constructed for each time slice. The test only detects monotone trends; large but non-monotone
#' changes are visible in the plots.
#'
#' @returns
#' \item{eval.tab}{Returns a table of the measures of comparison for each level of the time variable compared to the target.}
#' \item{fit.plot}{Returns a line plot with the fit measures that are bounded between zero and one: PS and CC. A small PS value and large CC value indicate good fit.}
#' \item{bias.plot}{Returns a line plot with bias measures that are unbounded: AMB, MB and RMSB. Small values indicate low bias.}
#' \item{structure}{For \code{moveplot}, a data frame with the proportion of variance of the first dimension, the
#'   principal angle and the loadings on the first dimension for each level of the time variable.}
#' \item{var.plot}{For \code{moveplot}, a line plot of the proportion of variance of the first dimension over time.}
#' \item{angle.plot}{For \code{moveplot}, a line plot of the principal angle with the biplot of all the data over time.}
#' \item{loadings.plot}{For \code{moveplot}, a line plot of the loadings of the variables on the first dimension over time.}
#' \item{drift.tab}{For \code{moveplot}, a table of the Spearman rank correlations (rho) of each quantity with time,
#'   their p-values and whether they are significant at the 5% level (*).}
#'
#' @export
#'
#' @examples
#' data(Africa_climate)
#' data(Africa_climate_target)
#' bp <- biplotEZ::biplot(Africa_climate, scaled = TRUE) |> biplotEZ::PCA()
#' results <- bp |> moveplot3(time.var = "Year", group.var = "Region", hulls = TRUE,
#' move = FALSE, target = NULL) |> evaluation()
#' results$eval.tab
#' results$fit.plot
#' results$bias.plot
#'
#' data(Africa_climate)
#' data(Africa_climate_target)
#' bp <- biplotEZ::biplot(Africa_climate, scaled = TRUE) |> biplotEZ::PCA()
#' results <- bp |> moveplot3(time.var = "Year", group.var = "Region", hulls = TRUE,
#' move = FALSE, target = Africa_climate_target) |> evaluation()
#' results$eval.tab
#' results$fit.plot
#' results$bias.plot
#'
#' # Should a biplot be constructed for each time slice?
#' bp <- biplotEZ::biplot(Africa_climate, scaled = TRUE) |> biplotEZ::PCA()
#' results <- bp |> moveplot(time.var = "Year", group.var = "Region", hulls = TRUE,
#' move = FALSE) |> evaluation()
#' results$drift.tab
#' results$var.plot
#' results$angle.plot
#' results$loadings.plot
#'
evaluation <- function(bp, centring = TRUE)
{
  if (inherits(bp, "moveplot3")){
    eval.tab <- vector("list", length(bp$coord_set))

    target <- bp$G.target

    for (i in 1:length(bp$coord_set))
    {

      n.Y <- nrow(target)
      p.Y <- ncol(target)
      target <- as.matrix(target)

      testee <- bp$coord_set[[i]]
      n.X <- nrow(testee)
      p.X <- ncol(testee)
      testee <- as.matrix(testee)

      if(!centring)
      {
        testee <- testee
        target <- target
      }
      else
      {
        testee <- scale(testee, TRUE, FALSE)
        #centre=T, scale=F results are similar to Cox and Cox, Gower and
        #Dijkersthuis, Borg and Groenen
        target <- scale(target, TRUE, FALSE)
      }

      #transformations
      C.mat <- t(target)%*%testee
      svd.C <- svd(C.mat)
      A.mat <- svd.C[[3]]%*%t(svd.C[[2]])
      s.fact <- sum(diag(t(target)%*%testee%*%A.mat))/sum(diag(t(testee)%*%testee))
      #Gower and Dijksterhuis P32
      b.fact <- as.vector(1/n.Y * t(target - s.fact * testee %*% A.mat)%*%rep(1,n.Y))
      X.new <- b.fact + s.fact*testee%*%A.mat
      Res.SS <- sum(diag(t(((s.fact*testee%*%A.mat)-target))%*%((s.fact*testee%*%A.mat)-target)))
      Tot.SS <- s.fact^2*sum(diag(t(testee)%*%testee))+sum(diag(t(target)%*%target))
      Fit.SS <- 2*s.fact*sum(diag(svd.C[[1]]))

      PS <- Res.SS/sum(diag(t(target)%*%target))
      CC <- sum(stats::dist(testee) * stats::dist(target))/(sqrt(sum(stats::dist(testee)^2)) * sqrt(sum(stats::dist(target)^2)))
      RMSB <- ((sum(sum((target-testee)^2)))/length(testee))^(0.5)
      MB <- (sum(sum((target-testee)^1)))/length(testee)
      AMB <- (sum(sum(abs(target-testee))))/length(testee)

      REStable <- data.frame(c(PS, CC, AMB, MB, RMSB))
      colnames(REStable) <- paste("Target vs. ",bp$iter_levels[i], sep="")
      rownames(REStable)<- c("PS", "CC", "AMB", "MB", "RMSB")

      eval.tab[[i]] <- REStable

    }

    bias_meas <- c("AMB", "MB", "RMSB")
    fit_meas <- c("PS", "CC")

    eval_df <- do.call(rbind, lapply(eval.tab, function(x) {
      year <- as.numeric(gsub("Target vs. ", "", colnames(x)))
      data.frame(
        Year = year,
        Measure = rownames(x),
        Value = as.numeric(x[,1]),
        row.names = NULL
      )
    }))

    eval.tab <- eval.tab |> purrr::compact() |>
      purrr::map_dfr(~ as.data.frame(t(.x)), .id = NULL) |>
      dplyr::mutate(dplyr::across(dplyr::where(is.numeric), ~ round(.x, 3))) |>
      knitr::kable(align = "c", caption = "Measures of comparison")

    fit.plot <- ggplot() +
      ggplot2::geom_line(data = eval_df |> dplyr::filter(Measure  %in% fit_meas),
                         aes(x = Year, y = Value, color = Measure, group = Measure), linewidth = 1) +
      labs(x = "Year", y = "Value", title = "Evaluation Metrics over Time") +
      ggplot2::theme_minimal()

    bias.plot <- ggplot() +
      ggplot2::geom_line(data = eval_df |> dplyr::filter(Measure  %in% bias_meas),
                         aes(x = Year, y = Value, color = Measure, group = Measure), linewidth = 1) +
      labs(x = "Year", y = "Value", title = "Evaluation Metrics over Time") +
      ggplot2::theme_minimal()

    bp$bias.plot <- bias.plot
    bp$fit.plot <- fit.plot
    bp$eval.tab <- eval.tab
    bp

  } else if (inherits(bp, "moveplot")) {

    time.var <- bp$time.var
    tvi <- base::which(colnames(bp$raw.X) == time.var)
    gvi <- base::which(colnames(bp$raw.X) == bp$group.var)
    iter_levels <- levels(bp$raw.X[[tvi]])
    is_cva <- inherits(bp, "CVA")

    if(any(table(bp$raw.X[[tvi]]) < 4))
      stop("Number of observations per time slice not enough to construct a biplot for each time slice.")

    # Reference: the biplot of all the data
    V_ref <- if(is_cva) bp$Mr[, 1:2] else bp$Vr[, 1:2]
    Q_ref <- qr.Q(qr(V_ref))
    dim_lab <- if(is_cva) "CV1" else "PC1"

    structure_list <- vector("list", length(iter_levels))
    for (i in seq_along(iter_levels))
    {
      temp <- bp$raw.X[bp$raw.X[[tvi]] == iter_levels[i], ]
      if(is_cva) {
        bp_i <- biplotEZ::biplot(temp, scaled = bp$scaled) |> biplotEZ::CVA(classes = temp[[gvi]])
        V_i <- bp_i$Mr[, 1:2]
      } else {
        bp_i <- biplotEZ::biplot(temp, scaled = bp$scaled) |> biplotEZ::PCA()
        V_i <- bp_i$Vr[, 1:2]
      }

      # Sign indeterminacy: reflect the dimensions pointing away from the reference.
      # The subspace angle is unaffected, the loadings are.
      V_i <- V_i %*% diag(ifelse(colSums(V_i * V_ref) < 0, -1, 1))

      # largest principal angle between the planes of the time slice and of all the data
      sv <- svd(t(Q_ref) %*% qr.Q(qr(V_i)))$d

      structure_list[[i]] <- data.frame(time = iter_levels[i],
                                        var1 = bp_i$eigenvalues[1] / sum(bp_i$eigenvalues),
                                        angle = acos(min(1, max(sv[2], 0))) * 180 / pi,
                                        t(stats::setNames(V_i[, 1], paste0("load1_", colnames(bp$X)))),
                                        check.names = FALSE)
    }
    structure_df <- do.call(rbind, structure_list)
    names(structure_df)[1:3] <- c(time.var, paste0(tolower(dim_lab), "_var"), "angle_deg")

    # Is the drift monotone? Spearman correlation with the order of the time levels
    order_t <- seq_along(iter_levels)
    drift <- do.call(rbind, lapply(names(structure_df)[-1], function(v) {
      ct <- suppressWarnings(stats::cor.test(order_t, structure_df[[v]], method = "spearman"))
      data.frame(Quantity = v, rho = unname(ct$estimate), p = ct$p.value)
    }))
    # a quantity that is constant over time has no correlation (NA)
    drift$sig <- ifelse(!is.na(drift$p) & drift$p < 0.05, "*", "-")

    # time on a numeric axis when the levels are numbers (e.g. years), else in the order of the levels
    time_num <- suppressWarnings(as.numeric(iter_levels))
    if(anyNA(time_num)) time_num <- order_t
    time_scale <- ggplot2::scale_x_continuous(breaks = if(identical(time_num, order_t)) order_t else ggplot2::waiver(),
                                              labels = if(identical(time_num, order_t)) iter_levels else ggplot2::waiver())
    plot_df <- structure_df
    plot_df$time_num <- time_num

    var.plot <- ggplot(plot_df, aes(x = .data$time_num, y = .data[[names(structure_df)[2]]])) +
      ggplot2::geom_line() +
      geom_point() +
      time_scale +
      labs(x = time.var, y = "Proportion of variance", title = paste(dim_lab, "variance")) +
      ggplot2::theme_minimal()

    angle.plot <- ggplot(plot_df, aes(x = .data$time_num, y = .data$angle_deg)) +
      ggplot2::geom_line() +
      geom_point() +
      time_scale +
      labs(x = time.var, y = "Principal angle (degrees)",
           title = "Subspace angle vs biplot of all the data") +
      ggplot2::theme_minimal()

    load1_long <- do.call(rbind, lapply(colnames(bp$X), function(v) {
      data.frame(time_num = time_num, variable = v, loading = structure_df[[paste0("load1_", v)]])
    }))

    loadings.plot <- ggplot(load1_long, aes(x = .data$time_num, y = .data$loading, colour = .data$variable)) +
      ggplot2::geom_line() +
      time_scale +
      labs(x = time.var, y = paste(dim_lab, "loading"), title = paste(dim_lab, "loadings"), colour = NULL) +
      ggplot2::theme_minimal()

    bp$structure <- structure_df
    bp$var.plot <- var.plot
    bp$angle.plot <- angle.plot
    bp$loadings.plot <- loadings.plot
    bp$drift.tab <- drift |>
      dplyr::mutate(dplyr::across(dplyr::where(is.numeric), ~ round(.x, 3))) |>
      knitr::kable(align = "lccc", caption = "Spearman drift test")
    bp

  } else
    print("Evaluation measures can only be applied for moveplot() and moveplot3().")

  bp

}

