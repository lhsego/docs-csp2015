###############################################################################
#### Housing Example
#### Using DataDR and Trelliscope to analyze housing
#### sales data
###############################################################################

# The housing dataset contains data about housing sales data aggregated to the 
# county level in the United States between 2008-10-01 and 2014-03-01. This  
# is Zillow.com data provided by Quandl (https://www.quandl.com/c/housing). 
# The data variables are as follows:
#
# fips - Federal Information Processing Standard, a 5 digit count code
# county - US county name
# state - US state name
# time - date (the data is aggregated monthly)
# nSold - number sold this month
# medListPriceSqft - median list price per square foot
# medSoldPriceSqft - median sold price per square foot


# Load necessary libraries
library(datadr)
library(trelliscope)
library(housingData)

################################################################################
#### Let's set the working directory for this example. You may have to change the
#### path in the command below to correctly point to the 'housing_demo' directory
setwd("~/demos/housing_demo")

# Remove any left-over objects in the Global environment
rm(list = ls())

###############################################################################
#### To see the Trelliscope display execute this section. To see how the
#### display was made see the code below.

vdbConn("vdb_housing", autoYes = TRUE)
# myport <- 8100 # use this when running locally on your own computer
myport <- Sys.getenv("TR_PORT") # use this on demo cluster
view(port = myport)

###############################################################################
#### Analyze housing dataset and create Trelliscope displays

# Look at the housing dataset: this is Zillow.com data provided by 
# Quandl (https://www.quandl.com/c/housing)

head(housing)

dim(housing)

# Divide records by county and state
byCounty <- divide(housing, 
   by = c("county", "state"), update = TRUE)

# byCounty is a Divided Data Frame one of the primary data types in datadr
class(byCounty)

# Look at byCounty object
byCounty

# Look at first division
byCounty[[1]]

# Look at summary statistics 
summary(byCounty)

# Basic data object information

length(byCounty) ## number of data divisions

names(byCounty) ## column names

getKeys(byCounty) ## data division keys (state & county names in this example)

splitRowDistn(byCounty) ## percentiles of number of rows per division

splitSizeDistn(byCounty) ## percentiles of number of bytes per division

# A data division can be accessed by by its named key or by number
byCounty[["county=Benton County|state=WA"]]
byCounty[[176]]

# Look at quantiles of median list price/sqft 
priceQ <- drQuantile(byCounty, var = "medListPriceSqft")
xyplot(q~fval, data=priceQ, main="Median List Price/Sqft Quantiles")


##### Analytic recombination
# Calculate linear model for each data division to see the trend in prices

# Create a function to calculate a linear model and extract the slope parameter
lmCoef <- function(x) {
   data.frame(getSplitVars(x), slope=coef(lm(medListPriceSqft ~ time, data = x))[2])
}

# Test lmCoef on one division
lmCoef(byCounty[[176]]$value)

# Add the function transform to the DDF
byCountySlope <- addTransform(byCounty, lmCoef)

# Now look at data with the transformation
byCountySlope[[176]]

# Recombine the slope data into a single data.frame
countySlopes <- recombine(byCountySlope, combRbind)

# Look at the recombined data
head(countySlopes)

#### Joining multiple data sets based on keys

# Look at geoCounty which contains more information about US counties
head(geoCounty)

# Divide geoCounty on county and state just like we did with the housing data
geo <- divide(geoCounty, by = c("county", "state"))
geo[[1]]

# Get some wikipedia data on counties and divide by county/state
wikiByCounty <- divide(wikiCounty, by = c("county", "state"))

# Join divided housing, geo and wiki data together
# This forms a Distributed Data Object (DDO)
joinedData <- drJoin(housing = byCounty, slope=byCountySlope, geo = geo, wiki=wikiByCounty)

# Note that this is no longer a distributed data frame
class(joinedData)

joinedData[[176]]

length(joinedData)

# Filter dataset to remove divisions without housing sales data
joinedData <- drFilter(joinedData, function(x) {
   !is.null(x$housing)
})

# See that the length has decreased - some data divisions have been removed
length(joinedData)

#### Trelliscope: an interactive divide and recombine visualization tool

# Define a visualization database directory where the plots and metadata
# will be saved
vdbConn("vdb_housing", autoYes=TRUE)

# Define a plot function
timePanel <- function(x) {
   xyplot(medListPriceSqft + medSoldPriceSqft ~ time,
      data = x$housing, auto.key = TRUE, ylab = "Price / Sq. Ft.")
}

# Test the plot function on a single division
timePanel(joinedData[[176]]$value)

