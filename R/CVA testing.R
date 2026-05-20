moveplot_test <- function(bp, time.var, group.var, move = TRUE, hulls = TRUE,
                     scale.var = 5, shadow = FALSE)
{

  if(!is.null(group.var)) bp$group.aes <- bp$raw.X[,which(colnames(bp$raw.X) == group.var)] else
    bp$group.aes = NULL

  tvi <- which(colnames(bp$raw.X) == time.var)
  gvi <- which(colnames(bp$raw.X) == group.var)

  iterations <- nlevels(bp$raw.X[[tvi]])
  iter_levels <- levels(bp$raw.X[[tvi]])

  group_levels <- levels(bp$raw.X[[gvi]])

  # Group colours

  #biplotEZ default colour palette
  EZcols <- c("#0000FFFF", "#00FF00FF", "#FFD700FF", "#00FFFFFF", "#FF00FFFF",
              "#000000FF", "#FF0000FF", "#BEBEBEFF", "#A020F0FF", "#FA8072FF")

  if(is.null(bp$samples))
  { #biplotEZ::samples() not utilised
    samp_pch <- c(rep(19,bp$n))
    samp_opac <- 0.8
    group_palette <- stats::setNames(scales::hue_pal()(length(group_levels)), group_levels)
  } else {
    samp_pch <- c(rep(bp$samples$pch, length(group_levels)))
    samp_opac <- bp$samples$opacity
    if(length(bp$samples$col) == 1 | (sum(bp$samples$col == grDevices::adjustcolor(EZcols[1:length(group_levels)], samp_opac)) == length(group_levels))) {
      group_palette <- stats::setNames(scales::hue_pal()(length(group_levels)), group_levels)}
    else  group_palette <- bp$samples$col
  }

  # Samples
  Z <- bp$Z
  Z <- suppressMessages(dplyr::bind_cols(Z, bp$Xcat))
  colnames(Z)[1:2] <- c("V1","V2")
  Z_tbl <- dplyr::as_tibble(Z)

  # Group means for CVA | per time slice
  Zmeans_tbl <- Z_tbl |>
    dplyr::group_by(Year, Region) |>
    dplyr::summarise(
      V1_mean = mean(V1, na.rm = TRUE),
      V2_mean = mean(V2, na.rm = TRUE),
      .groups = "drop"
    )

  # Variables

  #conversion of 1:1.5 between cex of pch base R:ggplot2
  #conversion of 1:2 between cex of text base R:ggplot2
  if(is.null(bp$axes$label.cex) || bp$axes$label.cex[1] == formals(biplotEZ::axes)$label.cex[1]) {
    text_size = 4
  } else {
    text_size <- bp$axes$label.cex[1] * 2
  }

  axes_info <- axes_moveEZ(bp)

  if(class(bp)[2] == "PCA") Vr <- bp$Vr
  if(class(bp)[2] == "CVA") Vr <- bp$Mr

  colnames(Vr) <- c("V1","V2")
  Vr <- dplyr::as_tibble(Vr)
  Vr_tbl <- Vr |> dplyr::mutate(var = colnames(bp$X)) |>
    dplyr::mutate(slope = sign(axes_info$slope)) |>
    dplyr::mutate(hadj = -slope, vadj = -1)


  # C Hulls for points
  chull_reg <- vector("list", iterations)
  for(i in 1:iterations)
  {
    idx <- which(bp$raw.X[[tvi]] == iter_levels[i])
    Y <- Z[idx,]
    chull_reg_iter <- vector("list", length(group_levels))
    for(j in 1:length(group_levels))
    {
      temp <- which(Y[[group.var]] == group_levels[j]) # index of the group var
      chull_reg_iter[[j]] <- Y[temp,][grDevices::chull(Y[temp,]),]
      chull_reg[[i]][[j]] <- chull_reg_iter[[j]]
    }
    chull_reg[[i]] <- do.call(rbind,chull_reg[[i]])
  }

  chull_reg <- do.call(rbind,chull_reg)
  chull_reg <- dplyr::as_tibble(chull_reg)

  # Subset of samples for which hulls cannot be constructed
  tvi_chull <- which(colnames(chull_reg) == time.var)
  no_hulls <- as.numeric(names(which(table(chull_reg[[tvi_chull]])<4)))
  Z_tbl_sub <- Z_tbl |>  dplyr::filter(Z_tbl[[tvi_chull]] %in% no_hulls)

  # Plotting
  # move – TRUE --- Animated sliced Z
  # move – FALSE  --- Facet on sliced Z
  bp$plot <- ggplot() +
    # Axes
    geom_segment(data = Vr_tbl,aes(x=0, y=0, xend = V1*scale.var, yend = V2*scale.var, group = var),
                 arrow = arrow(length = unit(0.1, "inches"))) +
    geom_text(data = Vr_tbl, aes(x=V1*scale.var, y=V2*scale.var,
                                 label = var, hjust = "outward", vjust = "outward", group = var),
              colour = "black", size = text_size) +
    # Sample polygons or points
    {if(hulls){
      list(
        geom_polygon(data = chull_reg,
                     aes(x=V1, y=V2,
                         group = .data[[group.var]],
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
      geom_point(data = Zmeans_tbl,
                 aes(x = V1_mean, y = V2_mean,
                     colour = .data[[group.var]]),
                 size = 3,shape = 15,alpha = 1,show.legend = FALSE)
    }} +
    {if(move) { gganimate::transition_states(.data[[time.var]],
                                             transition_length = 2,
                                             state_length = 1, wrap = FALSE) } else {
                                               facet_wrap(~.data[[time.var]]) }} +
    {if(move) { ggplot2::labs(title = '{time.var}: {closest_state}',x="",y="")}} +
    # Sample points for hulls that cannot be constructed
    {if(hulls & (length(no_hulls) > 0)) {
      list(
        geom_point(data = Z_tbl_sub,
                   aes(x=V1, y=V2,
                       group = .data[[group.var]],
                       fill = .data[[group.var]],
                       colour = .data[[group.var]], shape = .data[[group.var]]),
                   size = 2, alpha = 0.8, show.legend = FALSE),
        ggplot2::scale_colour_manual(values = group_palette, drop = FALSE),
        ggplot2::scale_fill_manual(values = scales::alpha(group_palette, samp_opac), drop = FALSE),
        ggplot2::scale_shape_manual(values = samp_pch, drop = FALSE))
    }} +
    {if(!hulls & shadow) { gganimate::shadow_mark(alpha=0.3) }} +
    ggplot2::scale_x_continuous(expand = ggplot2::expansion(mult = 0.2)) +
    ggplot2::scale_y_continuous(expand = ggplot2::expansion(mult = 0.2)) +
    theme_classic() +
    theme(axis.ticks = element_blank(),
          axis.text.x = element_blank(),
          axis.text.y = element_blank(),
          axis.title.x = element_blank(),
          axis.title.y = element_blank(),
          plot.title = ggplot2::element_text(size=30, face ="bold"),
          legend.position = if (length(group_levels) == 1) "none" else "right")

  if(move==TRUE)
    print(gganimate::animate(bp$plot, duration = 15, fps = 10, end_pause = 20)) else
      print(bp$plot)
  bp
}
