domain <- biome
boundary <- ynp

n <- 100 # The number of samples generated in each iteration
n <- 10

# Generate n random points within domain; grow those points so extent = boundary's
points = sf::st_sample(domain, size = n)

# Plot using the ggplot geom_sf function.
ggplot() + 
  geom_sf(aes(), data=domain) + 
  geom_sf(aes(), data=points)





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



