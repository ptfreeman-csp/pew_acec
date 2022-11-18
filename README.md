## Ecological values of candidate Areas of Critical Environmental Concern
#### Conservation Science Partners
#### Caitlin Littlefield (caitlin@csp-inc.org)

The scripts within this repository generate metrics and figures that express the relative ecological values (e.g., species richness, ecological connectivity, geophysical diversity, extractive industry threats, etc.) of a candidate BLM Area of Critical Environmental Concern under consideration. 

The workflow is as follows, and scripts must be run in this order: 

`00_setup.v2.R` - sets working directory and loads requisite packages and sets several parameters for R environment</br>
`01_dataLoad.v2.R` - load shapefiles for candidate ACEC and relevant geographies and rastesr of ecological indicators</br>
`03_extractVals.v2.R` - extracts ecological indicator values for both the candidate ACEC and random samples across multiple spatial domains</br>
`04_indicatorFigs.v2.R` - generates summary figures</br>
`05_bonusPts.R` - generates summary statistics that are unique to specific candidate ACECs (e.g., contribution to Important Bird Areas)</br>

_N.b. set working directory and input/output folders in 00; script 02 was discontinued and is not included here_



