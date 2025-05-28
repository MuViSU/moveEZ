

#' Title
#'
#' @param bp
#'
#' @returns
#' @noRd
config <- function(bp)
{
  Z <- bp$Z
  Z <- suppressMessages(bind_cols(Z, bp$Xcat))
  colnames(Z)[1:5] <- c("V1","V2","Region","Year","Month")

  Z_tbl <- Z |> mutate(key = interaction(Z$Year, Z$Region))

  # Axes coordinates
  Vr_coords <- axes_coordinates(bp)
  Vr <- bp$Vr
  for(i in 1:6) Vr_coords[[i]] <- cbind(Vr_coords[[i]],var=i)
  Vr_coords <- do.call(rbind, Vr_coords)
  colnames(Vr_coords)[1:3] <- c("V1","V2","tick")
  Vr_coords_tbl <- as_tibble(Vr_coords)


  # C Hulls for points
  chull_reg <- vector("list", 8)
  for(i in 1:length(years))
  {
    idx <- which(Africa_climate2$Year == years[i])

    Y <- Z[idx,]

    chull_reg_yearly <- vector("list", 10)
    for(j in 1:10)
    {
      temp <- which(Y[,3] == levels(Africa_climate2$Region)[j])
      chull_reg_yearly[[j]] <- Y[temp,][chull(Y[temp,]),]
      chull_reg[[i]][[j]] <- chull_reg_yearly[[j]]
    }
    chull_reg[[i]] <- do.call(rbind,chull_reg[[i]])
  }

  chull_reg <- do.call(rbind,chull_reg)

  colnames(chull_reg)[1:2] <- c("V1","V2")

  chull_reg <- chull_reg |>
    mutate(Region = as.factor(Region))

}
