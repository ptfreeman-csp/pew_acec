library(terra)
setwd("/Volumes/GoogleDrive/.shortcut-targets-by-id/1IzmyhjH2hL-DtYsvhTml0HznlsDMF7p6/Pew_ACEC/data/working")
### Load aquifer vulnerability raster from Linard et al. 2012 (https://water.usgs.gov/GIS/metadata/usgswrd/XML/ofr2014-1158_co_nm_rusle.xml#stdorder)
ero <-rast("/Users/patrickfreeman-csp/Downloads/co_nm_rusle/co_nm_rusle.tif")

### Load existing raster for mammalian diversity as template for reprojection
mamm <- rast("mamm_west_270m.tif")

### Reproject raster to match CRS of mamm and crop/mask to NM
ero_nm <- project(ero, mamm)
ero_nm <- terra::crop(mask(ero_nm,vect(nm)), vect(nm))

### Plot to check
plot(aq_vuln_nm)

### Aggregate 30m raster to 270m raster (factor of 9) and use the mean value 
ero_nm_agg <- terra::aggregate(ero_nm, fact=9, fun="mean")

### Write raster to file 
writeRaster(ero_nm_agg, "NM_rusle_270m.tif")