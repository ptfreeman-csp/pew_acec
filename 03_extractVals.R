#########################################################
## EXTRACT VALUES OF CONSERVATION INDICATORS TO SAMPLE ##
#########################################################

# install.packages("exactextractr")
library(exactextractr)

samp_vals <- exact_extract(oilgas, sample, fun = "mean")
min(samp_vals) ; max(samp_vals)
hist(samp_vals)
quantile(samp_vals)
(aoi_vals <- exact_extract(oilgas, ls, fun = "mean"))


# Create empirical cumulative distribution function
d <- ecdf(samp_vals)
d(min(samp_vals)) # Should be zero
d(max(samp_vals)) # Should be one
d(aoi_vals)

ecdf_fun <- function(x,perc) ecdf(x)(perc)
ecdf_fun(samp_vals, aoi_vals)
