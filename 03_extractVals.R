#########################################################
## EXTRACT VALUES OF CONSERVATION INDICATORS TO SAMPLE ##
#########################################################

?extract
# Despite option for FUN = mean, seems like extracting to polygon still retains all vals.
# Turning into dataframe likely shrinks it, tho. But lapply mean to list then df may be best.
# ALSO, can do buffer on-the-fly rather than generating separate polygon layer.

# I don't think this is legit, but it's the only way to get extract to line-up!
crs(mamm) = "+proj=aea +lat_0=23 +lon_0=-96 +lat_1=29.5 +lat_2=45.5 +x_0=0 +y_0=0 +datum=WGS84 +units=m +no_defs"

start <- Sys.time()
foo1 <- raster::extract(mamm, sample, FUN = mean, na.rm = TRUE)
boo1 <- unlist(lapply(foo1, FUN = mean)) # same

foo2 <- raster::extract(mamm, sample)
boo2 <- unlist(lapply(foo2, FUN = mean)) # same

goo <- as_Spatial(pts)
foo3 <- raster::extract(mamm, goo, buffer = sqrt(trgt_area)/2)
boo3 <- unlist(lapply(foo3, FUN = mean)) # same

print(Sys.time() - start)

# install.packages("exactextractr")
library(exactextractr)

foo4 <- exact_extract(mamm, sample, fun = "mean")
# ^ SUPER FAST!!

foo5 <- exact_extract(mamm, ynp, fun = "mean")

rank <- percent_rank()
?percent_rank

quantile(foo4)

d <- ecdf(foo4)
d(foo5)
min(foo4)
max(foo4)
d(min(foo4))
d(max(foo4))
hist(foo4)
quantile(foo4)
d(60)

ecdf_fun <- function(x,perc) ecdf(x)(perc)
ecdf_fun(foo4, foo5)
