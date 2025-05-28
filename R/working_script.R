# Plotting objects
# 1.	Suppress Z | Full V
# Animation on Z, fixed V
# z_anim (polygons) + z_anim2 (points)

# 2.	Suppress Z | Sep V
# Animation on Z, V
# z_anim3 (only axes) + z_anim4 (axes + samples) + z_anim5 (axes + polygons)

# 3.	Sep Z | Sep V
# Animation on Z, V
# z_anim6 (axes + points) + z_anim7 (axes + polygons)


# Notes
# Suppress Z: Construct PCA on the full matrix X to get Z, and then slice Z into years.
# Full V: Construct PCA on the full matrix X to get V
# Sep V: Construct PCA on the sliced matrix X, and then get separate V’s
# Sep Z: Construct PCA on the sliced matrix X, and then get separate Z’s


###START HERE WITH FUNCTIONS
# Biplot object of all data
bp <- biplot(Africa_climate,scaled=TRUE) |> PCA(group.aes = Africa_climate$Region)

# Samples
Z <- bp$Z
#reg.col <- c("blue","green","gold","cyan","magenta","black","red","grey","purple","salmon")

Z <- suppressMessages(bind_cols(Z, Africa_climate$Region, Africa_climate$Year,Africa_climate$Month))
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

load("data/Africa_climate.rda")
Africa_climate$Year <- droplevels(Africa_climate$Year)
bp <- biplot(Africa_climate) |> PCA(group.aes=Africa_climate$Region)

# Z (polygons) animation 1

z_anim <- ggplot() +
  geom_point(data=Vr_coords_tbl, aes(x=V1,y=V2),size=1,colour="grey90") +
  geom_line(data = Vr_coords_tbl, aes(x = V1, y = V2, group = var),
            colour = "#d9d9d9") +
  geom_text(data=Vr_coords_tbl, aes(x=V1,y=V2,label=tick),size=2,colour="black") +
  geom_polygon(data = chull_reg,
               aes(x=V1, y=V2,
                   group = Region,
                   fill = Region), alpha=0.5) +
  transition_states(Year,
                    transition_length = 2,
                    state_length = 1) +
  labs(title = 'Year: {closest_state}',x="",y="") +
  xlim(c(-4,4)) +
  ylim(c(-4,4)) +
  theme_classic() +
  theme(axis.ticks = element_blank(), axis.text.x = element_blank(), axis.text.y = element_blank())

z_anim

# Z (samples) animation 2

z_anim2 <- ggplot() +
  geom_point(data=Vr_coords_tbl, aes(x=V1,y=V2),size=1,colour="grey90") +
  geom_line(data = Vr_coords_tbl, aes(x = V1, y = V2, group = var),
            colour = "#d9d9d9") +
  geom_text(data=Vr_coords_tbl, aes(x=V1,y=V2,label=tick),size=2,colour="black") +
  geom_point(data = Z_tbl,
             aes(x=V1, y=V2,
                 group = Region,
                 fill = Region,colour = Region),size=2, alpha=0.8) +
  #scale_color_manual(values = Z_tbl$Region) +
  transition_states(Year,
                    transition_length = 2,
                    state_length = 1) +
  labs(title = 'Year: {closest_state}',x="",y="") +
  #facet_wrap(~Region) +
  xlim(c(-4,4)) +
  ylim(c(-4,4)) +
  theme_classic() +
  theme(aspect.ratio=1,axis.ticks = element_blank(), axis.text.x = element_blank(), axis.text.y = element_blank())

z_anim2

# Basis extraction
bp_list <- vector("list", 8)
Z_list <- vector("list", 8)
Vr_list <- vector("list", 8)

for (i in 1:8)
{
  # Filter data by custom years

  temp <- Africa_climate2 |> filter(Year == years[i])
  bp_list[[i]] <- biplot(temp,scaled=TRUE) |> PCA(group.aes = temp$Region)
  Z_list[[i]] <- bp_list[[i]]$Z
  Z_list[[i]] <- suppressMessages(bind_cols(Z_list[[i]], bp_list[[i]]$Xcat$Region, bp_list[[i]]$Xcat$Year,bp_list[[i]]$Xcat$Month))
  names(Z_list[[i]])[1:5] <- c("V1","V2","Region", "Year", "Month")
  Vr_list[[i]] <- bp_list[[i]]$Vr
  Vr_list[[i]] <- suppressMessages(bind_cols(Vr_list[[i]],var=rep(i,6)))
  names(Vr_list[[i]])[1:2] <- c("V1","V2")
}



