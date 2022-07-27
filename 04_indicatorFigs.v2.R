
today <- paste0(mid(Sys.Date(),3,2),
                mid(Sys.Date(),6,2),
                mid(Sys.Date(),9,2))


#########################################
## CREATE INDICATOR FIGURES FOR REPORT ##
#########################################

## Load csvs with raw results --------------------------------------------------

# data <- read.csv(paste0(out.dir, "Lewistown-MT_aoi_vs_sample_percentiles_220725_v7.csv")) %>%
#   dplyr::select(an, dn, nv, vn, pv)

data <- read.csv(paste0(out.dir, "RockSprings-WYO_aoi_vs_sample_percentiles_220727_v1.csv")) %>%
  dplyr::select(an, dn, nv, vn, pv)



## Assign categories/labels ----------------------------------------------------

# Assign value/threat
threats <- c("annHerb", "geotherm", "wind", "solar", "mineral", "oilGas")
data <- data %>%
  mutate(type = ifelse(vn %in% threats, "threat", "value"))

# Assign full labels
lu <- data.frame(layer = c("amph", "bird", "mamm", "rept", "impSpp", "connect",
                           "intact", "ecoRar", "vegDiv", "sage", "annHerb",
                           "climAcc", "climStab", "geoDiv", "geoRar",
                           "geotherm", "oilGas", "mineral", "solar", "wind", "nightDark"),
                 variable = c("Amphibian species richness", "Bird species richness",
                              "Mammal species richness", "Reptile species richness",
                              "Imperiled species richness", "Ecological connectivity",
                              "Ecological intactness", "Ecosystem rarity",
                              "Vegetation diversity", "Percent sagebrush cover",
                              "Percent annual herbaceous cover", "Climate accessibility",
                              "Climate stability", "Geophysical diversity",
                              "Geophysical rarity", "Geothermal resource potential",
                              "Oil and gas resource potential", "Mineral resource potential",
                              "Solar resource potential", "Wind resource potential",
                              "Night sky darkness"))

data <- data %>% left_join(lu, by = c("vn" = "layer"))


# Pull colors for green (Value) and red (threat) gradients
# Source: https://colordesigner.io/gradient-generator
# Define list of colors (trial and error showed reverse necessary)
col_value <- c("#056e4f",
"#187556",
"#257b5e",
"#318266",
"#3b886d",
"#458f75",
"#4e967d",
"#589c84",
"#61a38c",
"#6aaa94",
"#73b19c",
"#7db7a4",
"#86beac",
"#8fc5b4",
"#99ccbc",
"#a2d3c4",
"#acdacc",
"#b6e1d4",
"#bfe8dc",
"#c9efe4")

col_threat <- c("#c81e43",
"#cc2d4b",
"#cf3a53",
"#d2445c",
"#d54f64",
"#d8586c",
"#db6174",
"#dd6a7c",
"#e07384",
"#e27c8c",
"#e48494",
"#e68d9c",
"#e795a3",
"#e99eab",
"#eaa6b2",
"#ebaeba",
"#ecb6c1",
"#edbfc8",
"#eec7cf",
"#efcfd6")


## Select AOI/sampling domain combo (one of each!!) ---------------------------

# Filter data to given AOI and sampling domain
sel <- data %>%
  filter(
         an == "Little Sandy",
         # an == "Red Desert",
         # an == "lewis",
         # dn == "west"
         # dn == "blmWest"
         # dn == "wyo"
         # dn == "MT"
         dn == "blmWyo"
         # dn == "blmMT"
         )

# Order data by percentile ranks (greatest first)
sel <- sel[order(sel$pv, decreasing = FALSE), ] 
# Lock the ranks in by setting variable  as a factor based on that order.
sel$variable <- factor(sel$variable, levels = sel$variable, ordered = TRUE)

# Look-up the color lookups and assign threat color (reds) or value (greens)
# Magically, it pulls the color corresponding to the index of sel$type
sel <- sel %>%
  mutate(color = ifelse(sel$type == "value", rev(col_value), rev(col_threat)))



## Plot & save ----------------------------------------------------------------

# p <- sel %>%
p <- sel[12:20,] %>% # top 8 (in oppo order)
  # group_by(an) %>% # defines as grouped df
  # arrange(desc(pv), .by_group = TRUE) %>% # sorts & remembers the grp
  ggplot(aes(x = variable, y = pv*100,
             fill = variable)) +
  geom_bar(stat = "identity") +
  # scale_fill_manual(values = sel$color) +
  scale_fill_manual(values = sel$color[12:20]) +
  coord_flip() +
  # theme_bw() +
  # theme_classic() +
  # theme_minimal() +
  theme(#panel.grid.major = element_blank(),
        #panel.grid.minor = element_blank(),
        legend.position = "none",
        axis.text = element_text(color = "black", size = 14), #, size = rel(1)),
        axis.title.y = element_blank(),
        axis.title.x = element_text(face ="bold", size = 14)) + #, size = rel(1))) +
  theme(plot.margin = unit(c(0.5,0.5,0.5,0.5), "cm")) +
  labs(y = "Score") +
  #------------- annotation layer ---------------------
  # the anchor points of the labels are inherited from ggplot() call 
  geom_text(aes(label = paste0(pv*100)), hjust = 1.2)

p

v <- 1
# v <- v+1
ggsave(paste0(out.dir, "top8_", sel$an[1], "_", sel$dn[1], "_n", sel$n[1], "_", today, "_v",v, ".png"),
       p,
       # width = 850, height = 550, units = "px")
       width = 6, height = 6, units = "in")
dev.off()


