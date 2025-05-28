#' Move plot
#'
#' Create animated biplot
#'
#' @param bp
#'
#' @returns
#' @export
#'
#' @examples
moveplot <- function(bp,time.var="Year")
{
  Xcat <- bp$Xcat
  tvi <- which(colnames(bp$Xcat) == time.var)
  iterations <- nlevels(bp$Xcat[,tvi])
  iter_levels <- levels(bp$Xcat[,tvi])

  # Samples
  Z <- bp$Z
  Z <- suppressMessages(dplyr::bind_cols(Z, Xcat))
  colnames(Z)[1:2] <- c("V1","V2")
  Z_tbl <- Z

  # Axes coordinates
  Vr_coords <- biplotEZ::axes_coordinates(bp)
  for(i in 1:bp$p) Vr_coords[[i]] <- cbind(Vr_coords[[i]],var=i)
  Vr_coords <- do.call(rbind, Vr_coords)
  colnames(Vr_coords)[1:3] <- c("V1","V2","tick")
  Vr_coords_tbl <- dplyr::as_tibble(Vr_coords)

  # C Hulls for points
  chull_reg <- vector("list", iterations)
  for(i in 1:iterations)
  {
    idx <- which(bp$Xcat[,tvi] == iter_levels[i])

    Y <- Z[idx,]

    # which(colnames(Xcat) == bp$group.aes)
    chull_reg_iter <- vector("list", length(bp$g.names))
    for(j in 1:length(bp$g.names))
    {
      temp <- which(Y[,5] == bp$g.names[j]) # index of the time var
      chull_reg_iter[[j]] <- Y[temp,][chull(Y[temp,]),]
      chull_reg[[i]][[j]] <- chull_reg_iter[[j]]
    }
    chull_reg[[i]] <- do.call(rbind,chull_reg[[i]])
  }

  chull_reg <- do.call(rbind,chull_reg)
  chull_reg <- dplyr::as_tibble(chull_reg)

  # colnames(chull_reg)[1:2] <- c("V1","V2")

  ggplot() +
    # Axes
    geom_point(data=Vr_coords_tbl,
                        aes(x=V1,y=V2),size=1,colour="grey90") +
    geom_line(data = Vr_coords_tbl,
              aes(x = V1, y = V2, group = var),colour = "#d9d9d9") +
    # Markers on axes
    geom_text(data=Vr_coords_tbl,
              aes(x=V1,y=V2,label=tick),size=2,colour="black") +
    # Sample polygons
    geom_polygon(data = chull_reg,
                          aes(x=V1, y=V2,group = Region,fill = Region), alpha=0.5) +
    transition_states(chull_reg$Year, # fix here
                      transition_length = 2,
                      state_length = 1) +
    labs(title = 'Year: {closest_state}',x="",y="") +
    theme_classic() +
    theme(axis.ticks = element_blank(),
                   axis.text.x = element_blank(),
                   axis.text.y = element_blank())
}
