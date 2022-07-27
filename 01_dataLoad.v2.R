
# maybe necessary if some raster aren't loading
# unlink(".RData")

######################################
## DATA COLLECTION & PRE-PROCESSING ##
######################################


#-------------------------------------------------------------------------------
## Function to load features, set common crs, and fix any invalid geometries
load_f <- function(f) {
  # proj.crs <- "+proj=longlat +datum=WGS84 +no_defs"
  # Setting below and assigning this to spp richness rasters is the only way to get them to line-up!
  proj.crs <- "+proj=aea +lat_0=23 +lon_0=-96 +lat_1=29.5 +lat_2=45.5 +x_0=0 +y_0=0 +datum=WGS84 +units=m +no_defs"
  # proj.crs <- "+proj=aea +lat_0=0 +lon_0=0 +lat_1=29.5 +lat_2=45.5 +x_0=0 +y_0=0 +datum=NAD83 +units=m +no_defs"
  # proj.crs <- "+proj=aea +lat_0=37.5 +lon_0=-96 +lat_1=29.5 +lat_2=45.5 +x_0=0 +y_0=0 +datum=NAD83 +units=m +no_defs"
  read_sf(f) %>%
    st_transform(proj.crs) %>%
    st_make_valid() %>%
    st_buffer(dist = 0)
}

# proj.crs <- "+proj=longlat +datum=WGS84 +no_defs"
proj.crs <- "+proj=aea +lat_0=23 +lon_0=-96 +lat_1=29.5 +lat_2=45.5 +x_0=0 +y_0=0 +datum=WGS84 +units=m +no_defs"
# proj.crs <- "+proj=aea +lat_0=0 +lon_0=0 +lat_1=29.5 +lat_2=45.5 +x_0=0 +y_0=0 +datum=NAD83 +units=m +no_defs"
# proj.crs <- "+proj=aea +lat_0=37.5 +lon_0=-96 +lat_1=29.5 +lat_2=45.5 +x_0=0 +y_0=0 +datum=NAD83 +units=m"




#-------------------------------------------------------------------------------
## Load AOIs
# Load Red Desert all designations removed
rd_desigx <- load_f(paste0(data.dir,
                           "RockSpringsFO_Wyo/RedDesert-LittleSandyLandscape/RD_IBA_EraseDesignations.shp")) %>%
  as_Spatial()

# Load Red Desert all designations AND special mgmt area removed
rd_allx <- load_f(paste0(data.dir,
                         "RockSpringsFO_Wyo/RedDesert-LittleSandyLandscape/RD_IBA_EraseAll.shp")) %>%
  as_Spatial()

# Load Red Desert all designations AND special mgmt area removed AND other areas
rd_allx <- load_f(paste0(data.dir,
                         "RockSpringsFO_Wyo/RedDesert-LittleSandyLandscape/RD_IBA_EraseAll2.shp")) %>%
  as_Spatial()

# Load Little Sandy
ls <- load_f(paste0(data.dir,
                    "RockSpringsFO_Wyo/RedDesert-LittleSandyLandscape/RD_LS_IBA_RSFO - Copy.shp")) %>%
  filter(SITE_NAME == "Little Sandy Landscape") %>%
  as_Spatial()

# Lewistown MT
lewis <- load_f(paste0(data.dir, "LewistownFO_MT/Lewistown ACEC files/Priority Sage-Grouse Habitat/Lewistown_GreaterSageGrouse_PriorityHabitat.shp")) %>%
  as_Spatial() %>%
  aggregate() #%>%
  


#-------------------------------------------------------------------------------
# Load CONUS; retain western states.
usa <- load_f("C:/Users/clitt/OneDrive/Desktop/data_gen/political/tl_2012_us_state.shp")
keeps <- c("Washington", "Oregon", "California", "Idaho", "Montana",
           "Wyoming", "Nevada", "Utah", "Colorado", "Arizona", "New Mexico")
