#########################################################
## EXTRACT VALUES OF CONSERVATION INDICATORS TO SAMPLE ##
#########################################################

varsRasters <- list(amph,
             bird,
             mamm,
             rept,
             impSpp,
             connect,
             intact,
             ecoRar,
             vegDiv,
             sage,
             annHerb,
             climAcc,
             climStab,
             geoDiv,
             geoRar,
             geotherm,
             oilGas,
             solar,
             wind)

namesRasters <- c("amph", "bird", "mamm", "rept", "impSpp", "connect",
                  "intact", "ecoRar", "vegDiv", "sage", "annHerb",
                  "climAcc", "climStab", "geoDiv", "geoRar",
                  "geotherm", "oilGas", "solar", "wind")

aoisShapes <- list(rd_desigx,
             rd_allx,
             ls)

aoisNames <- c("Red Desert - no desig",
               "Red Desert - no desig nor spec mgmt",
               "Little Sandy")

FO <- "RockSprings-WYO"

# -----------------------------------------------------------------------------
# Select size of random sample
n <- 1000
# n <- 100
# n <- 10

# Select domain for generating random sample
domain <- west
# domain <- blmWest %>% st_as_sf()
# domain <- blmWyo
# domain <- wyo %>% st_as_sf()

# Empty vectors
an <- NULL
vn <- NULL
av <- NULL
sv <- NULL
sv.medians <- NULL
sv.means <- NULL
pv <- NULL
cv <- NULL
ev <- NULL

# Options for extracting rank/percentile:
# Ref: https://stackoverflow.com/questions/41087162/calculate-a-percentile-of-dataframe-column-efficiently
# Choosing percent rank in loop below, but could consider ecdf, here:
# Define function for computing empirical cumulative distribution and querying val.
# ecdf_fun <- function(x,perc) ecdf(x)(perc)
# ecdf_fun(samp_vals, aoi_vals)

for (i in 1:length(aoisShapes)){
# for (i in 1){
  a <- aoisShapes[[i]]
  trgt_area <- terra::area(a, unit = "m")
  pts = sf::st_sample(domain, size = n)
  sample <- gBuffer(as_Spatial(pts),
                    width = sqrt(trgt_area/(3.14)), # get radius
                    byid = TRUE) %>% st_as_sf()
  for (j in 1:length(varsRasters)){
  # for (j in 2:8){
    # Pull name of AOI and append to vector
    an <- c(an, aoisNames[i])
    print(aoisNames[i])
    # Pull name of variable and append to vector
    vn <- c(vn, namesRasters[j])
    print(namesRasters[j])
    # vn <- c(vn, names(varsRasters[[j]]))
    # Extract mean value of variable within AOI
    av.temp <- exact_extract(varsRasters[[j]], a, fun = "mean")
    # Append that value to vector
    av <- c(av, av.temp)
    # Extract mean values of variable for all random sample points; as vector
    sv.temp <- exact_extract(varsRasters[[j]], sample, fun = "mean") %>% round(2)
    # Get average across all random samples
    sv.mean <- mean(sv.temp, na.rm = TRUE) %>% round(2)
    # Get median across all random samples
    sv.median <- median(sv.temp, na.rm = TRUE) %>% round(2)
    # Bind those vectors.
    sv <- rbind(sv, sv.temp)
    # Bind those means
    sv.means <- c(sv.means, sv.mean)
    # Bind those medians
    sv.medians <- c(sv.medians, sv.median)
    # Extract perc rank of the aoi value relative to all sample values (first one)
    pv.temp <- percent_rank(c(av.temp, sv.temp))[1] %>% round(2)
    # Extract cumulative dist rank
    cv.temp <- cume_dist(c(av.temp, sv.temp))[1] %>% round(2)
    # Create empirical cumulative distribution function from those sample values
    ef <- ecdf(sv.temp)
    # # Extract the percentile of the AOI value within that distribution
    ev.temp <- ef(av.temp) %>% round(2)
    # Append those percentiles to a vector
    pv <- c(pv, pv.temp)
    cv <- c(cv, cv.temp)
    ev <- c(ev, ev.temp)
    
  }
}


# an
# vn
# av
# sv.temp
# sv
# sv.means
# sv.medians
# pv


foo <- cbind(an, vn, av, sv.means, sv.medians, pv, cv, ev, sv)
view(foo)

v <- 1
# v <- v+1
version <- paste0("ver",v)
write.csv(foo, paste0(out.dir, FO, "_aoi_vs_sample_percentiles_", domain, n,"_", today, version, ".csv"))



##########################################
## CALC AREAS IN MIGRATION ROUTES & IBA ##
##########################################

# Alt: could do extract val and take sum of pixels (0 or 1) for aoi and samples.

# Area in square m in all Wyo; nb can't set km in area()
migrArea <- terra::area(migr) %>% sum()#/1000000
ibaArea <- terra::area(iba) %>% sum()#/1000000

migrAreaAoi <- st_as_sf(migr) %>% st_crop(aoi) %>%
  as_Spatial() %>%terra::area() %>% sum()#/1000000
ibaAreaAoi <- st_as_sf(iba) %>% st_crop(aoi) %>%
  as_Spatial() %>% terra::area() %>% sum()#/1000000

migrPercAoi <- migrAreaAoi/migrArea
ibaPercAoi <- ibaAreaAoi/ibaArea

aoiArea <- aoi %>% terra::area() %>% sum()#/1000000
wyoArea <- wyo %>%  terra::area() %>% sum()#/1000000

aoiPercWyo <- aoiArea/wyoArea
