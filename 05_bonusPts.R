##########################################
## CALC AREAS IN MIGRATION ROUTES & IBA ##
##########################################

acre_in_km <- 247.105

aoisShapes <- list(rd_allx, ls)
aoisNames <- c(
  "Red Desert",
  "Little Sandy"
)

# aoisShapes <- list(lewis)
# aoisNames <- c(
#   "Lewistown"
# )


# a <- aoisShapes[[1]]; print(aoisNames[1])
a <- aoisShapes[[2]]; print(aoisNames[2])

# iba <- iba_mt %>% as_Spatial()
iba <- iba_wyo

# Area in square m; nb can't set km in area()
migrArea <- terra::area(migr) %>% sum()#/1000000
ibaArea <- terra::area(iba) %>% sum()#/1000000

# Get intersecting area; nb error may indicated ZERO overlap.
migrAreaAoi <- st_as_sf(migr) %>%
  st_intersection(st_as_sf(a)) %>%
  as_Spatial() %>%
  terra::area() %>%
  sum()#/1000000
ibaAreaAoi <- st_as_sf(iba) %>%
  st_intersection(st_as_sf(a)) %>%
  as_Spatial() %>%
  terra::area() %>%
  sum()#/1000000

# Of all migration corridor or IBA area in the state, AOI has x %.
(migrPercAoi <- migrAreaAoi/migrArea)
(ibaPercAoi <- ibaAreaAoi/ibaArea)

(aoiArea <- a %>% terra::area() %>% sum())#/1000000
(wyoArea <- wyo %>%  terra::area() %>% sum())#/1000000
# (mtArea <- mt %>%  terra::area() %>% sum())#/1000000

(aoiPercWyo <- aoiArea/wyoArea)
# (aoiPercMt <- aoiArea/mtArea)

(aoiArea/1000000*acre_in_km)