west <- usa %>% filter(NAME %in% keeps)
wyo <- usa %>% filter(NAME == "Wyoming") %>% as_Spatial()
mt <- usa %>% filter(NAME == "Montana") %>% as_Spatial()
wyoArea <- terra::area(wyo) %>% sum()/1000000
# unique(west$NAME) ; plot(west)
remove(usa, keeps)




#-------------------------------------------------------------------------------
# Load sagebrush biome; clip to west
sb <- load_f(paste0(local.data.dir,"eco/US_Sagebrush_Biome_2019.shp")) %>% st_crop(west)




#-------------------------------------------------------------------------------
# Load blm; convert to polygon using stars package; fix spatial issues (see links 00_setup)
# Ref: https://r-spatial.github.io/stars/
# Ref: https://gis.stackexchange.com/questions/192771/how-to-speed-up-raster-to-polygon-conversion-in-r

# sf::sf_use_s2(FALSE)
# 
# blmWest <- raster(paste0(data.dir, "working/blm_west.tif"))
# blmWest <- sf::as_Spatial(sf::st_as_sf(stars::st_as_stars(blmWest),
#                               as_points = FALSE, merge = TRUE)) %>%
#   st_as_sf() %>%
#   st_make_valid() %>%
#   ensure_multipolygons() %>%
#   st_buffer(dist = 0) %>%
#   st_transform(proj.crs)
# 
# # Set non-BLM lands to NA (currently 0)
# blmWest[blmWest$blm_west == 0,] <- NA 
# # Remove empty geometries
# blmWest <- blmWest %>% filter(!st_is_empty(.))
#
# # Generate Wyo-only layer (crop only gives bounding rectangle; intersect instead)
# blmWyo <- blmWest %>% st_intersection(st_as_sf(wyo)) 
# blmMT <- blmWest %>% st_intersection(st_as_sf(mt))
#
# 
# # Write BLMWest and BLM Wyo layer
# shapefile(as_Spatial(blmWest), paste0(data.dir,"working/blm_west.shp")) 
# shapefile(as_Spatial(blmWyo), paste0(data.dir,"working/blm_wyo.shp"))
# shapefile(as_Spatial(blmMT), paste0(data.dir,"working/blm_mt.shp"))


blmWest <- load_f(paste0(data.dir, "working/blm_west.shp"))
blmWyo <- load_f(paste0(data.dir,"working/blm_wyo.shp"))
blmMT <- load_f(paste0(data.dir, "working/blm_mt.shp"))


#-------------------------------------------------------------------------------
## Load indicators
setwd("G:/My Drive/2Pew ACEC/Pew_ACEC/data/working")

(list <- list.files(pattern= ".tif"))

# Load and process spp richness. These are orig from:
# https://www.sciencebase.gov/catalog/item/5bef2935e4b045bfcadf732c
# See notes at bottom re: mis-matched CRS from GEE.
# 
# start <- Sys.time()
# (amph_west <- raster(paste0(local.data.dir,
#                        "spp/amphibian_richness_habitat30m.tif")) %>% crop(west) %>% mask(west))
# writeRaster(amph_west, "amph_west.tif")
# (end <- start - Sys.time())
# start <- Sys.time()
# amph_west_270m <- amph_west %>% aggregate(fact = 9, fun = mean) # 30m --> 270m
# writeRaster(amph_west_270m, "amph_west_270m.tif", overwrite = TRUE)
# (end <- start - Sys.time())


# start <- Sys.time()
# (bird_west <- raster(paste0(local.data.dir,
#                             "spp/bird_richness_habitat30m.tif")) %>% crop(west) %>% mask(west))
# # writeRaster(bird_west, "bird_west.tif", overwrite = TRUE)
# (end <- start - Sys.time())
# start <- Sys.time()
# bird_west_270m <- bird_west %>% aggregate(fact = 9, fun = mean)
# writeRaster(bird_west_270m, "bird_west_270m.tif", overwrite = TRUE)
# (end <- start - Sys.time())


