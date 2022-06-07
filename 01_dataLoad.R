

# maybe necessary if some raster aren't loading
# unlink(".RData")

######################################
## DATA COLLECTION & PRE-PROCESSING ##
######################################

## Function to load features, set common crs, and fix any invalid geometries
load_f <- function(f) {
  # proj.crs <- "+proj=longlat +datum=WGS84 +no_defs"
  # proj.crs <- "+proj=aea +lat_0=23 +lon_0=-96 +lat_1=29.5 +lat_2=45.5 +x_0=0 +y_0=0 +datum=WGS84 +units=m +no_defs"
  # proj.crs <- "+proj=aea +lat_0=0 +lon_0=0 +lat_1=29.5 +lat_2=45.5 +x_0=0 +y_0=0 +datum=NAD83 +units=m +no_defs"
  proj.crs <- "+proj=aea +lat_0=37.5 +lon_0=-96 +lat_1=29.5 +lat_2=45.5 +x_0=0 +y_0=0 +datum=NAD83 +units=m +no_defs"
  
  
  read_sf(f) %>%
    st_transform(proj.crs) %>%
    st_make_valid() %>%
    st_buffer(dist = 0)
}
# proj.crs <- "+proj=longlat +datum=WGS84 +no_defs"
# proj.crs <- "+proj=aea +lat_0=23 +lon_0=-96 +lat_1=29.5 +lat_2=45.5 +x_0=0 +y_0=0 +datum=WGS84 +units=m +no_defs"
# proj.crs <- "+proj=aea +lat_0=0 +lon_0=0 +lat_1=29.5 +lat_2=45.5 +x_0=0 +y_0=0 +datum=NAD83 +units=m +no_defs"
proj.crs <- "+proj=aea +lat_0=37.5 +lon_0=-96 +lat_1=29.5 +lat_2=45.5 +x_0=0 +y_0=0 +datum=NAD83 +units=m"


## Load data

# Load CONUS; retain western states.
usa <- load_f("C:/Users/clitt/OneDrive/Desktop/data_gen/political/tl_2012_us_state.shp")
keeps <- c("Washington", "Oregon", "California", "Idaho", "Montana",
           "Wyoming", "Nevada", "Utah", "Colorado", "Arizona", "New Mexico")
west <- usa %>% filter(NAME %in% keeps)
# unique(west$NAME) ; plot(west)
remove(usa, keeps)


# Load Red Desert all designations removed
rd_desigX <- load_f(paste0(data.dir,
                           "RockSpringsFO_Wyo/RedDesert-LittleSandyLandscape/RD_IBA_EraseDesignations.shp"))

# Load Red Desert all designations AND special mgmt area removed
rd_allX <- load_f(paste0(data.dir,
                         "RockSpringsFO_Wyo/RedDesert-LittleSandyLandscape/RD_IBA_EraseAll.shp"))
# Load Little Sandy
ls <- load_f(paste0(data.dir,
                    "RockSpringsFO_Wyo/RedDesert-LittleSandyLandscape/RD_LS_IBA_RSFO - Copy.shp")) %>%
  filter(SITE_NAME == "Little Sandy Landscape")


sg <- load_f(paste0(data.dir, "source/sagegrouse/sageGrousePAC.shp"))
plot(st_geometry(sg))


list <- list.files(paste0(data.dir,"working"), pattern= ".tif", full.names = TRUE)

min(raster(list[[7]]))
max(raster(list[[7]]))


# Load spp richness
# amph <- raster(paste0(wd, "colab_scratch/amphClip.tif"))
amph <- raster(paste0(data.dir, "working/amph.v2.tif")) ; crs(amph)
bird <- raster(paste0(data.dir, "working/bird.tif")) ; crs(bird)
mamm <- raster(paste0(data.dir, "working/mamm.tif")) ; crs(mamm)
rept <- raster(paste0(data.dir, "working/rept.tif")) ; crs(rept)

climAcc <- raster(paste0(data.dir, "working/ClimAccessNorm.tif")) ; crs(climAcc)
plot(climAcc)
crs(ls)
boo <- projectRaster(climAcc, crs = proj.crs)
proj.crs
plot(boo)
plot(ls, add = TRUE)
plot(sample, add = TRUE)
crs(sample)

# Nat re
wind_res <- raster(paste0(data.dir, "working/windprobi_lt30pslope_ddpowerline4normPAs0UrbH20MULT.tif")) ; crs(wind_res)
solar_res <- 
oilgas2 <- raster(paste0(data.dir, "working/oilgas.v2.tif")) ; crs(oilgas)
oilgas <- raster(paste0(data.dir, "working/test.tif")) ; crs(oilgas)


# par(mfrow=c(2,2))
# plot(amph) ; plot(bird) ; plot(mamm) ; plot(rept)
# par(mfrow=c(1,1))


## READ THIS
# https://developers.google.com/earth-engine/guides/exporting


plot(amph) ; plot(st_geometry(ls), add = TRUE)
plot(oilgas) ; plot(st_geometry(ls), add = TRUE)
# ^ Won't line up unless the following is true, even tho they're different!
# It's as if the origin lat/lon for the rasters is wrong. B/c reprojecting ls (or sample) won't work either.
# > crs(amph) 
# CRS arguments:
#   +proj=aea +lat_0=0 +lon_0=0 +lat_1=29.5 +lat_2=45.5 +x_0=0 +y_0=0 +datum=NAD83 +units=m +no_defs 
# > crs(ls) 
# CRS arguments:
#   +proj=aea +lat_0=23 +lon_0=-96 +lat_1=29.5 +lat_2=45.5 +x_0=0 +y_0=0 +datum=WGS84 +units=m
# +no_defs 

crs(amph)
plot(amph) ; plot(sample, add = TRUE)
crs(sample)
