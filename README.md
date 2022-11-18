## Ecological values of candidate Areas of Critical Environmental Concern
#### Conservation Science Partners
#### Caitlin Littlefield (caitlin@csp-inc.org)

The scripts within this repository generate metrics and figures that express the relative ecological values (e.g., species richness, ecological connectivity, geophysical diversity, extractive industry threats, etc.) of a candidate BLM Area of Critical Environmental Concern under consideration. 

The workflow is as follows, and scripts must be run in this order: 
<ul>
 <li>`00_setup.v2.R` - sets working directory and loads requisite packages and sets several parameters for R environment</li>
 <li>`01_dataLoad.v2.R` - load shapefiles for candidate ACEC and relevant geographies and rastesr of ecological indicators</li>
 <li>`03_extractVals.v2.R` - extracts ecological indicator values for both the candidate ACEC and random samples across multiple spatial domains</li>
 <li>`04_indicatorFigs.v2.R` - generates summary figures</li>
 <li>`05_bonusPts.R` - for specific candidate ACECs, generates summary statistics that are unique to that area (e.g., contribution to Important Bird Areas)</li>
</ul>

_N.b. set working directory and input/output folders in 00_; script 02_ was discontinued and is not included here; 



#### EVERYTHING BELOW HERE NEEDS UPDATING ####



This project consists of two highly interrelated components. In Part 1, we quantified the ecological value of USFS National Forest lands at the administrative unit level by bringing together several key ecological and environmental indicators and integrating them into a composite index of ecological value. This index provides a single coherent estimate of ecological value for each location within all National Forest boundaries, which is then summarized at the administrative unit level. In Part 2, we use the composite index layer generated in Part 1 to identify High Ecological Value Areas (HEVAs) within individual National Forest units. HEVAs are contiguous areas with land in the top 10% of ecological value for a given National Forest. Full methodological details are provided in the Technical Report documents for Part 1 (Administrative Unit analysis) and Part 2 (individual forest analyses)

The workflow for this project involves Google Earth Engine (GEE), the GEE Python API, and R. GEE scripts are provide here as javascript (.js) files and were run in the browser-based GEE code editor (https://code.earthengine.google.com/). Python code with GEE integration (Part 2, Step 2.1) is provided as a Jupyter notebook. Specific functions/operations of all scripts are described below and in the scripts themselves. <br><br>

### Part 1 Workflow - Eco Value at the Administrative Unit Level
#### Step 1.1. Extract random samples for each indicator across all admin units (_GEE_)
_Script:_ `extract-values.js`<br>
As described in the technical report, the composite index was calculated as a weighted linear combination of all indicators, where the weights were optimized to ensure equal influence of each indicator on the composite index value. To conduct the weights optimization, we first extracted indicator values from a very large number (n = 508,212) of random points distributed across all admin units. This script generates those random points, extracts values for each indicator, and then exports the data set to GeoJSON files in google drive. The extraction and export task is divided into two parts to avoid GEE memory issues. GeoJSON files with extracted values then need to be saved in a _data/samples/_ directory to be read into R for step 2.

#### Step 1.2. Prepare random samples and calculate optimized weights (_R_)
_Scripts:_ `prep-samples.R`, `influence-analysis.R`<br>
The first script reads in and prepares the random samples and saves the sample data set (as .csv) in a format suitable for the weights optimization routine. The second script determines the optimal set of weights for all indicators, i.e., the weights that get as close as possible to ensuring that all indicators have equal influence on the composite index values. Sets of optimized weights are saved as a .csv data table. These optimized weights must then be entered into the appropriate dictionary in the GEE script that calculates the composite index (see step 3).

#### Step 1.3. Calculate composite index and generate admin unit-level summaries (_GEE_)
_Script:_ `comp-idx.js`<br>
The optimized weights generated in step 2 are manually entered into a look-up table in this script. The script then calculates the composite index (based on these weights) for all pixels within National Forest boundaries and summarizes (mean and standard deviation) all indicator values and the composite index across each administrative unit. Indicator summaries are calculated based on (1) the data on their original scale/units and (2) standardized (z-score) values for each indicator for comparability across indicators. Admin unit-level summaries are exported as .csv data tables (one each for original scale and standardized data) and a geoJSON file of admin unit polygons is also generated. Files are exported to google drive and then need to be saved in a _data/_ directory to be read into R for step 4.

#### Step 1.4. Prepare formatted Part 1 deliverables (_R_)
_Scripts:_ `summary-table.R`, `results-summary.R`<br>
The `summary-table.R` script takes the output from step 3 and reformats it into finalized data tables (used in the technical report) and shapefiles (provided on DataBasin). Two of each are produce: one for original scale data and one for standardized data. This script also saves an R Data (.rda) file to the _data/_ directory of formatted index and indicator values. This R Data file is used in the `results-summary.R` script to produce the summary boxplots shown as Fig. 2 in the technical report. <br><br>


### Part 2 Workflow - Eco Value for Individual National Forests
#### Step 2.1. Identify High Eco Value Areas (_Python + GEE_)
_Script:_ `top-areas.ipynb` <br>
This notebook loops through each of the 51 focal National Forests and identifies HEVAs (areas in top 10% of ecological value for that forest). Summary statistics for each HEVA within each focal forest are also calculated. GeoJSON files consisting of polygon (vector) data for all HEVAs and tiff files consisting of composite index rasters for each focal forest are exported to Google Cloud Storage for downstream processing. Thes datasets need to be downloaded and stored in the _data/_ directory. **NOTE** Cloud storage export paths currently point to private CSP cloud buckets and will need to be updated. Alternatively, use ee.batch.Export.[table/image].toDrive to export GeoJSON and tiff files to Google Drive.

#### Step 2.2. Prepare maps and tables for individual National Forests (_R_)
_Script:_ `carto-tables.R` <br>
This script ingests the GeoJSON and tiff files created in Step 2.1 and produces all maps and summary tables used in individual forest reports. The script also draws on roads and forest boundary shapefiles provided in the _data/_ directory. Maps and tables are exported to _output/maps/_ and _output/tables_ directories, respectively.


### Helper scripts
In addition to the scripts involved directly in the workflow (described above), there are several helper scripts in both GEE and R that provide custom functions and/or routing to relevant data sets.<br><br>
__GEE helper scripts__<br>
-`data.js` - Provides quick access to indicator layers and other data sets stored as GEE assets <br>
-`utils.js` - Custom functions used in calculating the composite index <br><br>

__R helper scripts__<br>
-`influence-utils.R` - Several functions to run the optimization routine used to determine optimal weights for each indicator variable in calculating the composite index <br>
-`parser-utils.R` - Parser function for getting lat lon values from GeoJSON files <br>
-`math-stats.R` - Functions for quickly fitting several common mathematical functions/transformations <br>

### Helper files
-`state-abbreviations.csv` - List of state names and two-letter abbreviations used in prepping data tables in `summary-table.R` script <br>
-`forest-names.csv` - List of names of the 51 focal National Forests for which individual-level analyses were conducted. Used in `top-areas.ipynb` and `carto-tables.R` <br>

### Data and Code Locations
Bucket: [gs://pew-usfs](https://storage.cloud.google.com/pew-usfs)

GEE Assets: [projects/GEE_CSP/pew-usfs](https://code.earthengine.google.com/?asset=projects/GEE_CSP/pew-usfs)

GEE Code: projects/GEE_CSP/default/pew-usfs