# start <- Sys.time()
# (mamm_west <- raster(paste0(local.data.dir,
#                             "spp/mammal_richness_habitat30m.tif")) %>% crop(west) %>% mask(west))
# # writeRaster(mamm_west, "mamm_west.tif", overwrite = TRUE)
# (end <- start - Sys.time())
# start <- Sys.time()
# mamm_west_270m <- mamm_west %>% aggregate(fact = 9, fun = mean)
# (end <- start - Sys.time())
# start <- Sys.time()
# writeRaster(mamm_west_270m, "mamm_west_270m.tif", overwrite = TRUE)
# (end <- start - Sys.time())
# 
#  
# start <- Sys.time()
# (rept_west <- raster(paste0(local.data.dir,
#                             "spp/reptile_richness_habitat30m.tif")) %>% crop(west) %>% mask(west))
# # writeRaster(rept_west, "rept_west.tif", overwrite = TRUE)
# (end <- start - Sys.time())
# start <- Sys.time()
# rept_west_270m <- rept_west %>% aggregate(fact = 9, fun = mean)
# writeRaster(rept_west_270m, "rept_west_270m.tif", overwrite = TRUE)
# (end <- start - Sys.time())

## -----------------------------------------

(amph <- raster("amph_west_270m.tif")) 
(bird <- raster("bird_west_270m.tif"))
(mamm <- raster("mamm_west_270m.tif"))
(rept <- raster("rept_west_270m.tif"))


(impSpp <- raster("impSppNorm.tif")) ; crs(impSpp) <- proj.crs


# Ecological connectivity, intactness, system div.
(connect <- raster("connNorm.tif"))
(intact <- raster("intactNorm.tif"))
(ecoRar <- raster("ecorarityaggto270norm.tif"))
(vegDiv <- raster("gapdiv270mnorm.tif"))


# Sage & annual herb
# RCMAP layers via GEE (sageNorm, annHerbNorm) had goofy CRS. Went to source at SciBase (even tho 30m)
# Both requisite layers for 2019 and 2020 errored,  hence using 2018.
# Below, loaded orig layers at SciBase then cropped and masked to sagebrush biome.

# start <- Sys.time()
# (sage <- raster(paste0(local.data.dir,
#                        "eco/Sagebrush_2009_2020/rcmap_sagebrush_2018.img")) %>% crop(sb) %>% mask(sb))
# writeRaster(sage, "sage.tif")
# (end <- start - Sys.time())
# 
# start <- Sys.time()
# (annHerb <- raster(paste0(local.data.dir,
#                           "eco/Annual_Herbaceous_2009_2020/rcmap_annual_herbaceous_2018.img")) %>% crop(sb) %>% mask(sb))
# writeRaster(annHerb, "annHerb.tif")
# (end <- start - Sys.time())
# 
# (sage <- raster("sage.tif"))
# (annHerb <- raster("annHerb.tif"))
# 
# start <- Sys.time()
# boo <- sage %>% resample(amph)
# writeRaster(boo, "sage_270m.tif")
# (end <- start - Sys.time())
# 
# start <- Sys.time()
# foo <- annHerb %>% resample(amph)
# writeRaster(foo, "annHerb_270m.tif")
# (end <- start - Sys.time())

(sage <- raster("sage_270m.tif"))
(annHerb <- raster("annHerb_270m.tif"))


# Clim
(climAcc <- raster("ClimAccNorm.tif"))
(climStab <- raster("ClimStabNorm.tif"))


# Geophys
(geoDiv <- raster("div_ergo_lth270mnorm.tif"))
(geoRar <- raster("georarity270mnorm.tif"))

 
# Water
(waterAvail <- raster("wateravail_allwater2.tif"))
(waterFut <- raster("wateruseddwaterdist2norm.tif"))