Vr_sep_coords <- vector("list",8)
Z_sep_coords <- vector("list",8)

for (i in 1:8)
{

  Vr_sep_coords[[i]] <- axes_coordinates(bp_list[[i]])
  Z_sep_coords[[i]] <- Z_list[[i]]

  for (j in 1:6)
  {
    Vr_sep_coords[[i]][[j]] <- suppressMessages(bind_cols(Vr_sep_coords[[i]][[j]],Year=years[i]))
    Vr_sep_coords[[i]][[j]] <- suppressMessages(bind_cols(Vr_sep_coords[[i]][[j]],var=j))
  }
  Vr_sep_coords[[i]] <- do.call(rbind,Vr_sep_coords[[i]])
}

Vr_sep_coords <- do.call(rbind,Vr_sep_coords)
names(Vr_sep_coords)[1:3] <- c("V1","V2", "tick")

Z_sep_coords <- do.call(rbind,Z_sep_coords)

Vr_sep_coords_tbl <- Vr_sep_coords |> mutate(var = as.factor(var))

# Axes animation 3

z_anim3 <- ggplot() +
  #geom_point(data=Vr_sep_coords_tbl, aes(x=V1,y=V2),size=1,colour="black") +
  geom_line(data = Vr_sep_coords_tbl, aes(x = V1, y = V2, group = var,colour=var)) +
  #geom_text(data=Vr_sep_coords_tbl, aes(x=V1,y=V2,label=tick),size=2,colour="black") +
  #facet_wrap(~Year) +
  transition_states(Year,
                    transition_length = 0,
                    state_length = 3) +
  labs(title = 'Year: {closest_state}',x="",y="") +
  xlim(c(-4,4)) +
  ylim(c(-4,4)) +
  theme_classic() +
  theme(aspect.ratio=1,axis.ticks = element_blank(), axis.text.x = element_blank(), axis.text.y = element_blank())
z_anim3

# Axes(Sep) + samples (suppressed) animation 4

z_anim4 <- ggplot() +
  #geom_point(data=Vr_sep_coords_tbl, aes(x=V1,y=V2),size=1,colour="black") +
  geom_line(data = Vr_sep_coords_tbl, aes(x = V1, y = V2, group = var),
            colour = "#d9d9d9") +
  #geom_text(data=Vr_sep_coords_tbl, aes(x=V1,y=V2,label=tick),size=2,colour="black") +
  #facet_wrap(~Year) +
  geom_point(data = Z_tbl,
             aes(x=V1, y=V2,
                 group = Region,
                 fill = Region,colour = Region),size=2, alpha=0.8) +
  transition_states(Year,
                    transition_length = 2,
                    state_length = 3) +
  labs(title = 'Year: {closest_state}',x="",y="") +
  xlim(c(-4,4)) +
  ylim(c(-4,4)) +
  theme_classic() +
  theme(aspect.ratio=1,axis.ticks = element_blank(), axis.text.x = element_blank(), axis.text.y = element_blank())

z_anim4

# Axes (Sep) + polygons (suppressed) animation 5
z_anim5 <- ggplot() +
  #geom_point(data=Vr_sep_coords_tbl, aes(x=V1,y=V2),size=1,colour="black") +
  geom_line(data = Vr_sep_coords_tbl, aes(x = V1, y = V2, group = var),
            colour = "#d9d9d9") +
  #geom_text(data=Vr_sep_coords_tbl, aes(x=V1,y=V2,label=tick),size=2,colour="black") +
  #facet_wrap(~Year) +
  geom_polygon(data = chull_reg,
               aes(x=V1, y=V2,
                   group = Region,
                   fill = Region), alpha=0.5) +
  transition_states(Year,
                    transition_length = 2,
                    state_length = 3) +
  labs(title = 'Year: {closest_state}',x="",y="") +
  xlim(c(-4,4)) +
  ylim(c(-4,4)) +
  theme_classic() +
  theme(aspect.ratio=1,axis.ticks = element_blank(), axis.text.x = element_blank(), axis.text.y = element_blank())

