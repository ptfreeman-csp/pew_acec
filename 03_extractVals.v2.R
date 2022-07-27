today <- paste0(mid(Sys.Date(),3,2),
                mid(Sys.Date(),6,2),
                mid(Sys.Date(),9,2))


#########################################################
## EXTRACT VALUES OF CONSERVATION INDICATORS TO SAMPLE ##
#########################################################

## Add vars to list, var names to vector --------------------------------------

varsRasters <- list(amph, bird, mamm, rept, impSpp, connect,
                    intact, ecoRar, vegDiv, sage, annHerb,
                    climAcc, climStab, geoDiv, geoRar,
                    geotherm, oilGas, mineral, solar, wind, nightDark)


namesRasters <- c("amph", "bird", "mamm", "rept", "impSpp", "connect",
                  "intact", "ecoRar", "vegDiv", "sage", "annHerb",
                  "climAcc", "climStab", "geoDiv", "geoRar",
                  "geotherm", "oilGas", "mineral", "solar", "wind", "nightDark")



## Field office selection --------------------------------------------------------------

FO <- "RockSprings-WYO"
# FO <- "Lewistown-MT"



## Domain selection -----------------------------------------------------------

domains <- list(st_as_sf(west),
                blmWest,
                st_as_sf(wyo),
                blmWyo)
dNames <- c("west",
            "blmWest",
            "wyo",
            "blmWyo")

# domains <- list(st_as_sf(west),
#                 blmWest,
#                 st_as_sf(mt),
#                 blmMT)
# dNames <- c("west",
#             "blmWest",
#             "MT",
#             "blmMT")


## Sample size selection to match domains -------------------------------------

ns <- c(2000, 2000, 500, 500)
# ns <- c(26, 26, 24, 24)


## AOI selection --------------------------------------------------------------

aoisShapes <- list(rd_allx, ls)
aoisNames <- c(
  "Red Desert",
  "Little Sandy"
)

# aoisShapes <- list(lewis)
# aoisNames <- c("lewis")


## Loop to extract values------------------------------------------------------

# Empty vectors
an <- as.character()
dn <- as.character()
nv <- as.numeric()
vn <- as.character()
av <- as.numeric()
sv <- as.numeric()
sv.medians <- as.numeric()
sv.means <- as.numeric()
pv <- as.numeric()
cv <- as.numeric()
ev <- as.numeric()


# REFS:
# Options for extracting rank/percentile:
# Ref: https://stackoverflow.com/questions/41087162/calculate-a-percentile-of-dataframe-column-efficiently
# Choosing percent rank in loop below, but could consider ecdf, here:
# Define function for computing empirical cumulative distribution and querying val.
# ecdf_fun <- function(x,perc) ecdf(x)(perc)
# ecdf_fun(samp_vals, aoi_vals)


