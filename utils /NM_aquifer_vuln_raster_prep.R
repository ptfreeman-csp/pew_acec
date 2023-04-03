library(terra)
setwe("/Volumes/GoogleDrive/.shortcut-targets-by-id/1IzmyhjH2hL-DtYsvhTml0HznlsDMF7p6/Pew_ACEC/data/working")
### Load aquifer vulnerability raster from Linard et al. 2012 (https://water.usgs.gov/GIS/metadata/usgswrd/XML/ofr2014-1158_co_nm_drastic.xml#Identification_Information)
aq_vuln <-rast("/Users/patrickfreeman-csp/Downloads/CO_NM_DRASTIC/CO_NM_DRASTIC.tif")

### Load existing raster for mammalian diversity as template for reprojection
mamm <- rast("mamm_west_270m.tif")

### Reproject raster to match CRS of mamm and crop/mask to NM
aq_vuln_nm <- project(aq_vuln, mamm)
aq_vuln_nm <- terra::crop(mask(aq_vuln,vect(nm)), vect(nm))

### Plot to check
plot(aq_vuln_nm)

### Aggregate 30m raster to 270m raster (factor of 9) and use the mean value 
aq_vuln_nm_agg <- terra::aggregate(aq_vuln_nm, fact=9, fun="mean")

### Write raster to file 
writeRaster(aq_vuln_nm_agg, "NM_DRASTIC_270m.tif")