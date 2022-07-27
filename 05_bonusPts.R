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
