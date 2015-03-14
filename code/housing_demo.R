

# Load necessary libraries
library(datadr)
library(trelliscope)
library(housingData)

# Set the working directory. You will need to provide the complete file path.
setwd("housing_demo")

# Remove any left-over objects in the Global environment
rm(list = ls())



# To see the Trelliscope output, execute this block of code. We will 
# go into further details below about how to set up your own Trelliscope
# visual data base. 
vdbConn("vdb_housing", autoYes = TRUE)

# use this when running locally on your own computer
myport <- 8100 

# myport <- Sys.getenv("TR_PORT") # use this on demo cluster

view(port = myport)




# If you have not already done so, import the necessary packages
library(datadr)
library(trelliscope)
library(housingData)

# Take a peek at the first 6 rows of housing
head(housing)




# Let's get a sense of the dimensions of our data frame
dim(housing)



# We will create a distributed data frame by dividing our data by county and state
byCounty <- divide(housing, by = c("county", "state"), update = TRUE)



# byCounty is a Divided Data Frame one of the primary data types in datadr
class(byCounty)



# Look at byCounty object
byCounty

# Look at first division. It will consist of a key-value pair.
# The key should look something like county=X|state=Y and the value
# should be the data frame corresponding to that key.
byCounty[[1]]



# Look at summary statistics for each key-value pair. 
summary(byCounty)

# Basic data object information

length(byCounty) ## number of data divisions

names(byCounty) ## column names

getKeys(byCounty) ## data division keys (state & county names in this example)





splitRowDistn(byCounty) ## percentiles of number of rows per division

splitSizeDistn(byCounty) ## percentiles of number of bytes per division



# A data division can be accessed by by its named key or by number
byCounty[["county=Benton County|state=WA"]]
# byCounty[[176]] # If you wish to access the data frame by index 



# Look at quantiles of median list price/sqft 
priceQ <- drQuantile(byCounty, var = "medListPriceSqft")
xyplot(q~fval, data=priceQ, main="Median List Price/Sqft Quantiles")



# Calculate linear model for each data division to see the trend in prices

# Create a function to calculate a linear model and extract the slope parameter
lmCoef <- function(x) {
   data.frame(getSplitVars(x), slope=coef(lm(medListPriceSqft ~ time, data = x))[2])
}

# Test lmCoef on one division
kvApply(lmCoef, byCounty[[176]])

# Add the function transform to the DDF
byCountySlope <- addTransform(byCounty, lmCoef)

# Now look at data with the transformation
byCountySlope[[176]]

# Recombine the slope data into a single data.frame
countySlopes <- recombine(byCountySlope, combRbind)

# Look at the recombined data
head(countySlopes)




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





# Define a visualization database directory where the plots and metadata
# will be saved. Unless a complete file path is specified, the vdb will be
# generated in the working directory. 
vdbConn("vdb_housing", autoYes=TRUE)

# Define a plot function
timePanel <- function(x) {
   xyplot(medListPriceSqft + medSoldPriceSqft ~ time,
      data = x$housing, auto.key = TRUE, ylab = "Price / Sq. Ft.")
}

# Test the plot function on a single division
kvApply(timePanel, joinedData[[176]])




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
kvApply(priceCog, joinedData[[176]])




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
myport <- 8100 # use this when running locally
# myport <- Sys.getenv("TR_PORT") # use this on demo cluster
view(port=myport)

