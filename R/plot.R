#' Move plot
#'
#' Create animated biplot
#'
#' @param bp biplot object from biplotEZ
#' @param time.var time variable
#' @param group.var group variable
#' @param moveS whether to animate (TRUE) samples or facet (FALSE) samples, according to time.var
#' @param moveX whether to animate variables (TRUE or FALSE)
#' @param hull whether to display sample points or convex hulls
#' @param scale.var scaling the vectors representing the variables
#'
#' @returns
#' @export
#'
#' @examples
moveplot <- function(bp,time.var,group.var,moveS=TRUE,
                     moveX = FALSE,hulls=TRUE,scale.var=5)
{

  if(moveX == TRUE & moveS == FALSE) {
    moveS=TRUE
    warning("moveS changed to TRUE for moving axes") }

  if(!is.null(group.var)) bp$group.aes <- bp$raw.X[,which(colnames(bp$raw.X) == group.var)] else
    bp$group.aes = NULL

  tvi <- which(colnames(bp$raw.X) == time.var)
  gvi <- which(colnames(bp$raw.X) == group.var)

  iterations <- nlevels(bp$raw.X[[tvi]])
  iter_levels <- levels(bp$raw.X[[tvi]])

  group_levels <- levels(bp$raw.X[[gvi]])


  # Samples
  Z <- bp$Z
  Z <- suppressMessages(dplyr::bind_cols(Z, bp$Xcat))
  colnames(Z)[1:2] <- c("V1","V2")
  Z_tbl <- dplyr::as_tibble(Z)

  # Set limits
  # xlim
  minx <- min(Z_tbl$V1)
  maxx <- max(Z_tbl$V1)
  range_x <- maxx - minx

  # ylim
  miny <- min(Z_tbl$V2)
  maxy <- max(Z_tbl$V2)
  range_y <- maxy - miny

  perc <- 20/100
  xlim <- c(minx - perc*range_x,maxx + perc*range_x)
  ylim <- c(miny - perc*range_y,maxy + perc*range_y)


  # Axes (if moveX == FALSE)
  if(moveX == FALSE)
  {
    axes_info <- axes_moveEZ(bp)
    Vr <- bp$Vr
    Vr <- dplyr::as_tibble(Vr)
    Vr_tbl <- Vr |> dplyr::mutate(var = colnames(bp$X)) |>
      dplyr::mutate(slope = sign(axes_info$slope)) |>
      dplyr::mutate(hadj = -slope, vadj = -1)
  }


  # Axes (if moveX == TRUE)
  if(moveX == TRUE)
  {
    # Basis extraction
    bp_list <- vector("list", iterations)
    axes_info <- vector("list", iterations)
    Z_list <- vector("list", iterations)
    Vr_list <- vector("list", iterations)

    for (i in 1:iterations)
    {
      # Filter data by custom years

      temp <- bp$raw.X |> dplyr::filter(bp$raw.X[[tvi]] == iter_levels[i])
      bp_list[[i]] <- biplotEZ::biplot(temp,scaled=bp$scaled) |> biplotEZ::PCA(group.aes = temp[[gvi]])
      Z_list[[i]] <- dplyr::as_tibble(bp_list[[i]]$Z)
      Z_list[[i]] <- suppressMessages(dplyr::bind_cols(Z_list[[i]], bp_list[[i]]$Xcat))
      colnames(Z_list[[i]])[1:2] <- c("V1","V2")


      axes_info[[i]] <- axes_moveEZ(bp_list[[i]])
      Vr_list[[i]] <- dplyr::as_tibble(bp_list[[i]]$Vr)
      Vr_list[[i]] <- Vr_list[[i]] |> dplyr::mutate(var = colnames(bp$X)) |>
        dplyr::mutate(slope = sign(axes_info[[i]]$slope)) |>
        dplyr::mutate(hadj = -slope, vadj = -1) |>
        dplyr::mutate(time.var = iter_levels[i])

    }

    Z_tbl <- do.call(rbind,Z_list)
    Vr_tbl <- do.call(rbind,Vr_list)
    names(Vr_tbl)[7] <- time.var
  }



  # C Hulls for points
  chull_reg <- vector("list", iterations)
  for(i in 1:iterations)
  {
    idx <- which(bp$raw.X[[tvi]] == iter_levels[i])
    Y <- Z[idx,]
    chull_reg_iter <- vector("list", length(group_levels))
    for(j in 1:length(group_levels))
    {
      temp <- which(Y[[group.var]] == group_levels[j]) # index of the time var
      chull_reg_iter[[j]] <- Y[temp,][chull(Y[temp,]),]
      chull_reg[[i]][[j]] <- chull_reg_iter[[j]]
    }
    chull_reg[[i]] <- do.call(rbind,chull_reg[[i]])
  }

  chull_reg <- do.call(rbind,chull_reg)
  chull_reg <- dplyr::as_tibble(chull_reg)


  # Plotting

  # MoveS – TRUE MoveX – FALSE --- Animated sliced Z
  # MoveS – FALSE moveX – FALSE --- Facet on sliced Z
  if(moveX == FALSE)
  {
    ggplot() +
      # Axes
      geom_segment(data=Vr_tbl,aes(x=0,y=0,xend=V1*scale.var,yend=V2*scale.var,group=var),
                   arrow=arrow(length=unit(0.1,"inches"))) +
      geom_text(data=Vr_tbl,aes(x=V1*scale.var, y=V2*scale.var,
                                label = var,
                                hjust="outward", vjust="outward",group=var),colour="black",size=4) +
      # Sample polygons or points
      {if(hulls){
        geom_polygon(data = chull_reg,
                     aes(x=V1, y=V2,group = .data[[group.var]],
                         fill = .data[[group.var]]), alpha=0.5)

      } else {
        geom_point(data = Z_tbl,
                   aes(x=V1, y=V2,
                       group = .data[[group.var]],
                       fill =.data[[group.var]],
                       colour = .data[[group.var]]),size=2, alpha=0.8)
      }} +
      {if(moveS) { transition_states(.data[[time.var]],
                                     transition_length = 2,
                                     state_length = 1) } else {
                                       facet_wrap(~.data[[time.var]]) }} +
      {if(moveS) labs(title = '{time.var}: {closest_state}',x="",y="")} +
      xlim(xlim) +
      ylim(ylim) +
      theme_classic() +
      theme(axis.ticks = element_blank(),
            axis.text.x = element_blank(),
            axis.text.y = element_blank())

  } else {
    ggplot() +
      # Axes
      geom_segment(data=Vr_tbl,aes(x=0,y=0,xend=V1*scale.var,yend=V2*scale.var,group=var),
                   arrow=arrow(length=unit(0.1,"inches"))) +
      geom_text(data=Vr_tbl,aes(x=V1*scale.var, y=V2*scale.var,
                                label = var,
                                hjust="outward", vjust="outward",group=var),colour="black",size=4) +
      transition_states(.data[[time.var]],
                        transition_length = 2,
                        state_length = 1) +
      # Sample polygons or points
      {if(hulls){
        geom_polygon(data = chull_reg,
                     aes(x=V1, y=V2,group = .data[[group.var]],
                         fill = .data[[group.var]]), alpha=0.5)

      } else {
        geom_point(data = Z_tbl,
                   aes(x=V1, y=V2,
                       group = .data[[group.var]],
                       fill =.data[[group.var]],
                       colour = .data[[group.var]]),size=2, alpha=0.8)
      }} +
      {if(moveS) { transition_states(.data[[time.var]],
                                     transition_length = 2,
                                     state_length = 1) } else {
                                       facet_wrap(~.data[[time.var]]) }} +
      {if(moveS) labs(title = '{time.var}: {closest_state}',x="",y="")} +
      xlim(xlim) +
      ylim(ylim) +
      theme_classic() +
      theme(axis.ticks = element_blank(),
            axis.text.x = element_blank(),
            axis.text.y = element_blank())

  }


  # MoveS – TRUE MoveX – TRUE --- Animate on separate Z and V
  # MoveS – FALSE MoveX – TRUE --- give a message & set MoveS = TRUE --> Animate on separate Z and V

  # if(moveX == TRUE)
  # {
  #   ggplot() +
  #     # Axes
  #     geom_segment(data=Vr_tbl,aes(x=0,y=0,xend=V1*scale.var,yend=V2*scale.var,group=var),
  #                  arrow=arrow(length=unit(0.1,"inches"))) +
  #     geom_text(data=Vr_tbl,aes(x=V1*scale.var, y=V2*scale.var,
  #                               label = var,
  #                               hjust="outward", vjust="outward",group=var),colour="black",size=4) +
  #     transition_states(.data[[time.var]],
  #                       transition_length = 2,
  #                       state_length = 1) +
  #     # Sample polygons or points
  #     {if(hulls){
  #       geom_polygon(data = chull_reg,
  #                    aes(x=V1, y=V2,group = .data[[group.var]],
  #                        fill = .data[[group.var]]), alpha=0.5)
  #
  #     } else {
  #       geom_point(data = Z_tbl,
  #                  aes(x=V1, y=V2,
  #                      group = .data[[group.var]],
  #                      fill =.data[[group.var]],
  #                      colour = .data[[group.var]]),size=2, alpha=0.8)
  #     }} +
  #     {if(moveS) { transition_states(.data[[time.var]],
  #                                    transition_length = 2,
  #                                    state_length = 1) } else {
  #                                      facet_wrap(~.data[[time.var]]) }} +
  #     {if(moveS) labs(title = '{time.var}: {closest_state}',x="",y="")} +
  #     xlim(xlim) +
  #     ylim(ylim) +
  #     theme_classic() +
  #     theme(axis.ticks = element_blank(),
  #           axis.text.x = element_blank(),
  #           axis.text.y = element_blank())
  #
  # }

}