z_anim5

# Axes (Sep) + samples (Sep) animation 6
z_anim6 <- ggplot() +
  #geom_point(data=Vr_sep_coords_tbl, aes(x=V1,y=V2),size=1,colour="black") +
  geom_line(data = Vr_sep_coords_tbl, aes(x = V1, y = V2, group = var),
            colour = "#d9d9d9") +
  #geom_text(data=Vr_sep_coords_tbl, aes(x=V1,y=V2,label=tick),size=2,colour="black") +
  #facet_wrap(~Year) +
  geom_point(data = Z_sep_coords,
             aes(x=V1, y=V2,
                 group = Region,
                 fill = Region, colour = Region), size=2, alpha=0.8) +
  transition_states(Year,
                    transition_length = 2,
                    state_length = 3) +
  labs(title = 'Year: {closest_state}',x="",y="") +
  xlim(c(-4,4)) +
  ylim(c(-4,4)) +
  theme_classic() +
  theme(aspect.ratio=1,axis.ticks = element_blank(), axis.text.x = element_blank(), axis.text.y = element_blank())

z_anim6

#creating manual hulls for separate Z

chull_reg_sep <- vector("list", 8)
for(i in 1:length(years))
{
  idx <- which(Z_list[[i]]$Year == years[i])

  Y <- Z_list[[i]][idx,]

  chull_reg_yearly_sep <- vector("list", 10)
  for(j in 1:10)
  {
    temp <- which(Y[,3] == levels(Z_list[[i]]$Region)[j])
    chull_reg_yearly_sep[[j]] <- Y[temp,][chull(Y[temp,]),]
    chull_reg_sep[[i]][[j]] <- chull_reg_yearly_sep[[j]]
  }
  chull_reg_sep[[i]] <- do.call(rbind,chull_reg_sep[[i]])
}

chull_reg_sep <- do.call(rbind,chull_reg_sep)

# Axes (Sep) + polygons (Sep) animation 7

z_anim7 <- ggplot() +
  #geom_point(data=Vr_sep_coords_tbl, aes(x=V1,y=V2),size=1,colour="black") +
  geom_line(data = Vr_sep_coords_tbl, aes(x = V1, y = V2, group = var),
            colour = "#d9d9d9") +
  #geom_text(data=Vr_sep_coords_tbl, aes(x=V1,y=V2,label=tick),size=2,colour="black") +
  #facet_wrap(~Year) +
  geom_polygon(data = chull_reg_sep,
               aes(x=V1, y=V2,
                   group = Region,
                   fill = Region), alpha=0.5) +
  transition_states(Year,
                    transition_length = 2,
                    state_length = 3) +
  labs(title = 'Year: {closest_state}',x="",y="") +
  xlim(c(-4,4)) +
  ylim(c(-4,4)) +
  theme_classic() +
  theme(aspect.ratio=1,axis.ticks = element_blank(), axis.text.x = element_blank(), axis.text.y = element_blank())

z_anim7

###########################test
ggplot() +
  geom_point(data=Vr_coords_tbl, aes(x=V1,y=V2),size=0.5,colour="grey90") +
  geom_line(data = Vr_coords_tbl, aes(x = V1, y = V2, group = var),
            colour = "#d9d9d9") +
  geom_text(data=Vr_coords_tbl, aes(x=V1,y=V2,label=tick),size=2,colour="black") +
  geom_point(data = Z_tbl,
             aes(x=V1, y=V2,
                 group = Region,
                 fill = Region,colour = Region),alpha=0.8) +
  # facet_wrap(~Year) +
  xlim(c(-4,4)) +
  ylim(c(-4,4)) +
  theme_classic() +
  theme(aspect.ratio=1,axis.ticks = element_blank(), axis.text.x = element_blank(), axis.text.y = element_blank())

#library(woyler)
#givens rotation