# Nat res
(geotherm <- raster("geotherm_lt10pslop_nourbFWPAspldist.tif"))
(oilGas <- raster("oilgas5k6cellmean270mnorm_PAs0UrbH20.tif"))
(mineral <- raster("mrdsPA5kmeanmnormPAs0UrbH20.tif"))
(solar <- raster("maxdnighi_lt5pslope_ddpowerline4normPAs0UrbH20.tif"))
(wind <- raster("windprobi_lt30pslope_ddpowerline4normPAs0UrbH20MULT.tif"))


# Misc
(nightDark <- raster("virrs2011.tif")) 
# Migration routes.
w1 <- load_f(paste0(data.dir,"source/WGFD_MuleDeerCorridorComplexes/MuleDeerMigrationBaggsWGFDCorridor.shp")) %>% as_Spatial()
w2 <- load_f(paste0(data.dir,"source/WGFD_MuleDeerCorridorComplexes/MuleDeerMigrationPlatteValleyWGFDCorridor.shp")) %>% as_Spatial()
w3 <- load_f(paste0(data.dir,"source/WGFD_MuleDeerCorridorComplexes/MuleDeerMigrationSubletteWGFDCorridor.shp")) %>% as_Spatial()
# wyoMule <- raster::bind(w1, w2, w3) %>% st_as_sf() %>% fasterize(amph)
migr <- union(w1, w2) %>% union(w3)
remove(w1, w2, w3)


#IBA in Wyo; 
# iba <- load_f(paste0(data.dir,"source/IBA_CONUS/Important_Bird_Areas_Polygon_Public_View.shp")) %>% st_crop(wyo)
iba <- load_f(paste0(data.dir, "RockSpringsFO_Wyo/audiba_WY_20150818/audiba_WY_20150818.shp")) %>% as_Spatial()

setwd("G:/My Drive/2Pew ACEC/Pew_ACEC/")


# ------------------------------------------------------------------------------
# ------------------------------------------------------------------------------

## Spp richness CRS conundrum.
# These are orig from https://www.sciencebase.gov/catalog/item/5bef2935e4b045bfcadf732c
# I had downloaded, from SciBase, uploaded to GEE, then re-downloaded clipped and at lower res via Colab.
# In GEE/Colab, projection is given as:
# 'PROJCS["NAD_1983_Albers",
# \n  GEOGCS["NAD83",
# \n    DATUM["North_American_Datum_1983",
# \n      SPHEROID["GRS 1980", 6378137.0, 298.2572221010042, AUTHORITY["EPSG","7019"]],
# \n      AUTHORITY["EPSG","6269"]],
# \n    PRIMEM["Greenwich", 0.0],
# \n    UNIT["degree", 0.017453292519943295],
# \n    AXIS["Longitude", EAST],
# \n    AXIS["Latitude", NORTH],
# \n    AUTHORITY["EPSG","4269"]],
# \n  PROJECTION["Albers_Conic_Equal_Area"],
# \n  PARAMETER["central_meridian", -96.0],
# \n  PARAMETER["latitude_of_origin", 23.0],
# \n  PARAMETER["standard_parallel_1", 29.5],
# \n  PARAMETER["false_easting", 0.0],
# \n  PARAMETER["false_northing", 0.0],
# \n  PARAMETER["standard_parallel_2", 45.5],
# \n  UNIT["m", 1.0],
# \n  AXIS["x", EAST],
# \n  AXIS["y", NORTH]]'}
# Yet loading the GEE/Colab export in here gives a crs of:
# +proj=aea +lat_0=0 +lon_0=0 +lat_1=29.5 +lat_2=45.5 +x_0=0 +y_0=0 +datum=NAD83 +units=m +no_defs 
# So somehow export screwed this up? Assigning crs that matches GEE/Colab AND USGS orig works:
# +proj=aea +lat_0=23 +lon_0=-96 +lat_1=29.5 +lat_2=45.5 +x_0=0 +y_0=0 +datum=WGS84 +units=m +no_defs