start <- Sys.time()
# Work thru each of the AOIs
for (i in 1:length(aoisShapes)){
# for (i in 1){
  # Iteratively select AOIs
  a <- aoisShapes[[i]]
  # Compute AOI area
  trgt_area <- sum(terra::area(a, unit = "m")) # sum in case multi-part 
  # Work thru each of the domains.
  for (j in 1:length(domains)){
    # Within a given domain, create n sample points
    pts = sf::st_sample(domains[[j]], size = ns[j])
    # Grow those sample points to match AOI area.
    sample <- gBuffer(as_Spatial(pts),
                    width = sqrt(trgt_area/(3.14)), # grow by AOI area's radius
                    byid = TRUE) %>% st_as_sf()
    # Work thru each of the indicator rasters, extracting values
    for (k in 1:length(varsRasters)){
    # for (k in 1:5){
      # Pull name of AOI and append to vector
      an <- c(an, aoisNames[i])
      print(paste0("AOI is ", aoisNames[i]))
      # Pull name of domain and append to vector
      dn <- c(dn, dNames[j])
      print(paste0("Domain is ", dNames[j]))
      # Pull sample size and append to vector
      nv <- c(nv, ns[j])
      print(paste0("Sample size is ", ns[j]))
      # Pull name of variable and append to vector
      vn <- c(vn, namesRasters[k])
      print(paste0("Variable is ",namesRasters[k]))
      # Extract mean value of variable within AOI
      av.temp <- exact_extract(varsRasters[[k]], a, fun = "mean")
      # Append that value to vector
      av <- c(av, av.temp)
      # Extract mean values of variable for all random sample points; as vector
      sv.temp <- exact_extract(varsRasters[[k]], sample, fun = "mean") %>% round(2)
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
}
(end <- start - Sys.time()) 


# Bind all together into dataframe
foo <- cbind(an, dn, nv, vn, av, sv.means, sv.medians, pv, cv, ev) %>% as.data.frame()
foo[c(3,5:10)] <- lapply(foo[c(3,5:10)], as.numeric) # Set numbers to numbers.

v <- 1
# v <- v+1
write.csv(foo, paste0(out.dir, FO, "_aoi_vs_sample_percentiles_", today, "_v",v, ".csv"))





##########################################
## CALC AREAS IN MIGRATION ROUTES & IBA ##
##########################################

aoisShapes <- list(rd_allx, ls)

a <- aoiShapes[[1]]; print(aoisNames[1])
a <- aoiShapes[[2]]; print(aoisNames[2])


# Alt: could do extract val and take sum of pixels (0 or 1) for aoi and samples.

# Area in square m in all Wyo; nb can't set km in area()
migrArea <- terra::area(migr) %>% sum()#/1000000
ibaArea <- terra::area(iba) %>% sum()#/1000000

migrAreaAoi <- st_as_sf(migr) %>% st_intersection(st_as_sf(a)) %>%
  as_Spatial() %>%terra::area() %>% sum()#/1000000
ibaAreaAoi <- st_as_sf(iba) %>% st_intersection(st_as_sf(a)) %>%
  as_Spatial() %>% terra::area() %>% sum()#/1000000

(migrPercAoi <- migrAreaAoi/migrArea)
(ibaPercAoi <- ibaAreaAoi/ibaArea)

(aoiArea <- a %>% terra::area() %>% sum())#/1000000
(wyoArea <- wyo %>%  terra::area() %>% sum())#/1000000

(aoiPercWyo <- aoiArea/wyoArea)












# 
# 
# ## OLD
# ## --------------------------------------------------------------------------
# start <- Sys.time()
# # for (i in 1:length(aoisShapes)){
# for (i in 1){
#   a <- aoisShapes[[i]]
#   trgt_area <- terra::area(a, unit = "m")
#   pts = sf::st_sample(domain, size = n)
#   sample <- gBuffer(as_Spatial(pts),
#                     width = sqrt(trgt_area/(3.14)), # get radius
#                     byid = TRUE) %>% st_as_sf()
#   # for (j in 1:length(varsRasters)){
#   for (j in 1:5){
#     # Pull name of AOI and append to vector
#     an <- c(an, aoisNames[i])
#     print(aoisNames[i])
#     # Pull name of variable and append to vector
#     vn <- c(vn, namesRasters[j])
#     print(namesRasters[j])
#     # Extract mean value of variable within AOI
#     av.temp <- exact_extract(varsRasters[[j]], a, fun = "mean")
#     # Append that value to vector
#     av <- c(av, av.temp)
#     # Extract mean values of variable for all random sample points; as vector
#     sv.temp <- exact_extract(varsRasters[[j]], sample, fun = "mean") %>% round(2)
#     # Get average across all random samples
#     sv.mean <- mean(sv.temp, na.rm = TRUE) %>% round(2)
#     # Get median across all random samples
#     sv.median <- median(sv.temp, na.rm = TRUE) %>% round(2)
#     # Bind those vectors.
#     sv <- rbind(sv, sv.temp)
#     # Bind those means
#     sv.means <- c(sv.means, sv.mean)
#     # Bind those medians
#     sv.medians <- c(sv.medians, sv.median)
#     # Extract perc rank of the aoi value relative to all sample values (first one)
#     pv.temp <- percent_rank(c(av.temp, sv.temp))[1] %>% round(2)
#     # Extract cumulative dist rank
#     cv.temp <- cume_dist(c(av.temp, sv.temp))[1] %>% round(2)
#     # Create empirical cumulative distribution function from those sample values
#     ef <- ecdf(sv.temp)
#     # # Extract the percentile of the AOI value within that distribution
#     ev.temp <- ef(av.temp) %>% round(2)
#     # Append those percentiles to a vector
#     pv <- c(pv, pv.temp)
#     cv <- c(cv, cv.temp)
#     ev <- c(ev, ev.temp)
#     
#   }
# }
# (end <- start - Sys.time()) 
# 
# foo <- cbind(an, vn, av, sv.means, sv.medians, pv, cv, ev, sv) %>% as.data.frame()
# foo$domain <- domain_name
# foo$n <- n
# # view(foo)
# 
# v <- 1
# # v <- v+1
# write.csv(foo, paste0(out.dir, FO, "_aoi_vs_sample_percentiles_", domain_name, n,"_", today, "_v",v, ".csv"))



# https://stackoverflow.com/questions/45894133/deleting-tmp-files

