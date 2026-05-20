moveplot2_test <- function(bp, time.var, group.var, move = TRUE,hulls = TRUE,
                      scale.var = 5, align.time = NA, reflect = NA)
{

  if(!is.null(group.var)) bp$group.aes <- bp$raw.X[,which(colnames(bp$raw.X) == group.var)] else
    bp$group.aes = NULL

  tvi <- which(colnames(bp$raw.X) == time.var)
  gvi <- which(colnames(bp$raw.X) == group.var)

  if(any(table(bp$raw.X[[tvi]]) < 4)) stop("Number of observations per time slice not enough to construct a biplot. \n Use moveplot()")

  iterations <- nlevels(bp$raw.X[[tvi]])
  iter_levels <- levels(bp$raw.X[[tvi]])

  group_levels <- levels(bp$raw.X[[gvi]])

  # Group colours

  #biplotEZ default colour palette
  EZcols <- c("#0000FFFF", "#00FF00FF", "#FFD700FF", "#00FFFFFF", "#FF00FFFF",
              "#000000FF", "#FF0000FF", "#BEBEBEFF", "#A020F0FF", "#FA8072FF")

  if(is.null(bp$samples))
  { #biplotEZ::samples() not utilised
    samp_pch <- c(rep(19, bp$n))
    samp_opac <- 0.8
    group_palette <- stats::setNames(scales::hue_pal()(length(group_levels)), group_levels)
  } else {
    samp_opac <- bp$samples$opacity
    samp_pch <- c(rep(bp$samples$pch, length(group_levels)))
    if(length(bp$samples$col) == 1 | (sum(bp$samples$col == grDevices::adjustcolor(EZcols[1:length(group_levels)], bp$samples$opacity)) == length(group_levels)))
    {
      group_palette <- stats::setNames(scales::hue_pal()(length(group_levels)), group_levels)
    } else {
      group_palette <- bp$samples$col}
  }

  align_levels <- which(iter_levels==align.time)

  # Samples

  Z <- bp$Z
  Z <- suppressMessages(dplyr::bind_cols(Z, bp$Xcat))
  colnames(Z)[1:2] <- c("V1","V2")
  Z_tbl <- dplyr::as_tibble(Z)

  # Basis extraction
  bp_list <- vector("list", iterations)
  axes_info <- vector("list", iterations)
  Z_list <- vector("list", iterations)
  Vr_list <- vector("list", iterations)
  chull_reg <- vector("list", iterations)
  if(class(bp)[2] == "CVA")
    Zm_list <- vector("list", iterations)

  for (i in 1:iterations)
  {
    # Filter data by custom years

    temp <- bp$raw.X |> dplyr::filter(bp$raw.X[[tvi]] == iter_levels[i])
    if(class(bp)[2] == "PCA") {
      bp_list[[i]] <- biplotEZ::biplot(temp,scaled=bp$scaled) |> biplotEZ::PCA(group.aes = temp[[gvi]])
      bp_list[[i]]$Vr <- bp_list[[i]]$Vr
      }

    if(class(bp)[2] == "CVA") {
      bp_list[[i]] <- biplotEZ::biplot(temp,scaled=bp$scaled) |> biplotEZ::CVA(classes = temp[[gvi]])
      bp_list[[i]]$Vr <- bp_list[[i]]$Mr
      }

    if (i %in% align_levels) {
      reflect.mat <- diag(2)
      if (reflect[which(align_levels == i)] == "x") reflect.mat[1, 1] <- -1
      if (reflect[which(align_levels == i)] == "y") reflect.mat[2, 2] <- -1
      if (reflect[which(align_levels == i)] == "xy") reflect.mat[1:2, 1:2] <- diag(-1, 2)

      bp_list[[i]]$Z <- bp_list[[i]]$Z %*% reflect.mat
      bp_list[[i]]$Vr <- bp_list[[i]]$Vr %*% reflect.mat
      bp_list[[i]]$Zmeans <- bp_list[[i]]$Zmeans %*% reflect.mat
    }

    colnames(bp_list[[i]]$Z) <- c("V1","V2")
    Z_list[[i]] <- dplyr::as_tibble(bp_list[[i]]$Z)
    Z_list[[i]] <- suppressMessages(dplyr::bind_cols(Z_list[[i]], bp_list[[i]]$Xcat))

    colnames(bp_list[[i]]$Zmeans) <- c("V1","V2")
    Zm_list[[i]] <- dplyr::as_tibble(bp_list[[i]]$Zmeans)
    Zm_list[[i]] <- suppressMessages(dplyr::bind_cols(Zm_list[[i]],time.var = iter_levels[i],group_levels))


    # Variables

    if(is.null(bp$axes$label.cex) || bp$axes$label.cex[1] == formals(biplotEZ::axes)$label.cex[1]) {
      text_size = 4
    } else {
      text_size <- bp$axes$label.cex[1] * 2
    }

    axes_info[[i]] <- axes_moveEZ(bp_list[[i]])
    colnames(bp_list[[i]]$Vr) <- c("V1","V2")
    Vr_list[[i]] <- dplyr::as_tibble(bp_list[[i]]$Vr)
    Vr_list[[i]] <- Vr_list[[i]] |> dplyr::mutate(var = colnames(bp$X)) |>
      dplyr::mutate(slope = sign(axes_info[[i]]$slope)) |>
      dplyr::mutate(hadj = -slope, vadj = -1) |>
      dplyr::mutate(time.var = iter_levels[i]) |>
      dplyr::mutate(time.var = as.factor(time.var))


    #idx <- which(temp[[tvi]] == iter_levels[i])
    Y <- Z_list[[i]] #[idx,]
    chull_reg_iter <- vector("list", length(group_levels))
    for(j in 1:length(group_levels))
    {
      temp2 <- which(Y[[group.var]] == group_levels[j]) # index of the group var
      chull_reg_iter[[j]] <- Y[temp2,][grDevices::chull(Y[temp2,]),]
      #chull_reg[[i]][[j]] <- chull_reg_iter[[j]]
    }
    chull_reg[[i]] <- do.call(rbind,chull_reg_iter)

  }

  Z_tbl <- do.call(rbind,Z_list)
  Vr_tbl <- do.call(rbind,Vr_list)
  names(Vr_tbl)[7] <- time.var
  Zm_tbl <- do.call(rbind,Zm_list)
  names(Zm_tbl)[3] <- time.var
  names(Zm_tbl)[4] <- group.var

  chull_reg <- do.call(rbind,chull_reg)
  chull_reg <- dplyr::as_tibble(chull_reg)

  # Plotting

  # Move – TRUE Animated separate Z,V
  # Move – FALSE Facet separate Z,V
  if(move==TRUE)
  {
    bp$plot <- ggplot() +
      # Axes
      geom_segment(data = Vr_tbl, aes(x=0, y=0, xend = V1*scale.var, yend = V2*scale.var, group = var),
                   arrow = arrow(length = unit(0.1, "inches"))) +
      geom_text(data = Vr_tbl, aes(x=V1*scale.var, y=V2*scale.var,
                                   label = var, hjust = "outward", vjust = "outward", group = var),
                colour = "black", size = text_size) +
      gganimate::transition_states(.data[[time.var]],
                                   transition_length = 2, state_length = 1, wrap = FALSE) +
      # Sample polygons or points
      {if(hulls){
        list(
          geom_polygon(data = chull_reg, aes(x=V1, y=V2,group = .data[[group.var]],
                                             fill = .data[[group.var]]), alpha = 0.5),
          ggplot2::scale_fill_manual(values = group_palette))
      } else {
        list(
          geom_point(data = Z_tbl, aes(x=V1, y=V2, group = .data[[group.var]],
                                       fill = .data[[group.var]], colour = .data[[group.var]], shape = .data[[group.var]]),
                     size = 2, alpha = samp_opac),
          ggplot2::scale_colour_manual(values = group_palette),
          ggplot2::scale_shape_manual(values = samp_pch),
          ggplot2::scale_fill_manual(values = scales::alpha(group_palette, samp_opac))) #,
        #if(shadow) { gganimate::shadow_mark(alpha=0.3) })
      }} +
      gganimate::transition_states(.data[[time.var]],
                                   transition_length = 2,
                                   state_length = 1, wrap = FALSE) +
      {if(class(bp)[2] == "CVA"){
        geom_point(data = Zm_tbl,
                   aes(x = V1, y = V2, group = .data[[group.var]],
                       colour = .data[[group.var]],fill = .data[[group.var]]),
                   size = 3,shape = 15,alpha = 1,show.legend = FALSE)
      }} +
      gganimate::transition_states(.data[[time.var]],
                                   transition_length = 2,
                                   state_length = 1, wrap = FALSE) +
      ggplot2::labs(title = '{time.var}: {closest_state}',x="",y="") +
      ggplot2::scale_x_continuous(expand = ggplot2::expansion(mult = 0.2)) +
      ggplot2::scale_y_continuous(expand = ggplot2::expansion(mult = 0.2)) +
      theme_classic() +
      theme(axis.ticks = element_blank(),
            axis.text.x = element_blank(),
            axis.text.y = element_blank(),
            axis.title.x = element_blank(),
            axis.title.y = element_blank(),
            plot.title = ggplot2::element_text(size=30,face ="bold"),
            legend.position = if (length(group_levels) == 1) "none" else "right")

  } else {

    bp$plot <- ggplot() +
      # Axes
      geom_segment(data = Vr_tbl, aes(x=0, y=0, xend = V1*scale.var, yend = V2*scale.var, group = var),
                   arrow = arrow(length = unit(0.1, "inches"))) +
      geom_text(data = Vr_tbl, aes(x=V1*scale.var, y=V2*scale.var,
                                   label = var, hjust = "outward", vjust = "outward", group = var),
                colour = "black", size = text_size) +
      # Sample polygons or points
      {if(hulls){
        list(
          geom_polygon(data = chull_reg,
                       aes(x=V1, y=V2, group = .data[[group.var]],
                           fill = .data[[group.var]]), alpha = 0.5),
          ggplot2::scale_fill_manual(values = group_palette))
      } else {
        list(
          geom_point(data = Z_tbl,
                     aes(x=V1, y=V2,
                         group = .data[[group.var]],
                         fill = .data[[group.var]],
                         colour = .data[[group.var]],
                         shape = .data[[group.var]]),
                     size = 2, alpha = samp_opac),
          ggplot2::scale_colour_manual(values = group_palette),
          ggplot2::scale_fill_manual(values = scales::alpha(group_palette, samp_opac)),
          ggplot2::scale_shape_manual(values = samp_pch))
      }} +
      {if(class(bp)[2] == "CVA"){
        geom_point(data = Zm_tbl,
                   aes(x = V1, y = V2, group = .data[[group.var]],
                       colour = .data[[group.var]],fill = .data[[group.var]]),
                   size = 3,shape = 15,alpha = 1,show.legend = FALSE)
      }} +
      facet_wrap(~.data[[time.var]]) +
      ggplot2::scale_x_continuous(expand = ggplot2::expansion(mult = 0.2)) +
      ggplot2::scale_y_continuous(expand = ggplot2::expansion(mult = 0.2)) +
      theme_classic() +
      theme(axis.ticks = element_blank(),
            axis.text.x = element_blank(),
            axis.text.y = element_blank(),
            axis.title.x = element_blank(),
            axis.title.y = element_blank(),
            legend.position = if (length(group_levels) == 1) "none" else "right")

  }

  if(move==TRUE)
    print(gganimate::animate(bp$plot,duration = 15,fps=10)) else
      print(bp$plot)
  bp
}
