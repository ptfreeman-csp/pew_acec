today <- paste0(mid(Sys.Date(),3,2),
                mid(Sys.Date(),6,2),
                mid(Sys.Date(),9,2))

domain <- biome # Domain from which to sample values.
boundary <- ynp # Boundary of existing/proposed PA.

# Compute target area of that PA. Convert from simple feature (sf) to spatial.
trgt_area <- area(as_Spatial(ynp)) # 8904687776 sqm; checks out.
# boundary.r <- fasterize(boundary, amph) %>%
#   crop(ynp) %>% mask(ynp) # Turn into raster but keep small.
# area(boundary.r) # Not recommended as object is projected and not lat/long



# The number of samples generated in each iteration
n <- 1000 # consider starting with way too many then pruning.
n <- 100
# n <- 10

# Generate n random points within domain
pts = sf::st_sample(domain, size = n) ; str(pts)
# pts = spsample(domain, n = n, type = random); str(pts)





############# PRUNING OPTION #################
# ref:# https://www.jla-data.net/eng/creating-and-pruning-random-points-and-polygons/
# Prune the too-many points
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
# pts <- pts[1:100]

#####################################################


ggplot() + 
  geom_sf(aes(), data=biome) + 
  geom_sf(aes(), data=pts) +
  geom_sf(aes(), data = foo, col = 'red')



# Grow buffer around each point to be same size as PA
?gBuffer
sample <- gBuffer(as_Spatial(pts),
               width = sqrt(trgt_area)/2, # get length of area side, halve it
               byid = TRUE, # keep them all separate polys
               capStyle = "SQUARE") #%>% st_as_sf()

plot(amph)
plot(sample, add = TRUE)
plot(ynp, add = TRUE)
plot(pts, add = TRUE)

# But there's lotsa overlap. Consider creating more points than necessary and pruning.




ggplot() + 
  geom_sf(aes(), data=biome) + 
  geom_sf(aes(), data=foo)

plot(foo)




# Plot using the ggplot geom_sf function.
ggplot() + 
  geom_sf(aes(), data=boundary.r) + 
  geom_sf(aes(), data=pts)

?gBuffer

str(points)

points <- st_sample(domain, )
?st_sample


str(domain)
# Create an sf polygon
polygon = sf::st_polygon(polygon)
# Sample 50 random points within the polygon
points = sf::st_sample(polygon, size=50)






?ldply

## Seed and grow random samples
r.samples <- ldply(seq_len(n), function(l) {
  data.frame(id=l, growRandomSample(inOGR=bndry, sampleSpace=extents[[o]])) # setSeed=rng.seed[m]
})

?growRandomSample # can't find this defined anywhere in R. homegrown function?

# Alt: generate random points then tesslate (to certain size?) around them
https://www.jla-data.net/eng/creating-and-pruning-random-points-and-polygons/
  
  

  # raster polygons  
  # https://stackoverflow.com/questions/9989508/creating-random-polygons-within-a-set-shapefiles-boundary-in-r

?ldply
?gBuffer