# Define a cognostics function: this is used to define information and 
# statistics that will be available in the Trelliscope UI for sorting and 
# filtering and also to display/link useful meta information.
priceCog <- function(a) { 
   x <- a$housing
   st <- getSplitVar(a, "state")
   ct <- getSplitVar(a, "county")
   zillowString <- paste(ct, st)
   zillowString <- gsub(" ", "-", zillowString)
   list(
      fips = cog(x$fips[1], desc = "fips code"),
      region = cog(state.region[state.abb == ifelse(st == "DC", "MD", st)]),
      division = cog(state.division[state.abb == ifelse(st == "DC", "MD", st)]),
      slope = cog(a$slope$slope, desc = "list price slope"),
      meanList = cogMean(x$medListPriceSqft),
      meanSold = cogMean(x$medSoldPriceSqft),
      listRange = cogRange(x$medListPriceSqft),
      soldRange = cogRange(x$medSoldPriceSqft),
      nObs = cog(length(which(!is.na(x$medListPriceSqft))), 
         desc = "number of non-NA list prices"),
      lat = cog(a$geo$lat, desc = "county latitude"),
      lon = cog(a$geo$lon, desc = "county longitude"),
      pop2013 = cog(log10(a$wiki$pop2013), desc = "log base 10 population in 2013"),
      wikiHref = cogHref(a$wiki$href, "wiki link"),
      zillowHref = cogHref(sprintf("http://www.zillow.com/homes/%s_rb/", zillowString), "zillow link")
   )
}

# Test on a single division
priceCog(joinedData[[176]]$value)

# Create the display: this creates and saves display files and information in
# the vdb directory defined above
makeDisplay(joinedData,
   name = "list_sold_vs_time_datadr_tut",
   desc = "List and sold price over time",
   panelFn = timePanel, 
   cogFn = priceCog,
   width = 400, height = 400,
   lims = list(x = "same"))

# Open Trelliscope in a browser
# myport <- 8100 # use this when running locally
myport <- Sys.getenv("TR_PORT") # use this on demo cluster
view(port=myport)

# A second Trelliscope display based on maps

# Filter out keys where either slope or geo data is missing
geoSlopeData <- drFilter(joinedData, function(x) {
   !is.null(x$slope) && !is.null(x$geo)
})

# Combine slope and geo for each remaining division into a data.frame
# (this eliminates the housing and wiki data)
geoSlopeData <- addTransform(geoSlopeData, function(x) {
   data.frame(x$slope, x$geo)
})
geoSlopeData[[1]]

# Persist the transformation 
geoSlopeData <- drPersist(geoSlopeData)

# Create a dataset of county slope and geo data divided by state
slopesByState <- divide(geoSlopeData, by="state", update=TRUE)
slopesByState[["state=WA"]]

# Calculate slope percentiles for coloring the graphs
slopeQuantiles <- drQuantile(slopesByState, "slope")
slopePercentiles <- approx(slopeQuantiles$fval, slopeQuantiles$q, seq(0,1,by=0.01))$y

library(maps)

# Match region definition from maps library to our state/county pairs
matchMapRegionToCounty <- function(mapRegionNames, countyNames) {
   ind <- match(mapRegionNames, countyNames)
   ind.na <- which(is.na(ind))

   for (i in ind.na) {
      ind[i] <- match(strsplit(mapRegionNames[i], ":")[[1]][1], countyNames)
   }
   ind
}

# Create a state map of each county colored by price change
stateMapPanelFn <- function(x) {
   map.data <- map("county", x$rMapState[1], fill=TRUE, plot=FALSE)

   ind <- matchMapRegionToCounty(map.data$names, paste(x$rMapState, x$rMapCounty, sep=","))
   plot.colors <- rep("grey", times=length(map.data$names))
   plot.colors <- level.colors(x$slope,
      slopePercentiles, rainbow(n=100, start=0, end=2/6))[ind]
   plot.colors[is.na(plot.colors)] <- "grey"

   map(map.data, fill=TRUE, col=plot.colors)
   mtext(toupper(x$rMapState[1]))
   return(NULL)
}

# Test on one data division
stateMapPanelFn(slopesByState[["state=WA"]]$value)

# Cognostics function that includes slope statistics, lat and lon ranges
# and a link to the corresponding county plots for the selected state
mapCog <- function(x) {
   st <- getSplitVar(x, "state")
   
   trellState <- list(
      sort = list(county = "asc"),
      filter = list(
         state = list(select = st)
      ),
      layout = list(nrow = 2, ncol = 3),
      labels = c("county", "state")
   )
   validateState(trellState)
   
   list(
      countyPlots=cogDisplayHref("list_sold_vs_time_datadr_tut", 
         displayGroup="common", state=trellState, 
         label=paste("View county prices for", st), defLabel=TRUE),
      region = cog(state.region[state.abb == ifelse(st == "DC", "MD", st)]),
      division = cog(state.division[state.abb == ifelse(st == "DC", "MD", st)]),
      medianSlope = cog(median(x$slope, na.rm=TRUE), desc = "median list price slope"),
      slopeMin = cog(min(x$slope, na.rm=TRUE)),
      slopeMax = cog(max(x$slope, na.rm=TRUE)),
      latMin = cog(min(x$lat, na.rm=TRUE)),
      latMax = cog(max(x$lat, na.rm=TRUE)),
      lonMin = cog(min(x$lon, na.rm=TRUE)),
      lonMax = cog(max(x$lon, na.rm=TRUE))
   )   
}

# Test cognostics function on one division
mapCog(slopesByState[["state=WA"]]$value)

# Make the new display
makeDisplay(slopesByState,
   name = "county_price_changes_for_each_state",
   desc = "County level trends in prices for each state",
   panelFn = stateMapPanelFn, 
   cogFn = mapCog,
   width = 400, height = 400)

# Open trelliscope
view(port=myport)
