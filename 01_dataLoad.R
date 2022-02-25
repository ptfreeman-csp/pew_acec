

# maybe necessary if some raster aren't loading
# unlink(".RData")

######################################
## DATA COLLECTION & PRE-PROCESSING ##
######################################

## Function to load features, set common crs, and fix any invalid geometries
load_f <- function(f) {
  # proj.crs <- "+proj=longlat +datum=WGS84 +no_defs"
  proj.crs <- "+proj=aea +lat_0=23 +lon_0=-96 +lat_1=29.5 +lat_2=45.5 +x_0=0 +y_0=0 +datum=WGS84 +units=m +no_defs"
  read_sf(f) %>%
    st_transform(proj.crs) %>%
    st_make_valid() %>%
    st_buffer(dist = 0)
}
# proj.crs <- "+proj=longlat +datum=WGS84 +no_defs"
proj.crs <- "+proj=aea +lat_0=23 +lon_0=-96 +lat_1=29.5 +lat_2=45.5 +x_0=0 +y_0=0 +datum=WGS84 +units=m +no_defs"


## Load data
# Load biome
biome <- load_f("G:/My Drive/2FWS Sagebrush/FWS Sagebrush/data - state of sagebrush/data/US_Sagebrush_Biome_2019.shp")
plot(biome)

# Load YNP
ynp <- load_f(paste0(wd, "colab_scratch/yellowstone.shp"))
plot(ynp)

# Load spp richness
amph <- raster(paste0(wd, "colab_scratch/amphClip.tif"))
mamm <- raster(paste0(wd, "colab_scratch/mammClip.tif"))
rept <- raster(paste0(wd, "colab_scratch/reptClip.tif"))
par(mfrow=c(1,3))
plot(amph) ; plot(mamm) ; plot(rept)
par(mfrow=c(1,1))

plot(amph) ; plot(ynp, add = TRUE)

# List all layers
spp.rich.list <- list(amph, mamm, rept)




