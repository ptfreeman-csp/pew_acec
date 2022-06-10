

# maybe necessary if some raster aren't loading
# unlink(".RData")

######################################
## DATA COLLECTION & PRE-PROCESSING ##
######################################

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


######################################
## Load domains and AOIs

# AOIs
# Load Red Desert all designations removed
load_f <- read_sf(paste0(data.dir,
                           "RockSpringsFO_Wyo/RedDesert-LittleSandyLandscape/RD_IBA_EraseDesignations.shp"))
# Load Red Desert all designations AND special mgmt area removed
rd_allX <- load_f(paste0(data.dir,
                         "RockSpringsFO_Wyo/RedDesert-LittleSandyLandscape/RD_IBA_EraseAll.shp"))
# Load Little Sandy
ls <- load_f(paste0(data.dir,
                    "RockSpringsFO_Wyo/RedDesert-LittleSandyLandscape/RD_LS_IBA_RSFO - Copy.shp")) %>%
  filter(SITE_NAME == "Little Sandy Landscape")


# Load CONUS; retain western states.
usa <- load_f("C:/Users/clitt/OneDrive/Desktop/data_gen/political/tl_2012_us_state.shp")
keeps <- c("Washington", "Oregon", "California", "Idaho", "Montana",
           "Wyoming", "Nevada", "Utah", "Colorado", "Arizona", "New Mexico")
west <- usa %>% filter(NAME %in% keeps)
wyo <- usa %>% filter(NAME == "Wyoming")
# unique(west$NAME) ; plot(west)
remove(usa, keeps)


# Load sagebrush biome
sb <- load_f(paste0(data.dir,"source/US_Sagebrush_Biome_2019.shp"))

# # Load blm
blm <- raster(paste0(data.dir, "working/blm_west.tif")) ; blm
plot(blm)

######################################
## Load indicators
setwd("G:/My Drive/2Pew ACEC/Pew_ACEC/data/working")

(list <- list.files(pattern= ".tif"))

# Load spp richness.
# These were orig from https://www.sciencebase.gov/catalog/item/5bef2935e4b045bfcadf732c
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
proj.crs <- "+proj=aea +lat_0=23 +lon_0=-96 +lat_1=29.5 +lat_2=45.5 +x_0=0 +y_0=0 +datum=WGS84 +units=m +no_defs"
(amph <- raster("amph.tif")) ; crs(amph) <- proj.crs
(bird <- raster("bird.tif")) ; crs(bird) <- proj.crs
(mamm <- raster("mamm.tif")) ; crs(mamm) <- proj.crs
(rept <- raster("rept.tif")) ; crs(rept) <- proj.crs
(impSpp <- raster("impSppNorm.tif")) ; #crs(impSpp) <- proj.crs

# Alt: load originals, except that they're GIANT 
# amph <- raster(paste0(loc.data.dir,"amphibian_richness_habitat30m.tif")) # %>% crop(west) %>% mask(west)
# bird <- raster(paste0(loc.data.dir,"bird_richness_habitat30m.tif")) 
# mamm <- raster(paste0(loc.data.dir,"mammal_richness_habitat30m.tif")) 
# rept <- raster(paste0(loc.data.dir,"reptile_richness_habitat30m.tif")) 

##########################################
##########################################
##########################################
########## FIX ME ########################
##########################################
##########################################
##########################################
# Ecological connectivity, intactness, system div.
# Sage/annHerb clipped to sagebrush biome b/c vals irrelevant elsewhere; 0-100 not 0-1

########### WON'T WORK WITH SAMPLE ")) ###########
(annHerb <- raster("annHerbNorm.tif"))  
(sage <- raster("sageNorm.tif"))
########### WON'T WORK WITH SAMPLE ")) ########### 

(connect <- raster("connNorm.tif"))
(intact <- raster("intactNorm.tif"))
(ecosysRarity <- raster("ecorarityaggto270norm.tif"))
(vegDiv <- raster("gapdiv270mnorm.tif"))


samp_vals <- exact_extract(vegDiv, sample, fun = "mean") ; head(samp_vals)

# Clim
climAcc <- raster("ClimAccNorm.tif") ; crs(climAcc)
climStab <- raster("ClimStabNorm.tif") ; crs(climStab)


# Geophys
geoDiv <- raster("div_ergo_lth270mnorm.tif") ; crs(geoDiv)
geoRarity <- raster("georarity270mnorm.tif") ; crs(geoRarity)

 
# Water
waterAvail <- raster("wateravail_allwater2.tif") ; crs(waterAvail)
waterFut <- raster("wateruseddwaterdist2norm.tif") ; crs(waterFut)


# Nat res
geotherm <- raster("geotherm_lt10pslop_nourbFWPAspldist.tif") ; crs(geotherm)
oilGas <- raster("oilgas5k6cellmean270mnorm_PAs0UrbH20.tif") ; crs(oilGas)
solar <- raster("maxdnighi_lt5pslope_ddpowerline4normPAs0UrbH20.tif") ; crs(solar)
wind <- raster("windprobi_lt30pslope_ddpowerline4normPAs0UrbH20MULT.tif") ; crs(wind)


# Misc
nightDark <- raster("virrs2011.tif") ; crs(nightDark)

w1 <- load_f(paste0(data.dir,"source/WGFD_MuleDeerCorridorComplexes/MuleDeerMigrationBaggsWGFDCorridor.shp")) %>% as_Spatial()
w2 <- load_f(paste0(data.dir,"source/WGFD_MuleDeerCorridorComplexes/MuleDeerMigrationPlatteValleyWGFDCorridor.shp")) %>% as_Spatial()
w3 <- load_f(paste0(data.dir,"source/WGFD_MuleDeerCorridorComplexes/MuleDeerMigrationSubletteWGFDCorridor.shp")) %>% as_Spatial()
wyoMule <- raster::bind(w1, w2, w3) %>% st_as_sf() %>% fasterize(amph) #%>% crop(wyo) %>% mask(wyo)
remove(w1, w2, w3)

setwd("G:/My Drive/2Pew ACEC/Pew_ACEC/")

