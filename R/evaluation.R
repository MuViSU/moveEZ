# -----------------------------------------------------------------------------------------------------

#' Measures of comparison for move plot 3
#'
#' This function calculates measures of comparison after generalised orthogonal Procrustes Analysis is performed in \code{moveplot3}. Orthogonal Procrustes Analysis is used to compare a target to a testee configuration.
#'
#' @param bp biplot object from moveEZ
#' @param centring logical argument to apply centring or not (default is \code{TRUE})
#'
#' @return
#' \item{PS}{Procrustes Statistic}
#' \item{CC}{Congruence coefficient}
#' \item{AMB}{Absolute Mean Bias}
#' \item{MB}{Mean Bias}
#' \item{RMSB}{Root Mean Squared Bias}
#' \item{Res.SS}{Residual sum of squares}
#' \item{Tot.SS}{Total sum of squares}
#' \item{Fit.SS}{Fitted sum of squares}
#'
#' @examples
#' data(Africa_climate)
#' data(Africa_climate_target)
#' bp <- biplotEZ::biplot(Africa_climate, scaled = TRUE) |> biplotEZ::PCA()
#' bp <- bp |> moveplot3(time.var = "Year", group.var = "Region", hulls = TRUE,
#' move = FALSE, target = NULL) |> evaluation()
#' bp$eval.list
#'
evaluation <- function(bp, centring = TRUE)
{
  if (inherits(bp, "moveplot3")){
  eval.list <- vector("list", length(bp$coord_set))

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
    #centre=T, scale=F results are similar to Cox and Cox, Gower and #Dijkersthuis, Borg and Groenen
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

  CC <- sum(dist(testee) * dist(target))/(sqrt(sum(dist(testee)^2)) * sqrt(sum(dist(target)^2)))
  RMSB <- ((sum(sum((target-testee)^2)))/length(testee))^(0.5)
  MB <- (sum(sum((target-testee)^1)))/length(testee)
  AMB <- (sum(sum(abs(target-testee))))/length(testee)

  REStable <- data.frame(c(PS, CC, AMB, MB, RMSB))
  colnames(REStable)<- paste("Target vs. ",bp$iter_levels[i], sep="")
  rownames(REStable)<- c("PS", "CC", "AMB", "MB", "RMSB")

  eval.list[[i]] <- REStable

  }

  bp$eval.list <- lapply(eval.list, round,4)
} else
  print("Evaulation measures only work for moveplot3().")

    bp

}
