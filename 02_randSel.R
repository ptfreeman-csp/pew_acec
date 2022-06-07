#######################################
## GENERATE RANDOM SAMPLE OF PA AREA ##
#######################################

today <- paste0(mid(Sys.Date(),3,2),
                mid(Sys.Date(),6,2),
                mid(Sys.Date(),9,2))

domain <- west # Domain from which to sample values.
boundary <- ls # Boundary of existing/proposed PA.

# Compute target area of that PA. Convert from simple feature (sf) to spatial.
(trgt_area <- terra::area(as_Spatial(boundary), unit = "m")) 
# ^ THIS CAN'T BE LAT/LON


# The number of samples generated in each iteration
n <- 1000 # consider starting with way too many then pruning.
# n <- 100
# n <- 10

# Generate n random points within domain
pts = sf::st_sample(domain, size = n) ; str(pts)
# pts = spsample(domain, n = n, type = random); str(pts)



# ############# PRUNING OPTION #################
# # ref:# https://www.jla-data.net/eng/creating-and-pruning-random-points-and-polygons/
# # Prune the too-many points
# i <- 1 # iterator start
# 
# buffer_size <- sqrt(trgt_area) # minimal distance to be enforced (in meters)
# 
# repeat( {
# 
#   #  create buffer around i-th point
#   buffer <- st_buffer(pts[i], buffer_size )
# 
#   offending <- pts %>%  # start with the intersection of master points...
#     st_intersects(buffer, sparse = F) # ... and the buffer, as a vector
# 
#   # i-th point is not really offending; retain it
#   offending[i] <- FALSE
# 
#   # If there are any offending points left, re-assign the master points
#   # with the offending ones excluded. This is the main pruning part.
#   pts <- pts[!offending]
# 
#   if ( i >= length(pts)) {
#     # the end was reached; no more points to process
#     break
#   } else {
#     # rinse & repeat
#     i <- i + 1
#   }
# 
# } )
# 
# pts <- pts[1:100] # Retain just the first 100.
# # These are now random-but-regular.
# 
# #####################################################


ggplot() + 
  geom_sf(aes(), data=west) +
  geom_sf(aes(), data=pts)


# Grow buffer around each point to be same size as PA
# ?gBuffer
sample <- gBuffer(as_Spatial(pts),
               width = sqrt(trgt_area)/2, # get length of area side, halve it
               byid = TRUE) # keep them all separate polys
               # capStyle = "SQUARE") %>% st_as_sf() ;

sample <- as(sample, "sf")

par(mfrow=c(1,1))
plot(amph)
plot(sample, add = TRUE) #; terra::area(sample[1])
crs(amph)
crs(sample)
