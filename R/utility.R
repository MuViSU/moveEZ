#' Provide axes coordinates
#'
#' @param bp Object
#' @param which.var which variable(s) to find coordinates
#'
#' @returns Axes coordinates
#'
axes_moveEZ <- function(bp,which.var)
{
  slope <- c()
  intcpt <- c()
  z.axes <- lapply(1:bp$p, .calibrate.axis, bp$X, bp$means, bp$sd,
                     bp$ax.one.unit,1:bp$p,rep(20,bp$p),
                     rep(0,bp$p), rep(0,bp$p))
  for(i in 1:bp$p) slope[i] <- z.axes[[i]][[3]]
  for(i in 1:bp$p) intcpt[i] <- z.axes[[i]][[2]]
  for(i in 1:length(z.axes)) z.axes[[i]] <- z.axes[[i]][[1]]

  return(list(z.axes=z.axes,slope=slope,intcpt=intcpt))
}

#' Calibrate axis
#'
#' @param j j
#' @param Xhat Xhat
#' @param means means
#' @param sd sd
#' @param axes.rows axes.rows
#' @param ax.which ax.which
#' @param ax.tickvec ax.tickvec
#' @param ax.orthogxvec ax.orthogxvec
#' @param ax.orthogyvec ax.orothogyvec
#'
#' @returns Calibrated axes
#'
.calibrate.axis <- function (j, Xhat, means, sd,
                             axes.rows, ax.which, ax.tickvec,
                             ax.orthogxvec, ax.orthogyvec)
{

  ax.num <- ax.which[j]
  tick <- ax.tickvec[j]
  ax.direction <- axes.rows[ax.num,]
  r <- ncol(axes.rows)
  ax.orthog <- rbind(ax.orthogxvec, ax.orthogyvec)
  if (nrow(ax.orthog) < r)    ax.orthog <- rbind(ax.orthog, 0)
  if (nrow(axes.rows) > 1)    phi.vec <- diag(1 / diag(axes.rows %*% t(axes.rows))) %*% axes.rows %*% ax.orthog[, ax.num] else
    phi.vec <- (1 / (axes.rows %*% t(axes.rows))) %*% axes.rows %*% ax.orthog[, ax.num]


  std.ax.tick.label <- pretty(range(Xhat[, ax.num]), n = tick)
  std.range <- range(std.ax.tick.label)
  std.ax.tick.label.min <-  std.ax.tick.label - (std.range[2] - std.range[1])
  std.ax.tick.label.max <-  std.ax.tick.label + (std.range[2] - std.range[1])
  std.ax.tick.label <-  c(std.ax.tick.label,  std.ax.tick.label.min, std.ax.tick.label.max)
  interval <- (std.ax.tick.label - means[ax.num]) / sd[ax.num]
  axis.vals <- sort(unique(interval))


  number.points <- length(axis.vals)
  axis.points <- matrix(0, nrow = number.points, ncol = r)
  for (i in 1:r)
    axis.points[, i] <-  ax.orthog[i, ax.num] + (axis.vals - phi.vec[ax.num]) * ax.direction[i]
  axis.points <- cbind(axis.points, axis.vals * sd[ax.num] + means[ax.num])

  #slope = delta y / delta x of two datapoints
  slope <- (axis.points[1, 2] - axis.points[2, 2]) / (axis.points[1, 1] - axis.points[2, 1])
  #if slope is infinite then all x-values are same
  v <- NULL
  if (is.na(slope)){
    v <- axis.points[1, 1]
    slope = NULL
  } else if (abs(slope) == Inf) {  v <- axis.points[1, 1]
  slope = NULL
  }

  #y=mx+c... c=y-mx
  intercept <- axis.points[1, 2] - slope * axis.points[1, 1]

  details <- list(a = intercept, b = slope, v = v)
  retvals <- list(coords = axis.points, a = intercept, b = slope, v = v)
  return(retvals)
}

#' Convex hulls per group
#'
#' @description Computes the convex hull of each group for a single level of
#'   the time variable. A hull needs at least three non-collinear observations;
#'   groups that do not meet this are left out of the hull data and returned
#'   separately so that they can be drawn as points instead.
#'
#' @param Y tibble of sample coordinates (columns V1, V2) and grouping columns
#' @param group.var group variable
#' @param group_levels levels of group.var to construct hulls for
#'
#' @returns A list with \code{hull}, the rows of \code{Y} that form the hull
#'   vertices of each group, and \code{points}, the rows of \code{Y} for groups
#'   with too few observations to construct a hull.
#'
chull_moveEZ <- function(Y, group.var, group_levels)
{
  hull <- vector("list", length(group_levels))
  pts <- vector("list", length(group_levels))
  for(j in seq_along(group_levels))
  {
    idx <- base::which(Y[[group.var]] == group_levels[j]) # index of the group var
    Yj <- Y[idx,]
    vertices <- if(length(idx) >= 3) grDevices::chull(Yj) else integer(0)
    if(length(vertices) >= 3)
      hull[[j]] <- Yj[vertices,]
    else
      pts[[j]] <- Yj
  }
  # Y[0,] keeps the column structure when every group falls in one branch
  list(hull = do.call(rbind, c(list(Y[0,]), hull)),
       points = do.call(rbind, c(list(Y[0,]), pts)))
}

#' Check the time and group variables
#'
#' @description Validates \code{time.var} and \code{group.var} before any
#'   plotting is attempted, so that unsuitable input stops with an informative
#'   error instead of failing downstream. Both must name factor columns of the
#'   data supplied to \code{biplotEZ::biplot()}, without missing values.
#'
#' @param bp biplot object from biplotEZ
#' @param time.var time variable
#' @param group.var group variable
#'
#' @returns \code{bp}, with unused levels of \code{time.var} dropped from
#'   \code{bp$raw.X}.
#'
check_vars_moveEZ <- function(bp, time.var, group.var)
{
  if(!inherits(bp, "biplot")) stop("bp must be a biplot object created with biplotEZ::biplot().")
  if(!is.data.frame(bp$raw.X))
    stop("The data supplied to biplot() must be a data frame containing time.var and group.var as factor columns.")

  vars <- list(time.var = time.var, group.var = group.var)
  for(arg in names(vars))
  {
    v <- vars[[arg]]
    if(!is.character(v) || length(v) != 1 || is.na(v))
      stop(arg, " must be a single column name given as a character string.")
    if(!(v %in% colnames(bp$raw.X)))
      stop(arg, " = \"", v, "\" is not a column of the data supplied to biplot().")

    x <- bp$raw.X[[v]]
    if(!is.factor(x))
    {
      # biplotEZ::biplot() uses every numeric column as a biplot variable
      if(is.numeric(x))
        stop(arg, " = \"", v, "\" must be a factor, not ", class(x)[1], ". biplot() has treated it as ",
             "a numeric variable of the biplot, so convert it before calling biplot(), e.g. data$",
             v, " <- factor(data$", v, ").")
      stop(arg, " = \"", v, "\" must be a factor, not ", class(x)[1], ". Convert it before calling ",
           "biplot(), e.g. data$", v, " <- factor(data$", v, "), specifying levels to control the ordering.")
    }
    # biplot() removes rows with missing values, NAs here mean bp was altered afterwards
    if(anyNA(x)) stop(arg, " = \"", v, "\" contains missing values. Remove or impute these before calling biplot().")
  }

  # levels without observations (e.g. after subsetting or NA removal) cannot form a time slice
  bp$raw.X[[time.var]] <- droplevels(bp$raw.X[[time.var]])

  bp
}
