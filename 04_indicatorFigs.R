#########################################
## CREATE INDICATOR FIGURES FOR REPORT ##
#########################################

## Load csvs with raw results
a <- read.csv(paste0(out.dir, "RockSprings-WYO_aoi_vs_sample_percentiles_west2000_220630_v1.csv")) %>%
  dplyr::select(an, vn, pv)
b <- read.csv(paste0(out.dir, "RockSprings-WYO_aoi_vs_sample_percentiles_blmwest2000_220630_v1.csv")) %>%
  dplyr::select(an, vn, pv)
c <- read.csv(paste0(out.dir, "RockSprings-WYO_aoi_vs_sample_percentiles_wyo500_220630_v1.csv")) %>%
  dplyr::select(an, vn, pv)
d <- read.csv(paste0(out.dir, "RockSprings-WYO_aoi_vs_sample_percentiles_blmwyo500_220630_v1.csv")) %>%
  dplyr::select(an, vn, pv)

# Assign domain and n if they're not in csv already from loop
a$domain <- "west"
a$n <- 2000
b$domain <- "blmwest"
b$n <- 2000
c$domain <- "wyo"
c$n <- 500
d$domain <- "blmwyo"
d$n <- 500

# Combine all
data <- rbind(a, b, c, d) ; remove(a, b, c, d)

threats <- c("annHerb", "geotherm", "wind", "solar", "oilGas")
# Assign value/threat
data <- data %>%
  mutate(type = ifelse(vn %in% threats, "threat", "value"))

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


# Filter data to given AOI and sampling domain
sel <- data %>%
  filter(an == "Little Sandy", domain == "blmwest")

# Order data by percentile ranks (greatest first)
sel <- sel[order(sel$pv, decreasing = FALSE), ] 
# Lock the ranks in by setting variable names as a factor based on that order.
sel$vn <- factor(sel$vn, levels = sel$vn, ordered = TRUE)

# Look-up the color lookups and assign threat color (reds) or value (greens)
# Magically, it pulls the color corresponding to the index of sel$type
sel <- sel %>%
  mutate(color = ifelse(sel$type == "value", rev(col_values), rev(col_threats)))


p <- sel %>%
  group_by(an) %>% # defines as grouped df
  # arrange(desc(pv), .by_group = TRUE) %>% # sorts & remembers the grp
  ggplot(aes(x = vn, y = pv, fill = vn)) +
  geom_bar(stat = "identity") +
  coord_flip() +
  # scale_fill_gradient(low = "green", high = "pink") +
  scale_fill_manual(values = sel$color) +
  theme_minimal() +
  facet_wrap(~an, ncol = 2, scales = "free_y")
  
p




p <- 
  ggplot(sel,
         aes(x = vn, y = pv, fill = pv)) +
  geom_bar(position="stack", stat="identity", alpha=0.9) +
  coord_flip() +
  
p


sel$color<-c('#e41a1c',
             '#377eb8',
             '#4daf4a',
             '#984ea3',
             '#ff7f00',
             '#ffff33',
             '#a65628',
             '#f781bf',
             '#999999',
             '#e41a1c',
             '#377eb8',
             '#4daf4a',
             '#984ea3',
             '#ff7f00',
             '#ffff33',
             '#a65628',
             '#f781bf',
             '#999999',
             '#e41a1c',
             '#1f78b4')


https://github.com/CaitLittlef/tws_castner_maps/blob/main/02_extractVals.R