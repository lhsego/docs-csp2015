## Housing Sales ##

### Data Description - Housing ###

The housing dataset contains data about housing sales aggregated to the 
county level in the United States between 2008-10-01 and 2014-03-01. This  
is Zillow.com data provided by [Quandl](https://www.quandl.com/c/housing). 
The data variables are as follows:

Variable | Description
---------|-----------------
fips | Federal Information Processing Standard, a 5 digit count code
county | US county name
state | US state name
time | date (the data is aggregated monthly)
nSold | number sold this month
medListPriceSqft | median list price per square foot
medSoldPriceSqft | median sold price per square foot

### Trelliscope View - Housing ###

The `datadr`, `trelliscope`, and `housingData` packages need to be imported for the following demo. Make sure to set the working directory to the location of the housing demo visual data base (vdb) directory. This will allow you to connect to the data base and interact with the trelliscope output. 


```r
# Load necessary libraries.
library(datadr)
library(trelliscope)
library(housingData)

# Set the working directory. You will need to provide the complete file path.
setwd("housing_demo")

# Remove any left-over objects in the Global environment
rm(list = ls())
```

The following will launch two pre-made trelliscope displays:
- median list/sold price per sq ft vs time
- median list/sold price per sq ft vs time by state

Each panel represents the median listed (blue) and sold (pink) housing value plotted over time. Note that some of the panels only have one of the two values. The purpose of looking at pre-made displays is to get the user acquainted with the trelliscope interface. We encourage you to explore the data and search for trends and anomalies. 


```r
# To see the Trelliscope output, execute this block of code. We will 
# go into further details below about how to set up your own Trelliscope
# visual data base. 
vdbConn("vdb_housing", autoYes = TRUE)

# use this when running locally on your own computer
myport <- 8100 

# myport <- Sys.getenv("TR_PORT") # use this on demo cluster

view(port = myport)
```

### Challenge Questions - Housing ###

Now that you have the trelliscope display open, we have a few challenge questions that we would like to see if you can answer. No one's grading you on this task. In order to familiarize yourself with the interface and get a sense of the power of the trelliscope package, see if you can answer the following set of questions:

1. Can you find the county with the largest positive slope in list price per square foot? Can you find the county with the largest negative slope? (Hint: use the Table Sort/Filter or Univariate Filter.)

2. Can you find the state that has the largest range of county trends in list price? (Hint: use the Bivariate Filter.)

3. Can you find the county with the largest increasing price trend in the South? (Hint: use the Table Sort/Filter to filter first.) 

### Code to Create Trelliscope View - Housing ###

This activity will teach you how to create your own trelliscope displays as well as some basic functionality of the datadr package using the housing data set. We will be using the same data from the pre-made displays, but now you will be writing the code to generate the output. We will begin by importing the necessary packages and create our first distributed data frame using the `divide()` function from datadr.  


```r
# If you have not already done so, import the necessary packages
library(datadr)
library(trelliscope)
library(housingData)

# Take a peek at the first 6 rows of housing
head(housing)
```

```
   fips         county state       time nSold medListPriceSqft
1 06001 Alameda County    CA 2008-10-01    NA         307.9787
2 06001 Alameda County    CA 2008-11-01    NA         299.1667
3 06001 Alameda County    CA 2008-11-01    NA               NA
4 06001 Alameda County    CA 2008-12-01    NA         289.8815
5 06001 Alameda County    CA 2009-01-01    NA         288.5000
6 06001 Alameda County    CA 2009-02-01    NA         287.0370
  medSoldPriceSqft
1         325.8118
2               NA
3         318.1150
4         305.7878
5         291.5977
6               NA
```


```r
# Let's get a sense of the dimensions of our data frame
dim(housing)
```

We are going to divide the data set by the variables "county" and "state". This kind of data division is very similar to the functionality provided by the `plyr` package. 


```r
# We will create a distributed data frame by dividing our data by county and state
byCounty <- divide(housing, by = c("county", "state"), update = TRUE)
```


```r
# byCounty is a Divided Data Frame one of the primary data types in datadr
class(byCounty)
```

Calling the distributed data frame (`ddf()`) that was just created lets the user know the size of the object in terms of memory and other metadata specific to the object. In this ddf, each element is itself a data frame. 


```r
# Look at byCounty object
byCounty
```

```

Distributed data frame backed by 'kvMemory' connection

 attribute      | value
----------------+-----------------------------------------------------------
 names          | fips(cha), time(Dat), nSold(num), and 2 more
 nrow           | 224369
 size (stored)  | 16.45 MB
 size (object)  | 16.45 MB
 # subsets      | 2883

* Other attributes: getKeys(), splitSizeDistn(), splitRowDistn(), summary()
* Conditioning variables: county, state
```

```r
# Look at first division. It will consist of a key-value pair.
# The key should look something like county=X|state=Y and the value
# should be the data frame corresponding to that key.
byCounty[[1]]
```

```
$key
[1] "county=Abbeville County|state=SC"

$value
   fips       time nSold medListPriceSqft medSoldPriceSqft
1 45001 2008-10-01    NA         73.06226               NA
2 45001 2008-11-01    NA         70.71429               NA
3 45001 2008-12-01    NA         70.71429               NA
4 45001 2009-01-01    NA         73.43750               NA
5 45001 2009-02-01    NA         78.69565               NA
...
```

A common procedure for EDA involves gathering a wide variety of summary statistics. The datadr package has some predefined functions for performing these calculations on distributed data frames / objects. 


```r
# Look at summary statistics for each key-value pair. 
summary(byCounty)

# Basic data object information

length(byCounty) ## number of data divisions

names(byCounty) ## column names

getKeys(byCounty) ## data division keys (state & county names in this example)
```

We can get a sense of the number of rows in each element of the ddf as well as the amount of memory taken up by each element using `splitRowDistn()` and `splitSizeDistn()`.


```r
splitRowDistn(byCounty) ## percentiles of number of rows per division

splitSizeDistn(byCounty) ## percentiles of number of bytes per division
```

You can access the elements of the distributed data frame (ddf) using the key or by index, just like you would with a traditional list.  


```r
# A data division can be accessed by by its named key or by number
byCounty[["county=Benton County|state=WA"]]
```

```
$key
[1] "county=Benton County|state=WA"

$value
   fips       time nSold medListPriceSqft medSoldPriceSqft
1 53005 2008-10-01   137         106.6351         106.2179
2 53005 2008-11-01    80         106.9650               NA
3 53005 2008-11-01    NA               NA         105.2370
4 53005 2008-12-01    95         107.6642         105.6311
5 53005 2009-01-01    73         107.6868         105.8892
...
```


```r
byCounty[[176]] # If you wish to access the data frame by index 
```

Finally, you can use the `drQuantile()` function to compute the sample quantiles for the elements in the ddf object.


```r
# Look at quantiles of median list price/sqft 
priceQ <- drQuantile(byCounty, var = "medListPriceSqft")
xyplot(q~fval, data=priceQ, main="Median List Price/Sqft Quantiles")
```

![plot of chunk unnamed-chunk-12](figures/knitr/unnamed-chunk-12-1.png) 

#### Divide and Recombine ####

Suppose we are interested in figuring out the trend component of each time series in our distributed data frame. We can do this by creating a linear model for each subdivision and extracting the slope parameter. We wish to incorporate this information into our pre-existing ddf and use it in our analysis. 


```r
# Calculate linear model for each data division to see the trend in prices

# Create a function to calculate a linear model and extract the slope parameter
lmCoef <- function(x) {
   data.frame(getSplitVars(x), slope=coef(lm(medListPriceSqft ~ time, data = x))[2])
}

# Test lmCoef on one division
kvApply(lmCoef, byCounty[[176]])
```

```
Error in kvApply(lmCoef, byCounty[[176]]): could not find function "fn"
```

```r
# Add the function transform to the DDF
byCountySlope <- addTransform(byCounty, lmCoef)

# Now look at data with the transformation
byCountySlope[[176]]

# Recombine the slope data into a single data.frame
countySlopes <- recombine(byCountySlope, combRbind)

# Look at the recombined data
head(countySlopes)
```

Sometimes you will want to actively combine two distributed data objects/frames together to create a new data set. We will demonstrate how to perform these types of operations using the `drJoin()` function.


```r
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
```

The data is now ready to be ingested into trelliscope. To use trelliscope, the user needs to define a visual data base and create basic functions for plotting. On top of this, a user can develop and use cognostics to improve data interpretability. A cognostic is usually, but not always, a summary statistic or some form of metadata to be included along with plots. These values can be useful in determining patterns or anomalies in visual displays. 


```r
# Define a visualization database directory where the plots and metadata
# will be saved. Unless a complete file path is specified, the vdb will be
# generated in the working directory. 
vdbConn("vdb_housing", autoYes=TRUE)
```


```r
# Define a plot function
timePanel <- function(x) {
   xyplot(medListPriceSqft + medSoldPriceSqft ~ time,
      data = x$housing, auto.key = TRUE, ylab = "Price / Sq. Ft.")
}

# Test the plot function on a single division
kvApply(timePanel, joinedData[[176]])
```

```
Error in kvApply(timePanel, joinedData[[176]]): could not find function "fn"
```

We have defined a simple plot function. It would be useful to define a set of cognostics that can give us a large set of angles with which to attack the data anlysis problem at hand. Some simple cognostics are included in the trelliscope package such as `cogMean()` and `cogRange()` which are self-explanatory. You are free to define any other measure of the data using the `cog()` function.  


```r
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
```

```
Error in kvApply(priceCog, joinedData[[176]]): could not find function "fn"
```


```r
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
```
