## Power Utilization in Retail Buildings ##

### Data Description - Power ###

This dataset contains recordings of the energy consumption and outdoor air temperature of four retail 
buildings at various locations in the U.S. at 15 minute intervals during 2010. The measurements have
been anonymized by applying a random linear transformation.
The variables in the data are described below:

Variable | Description
---------|-----------------
building | An integer identifying each of the four buildings
dateTime | The date and time when the power and temperature were recorded
year | Integer indicating the year of the measurement
date | The date of the measurement
quarter | The quarter of the year (Q1, Q2, Q3, Q4)
month | The month, represented as an integer (1, 2, ..., 12)
monthName | The name of the month ("January", "Februrary", ..., "December")
week |  Integer indicating the week in 2010 (1, 2, 3, ..., 52)
weekDay | The day of the week ("Monday", "Tuesday", ..., "Sunday")
day | Integer indicating the Julian day in 2010 (number of days since Jan 1, 2010)
OAT.F | Outdoor Air Temperature measured in Farenheit
Power.KW | Instantaneous power consumption by the building at the date time, measured in Kilowatts

### Trelliscope View - Power###

The purpose of this activity is to launch the `trelliscope` display and then explore the power
consumption data: to look for patterns, bad data, anomalies, etc. 
In this section, we'll show you the code required to launch a pre-created `trelliscope` view of the
data.

Let's begin by setting the working directory for this example. You will have to change the path 
in the command below to correctly point to the `power_demo` directory.


```r
# Set the working directory. Edit "~/correct_path" as necessary
setwd("~/correct_path/power_demo")
```

And load the `trelliscope` and `plyr` packages:


```r
# Load packages
library(trelliscope)
library(plyr)
```

The following will launch two pre-made trelliscope displays:
- Power vs. Time for each day in 2010
- Power vs. Outdoor Air Temp for each day in 2010

where each panel shows data for all four buildings for a single day.  Use
`Cntrl-C` or `ESC` to stop the viewer and return to the R prompt.


```r
# Open the connection to the pre-existing trelliscope visualization. "vdb_power" is a folder
# in the "power_demo" folder, where we set the working directory earlier.
vdbConn("vdb_power")

# use this port when running locally on your own computer
myport <- 8100 

# Launch the trelliscope viewer.  Use Ctrl-C or ESC to stop the reviewer and return
# the R prompt
view(port = myport)
```

### Challenge Questions - Power ###

Do your best to answer the following questions. We have placed them here to help 
you learn how to use `trelliscope`. Be sure to launch the `trelliscope` display 
(if it's not already open) using the code above.

1. Without manually scrolling through all the panels, can you identify the days when the 
power consumption pattern is noticeably different than normal consumption patterns?

2. Given the data, can you conclude that there are faulty sensors on or in the buildings?

3. Is there a seasonal trend in power consumption?

4. Given that each building is in a unique location, can you conclude that outdoor air temperature 
is correlated with power usage? 

### Code to Create Trelliscope View - Power ###

This activity will teach you how to create your own `trelliscope` displays. We will be using the same 
data as presented in the pre-made display, but you will have the opportunity to interact with the 
underlying code. This tutorial will demonstrate how to generate your own plots and how to create 
and use cognostics to filter and sort the plots.

There are several key steps to creating a Trelliscope view that we will discuss below:
- Load the `trelliscope` package and other requisite packages
- Get an initial feel for the data using tabular summaries
- Divide the data using `divide()` from the `datadr` package
- Define the **panel** and **cognostics** functions
- Establish a connection to a visualization data base (vdb) using `vdbConn()` from the 
  `trelliscope` package
- Write `trelliscope` view files to the vdb using `makeDisplay()`
- Launch the `trelliscope` viewer using `view()`

#### Preliminaries ####

Let's begin by removing any (and all) left-over objects in the Global environment of the R session:


```r
# Clear the R workspace
rm(list = ls())
```

Now we'll load the necessary libraries and read in the power data. 


```r
# Load the trelliscope package if you haven't already
library(trelliscope)
library(datadr)

# You will need to adjust replace the first part of path with the location where you
# unzipped the demonstration files
setwd("~/correct_path/power_demo")

# We'll begin by reading in the data. 
d <- read.csv("retailBuildings.csv")
```

#### Data Summaries ####

It's standard practice, when analyzing a new set of data, to get a sense of the underlying 
structure. The R programming language has several convenient functions for doing this and `str()` 
is one of the best for getting a sense of the size and contents of a data frame:


```r
# Print the first 6 rows of the dataset
head(d)
```

```
  building            dateTime year       date quarter month monthName
1        2 2010-01-01 01:15:00 2010 2010-01-01      Q1     1   January
2        2 2010-01-01 01:30:00 2010 2010-01-01      Q1     1   January
3        2 2010-01-01 01:45:00 2010 2010-01-01      Q1     1   January
4        2 2010-01-01 02:00:00 2010 2010-01-01      Q1     1   January
5        2 2010-01-01 02:15:00 2010 2010-01-01      Q1     1   January
6        2 2010-01-01 02:30:00 2010 2010-01-01      Q1     1   January
  week weekday day    OAT.F Power.KW
1    1  Friday   1 43.79894 126.7764
2    1  Friday   1 43.79894 127.3692
3    1  Friday   1 43.79894 124.4899
4    1  Friday   1 43.79894 124.5745
5    1  Friday   1 43.09446 123.3042
6    1  Friday   1 43.09446 122.4574
```

```r
# Now let's look at the structure of the data.
# Notice how there are 139740 rows and 12 columns, and that
# dateTime and date are stored as factors
str(d)
```

```
'data.frame':	139740 obs. of  12 variables:
 $ building : int  2 2 2 2 2 2 2 2 2 2 ...
 $ dateTime : Factor w/ 34935 levels "2010-01-01 01:15:00",..: 1 2 3 4 5 6 7 8 9 10 ...
 $ year     : int  2010 2010 2010 2010 2010 2010 2010 2010 2010 2010 ...
 $ date     : Factor w/ 364 levels "2010-01-01","2010-01-02",..: 1 1 1 1 1 1 1 1 1 1 ...
 $ quarter  : Factor w/ 4 levels "Q1","Q2","Q3",..: 1 1 1 1 1 1 1 1 1 1 ...
 $ month    : int  1 1 1 1 1 1 1 1 1 1 ...
 $ monthName: Factor w/ 12 levels "April","August",..: 5 5 5 5 5 5 5 5 5 5 ...
 $ week     : int  1 1 1 1 1 1 1 1 1 1 ...
 $ weekday  : Factor w/ 7 levels "Friday","Monday",..: 1 1 1 1 1 1 1 1 1 1 ...
 $ day      : int  1 1 1 1 1 1 1 1 1 1 ...
 $ OAT.F    : num  43.8 43.8 43.8 43.8 43.1 ...
 $ Power.KW : num  127 127 124 125 123 ...
```

It is often necessary to convert dates and date times from text to a format that R can 
recognize as a date:


```r
# Convert the 'dateTime' and 'date' to a POSIXct format so R can compute with
# them as dates
d$dateTime <- as.POSIXct(d$dateTime)
d$date <- as.POSIXct(d$date)

# Notice how "dateTime" and "date" are POSIX variables now
str(d)
```

```
'data.frame':	139740 obs. of  12 variables:
 $ building : int  2 2 2 2 2 2 2 2 2 2 ...
 $ dateTime : POSIXct, format: "2010-01-01 01:15:00" "2010-01-01 01:30:00" ...
 $ year     : int  2010 2010 2010 2010 2010 2010 2010 2010 2010 2010 ...
 $ date     : POSIXct, format: "2010-01-01" "2010-01-01" ...
 $ quarter  : Factor w/ 4 levels "Q1","Q2","Q3",..: 1 1 1 1 1 1 1 1 1 1 ...
 $ month    : int  1 1 1 1 1 1 1 1 1 1 ...
 $ monthName: Factor w/ 12 levels "April","August",..: 5 5 5 5 5 5 5 5 5 5 ...
 $ week     : int  1 1 1 1 1 1 1 1 1 1 ...
 $ weekday  : Factor w/ 7 levels "Friday","Monday",..: 1 1 1 1 1 1 1 1 1 1 ...
 $ day      : int  1 1 1 1 1 1 1 1 1 1 ...
 $ OAT.F    : num  43.8 43.8 43.8 43.8 43.1 ...
 $ Power.KW : num  127 127 124 125 123 ...
```

It would be useful to get an idea of the number of entries of each variable in our data set as 
well as a summary of each variable. We can use the `summary()` and `table()` functions to 
creates these summaries:

```r
summary(d)
```

```
    building       dateTime                        year     
 Min.   :2.00   Min.   :2010-01-01 01:15:00   Min.   :2010  
 1st Qu.:2.75   1st Qu.:2010-04-02 01:30:00   1st Qu.:2010  
 Median :3.50   Median :2010-07-02 01:00:00   Median :2010  
 Mean   :3.50   Mean   :2010-07-02 01:08:53   Mean   :2010  
 3rd Qu.:4.25   3rd Qu.:2010-10-01 00:30:00   3rd Qu.:2010  
 Max.   :5.00   Max.   :2010-12-30 23:45:00   Max.   :2010  
                                                            
      date                     quarter        month          monthName    
 Min.   :2010-01-01 00:00:00   Q1:34524   Min.   : 1.000   August :11904  
 1st Qu.:2010-04-02 00:00:00   Q2:34944   1st Qu.: 4.000   July   :11904  
 Median :2010-07-02 00:00:00   Q3:35328   Median : 7.000   May    :11904  
 Mean   :2010-07-01 13:16:13   Q4:34944   Mean   : 6.512   October:11904  
 3rd Qu.:2010-10-01 00:00:00              3rd Qu.:10.000   March  :11888  
 Max.   :2010-12-30 00:00:00              Max.   :12.000   January:11884  
                                                           (Other):68352  
      week            weekday           day            OAT.F       
 Min.   : 1.00   Friday   :19948   Min.   :  1.0   Min.   : 4.351  
 1st Qu.:14.00   Monday   :19968   1st Qu.: 91.0   1st Qu.:44.543  
 Median :27.00   Saturday :19968   Median :182.0   Median :53.089  
 Mean   :26.55   Sunday   :19952   Mean   :181.9   Mean   :55.245  
 3rd Qu.:40.00   Thursday :19968   3rd Qu.:273.0   3rd Qu.:69.160  
 Max.   :53.00   Tuesday  :19968   Max.   :364.0   Max.   :92.901  
                 Wednesday:19968                                   
    Power.KW    
 Min.   :  0.0  
 1st Qu.:192.0  
 Median :254.8  
 Mean   :257.9  
 3rd Qu.:317.4  
 Max.   :543.3  
                
```
It would be nice to see a tabulation of the categorial variables in the data.  We could do that 
one variable at a time, like this:

```r
# Table for building
table(d$building)
```

```

    2     3     4     5 
34935 34935 34935 34935 
```

```r
# Table for year
table(d$year)
```

```

  2010 
139740 
```
Or we could tabulate all of them at once, like this:

```r
# A character vector of all the categorical variables
sel <- c("building", "year", "quarter", "month", "monthName", "week", "weekday")

# Now we use that vector to select only those columns of 'd', and we can apply
# the table() function to each column, where column-wise summaries are indicated by
# MARGIN = 2.
apply(d[,sel], MARGIN = 2, table)
```

```
$building

    2     3     4     5 
34935 34935 34935 34935 

$year

  2010 
139740 

$quarter

   Q1    Q2    Q3    Q4 
34524 34944 35328 34944 

$month

    1     2     3     4     5     6     7     8     9    10    11    12 
11884 10752 11888 11520 11904 11520 11904 11904 11520 11904 11520 11520 

$monthName

    April    August  December  February   January      July      June 
    11520     11904     11520     10752     11884     11904     11520 
    March       May  November   October September 
    11888     11904     11520     11904     11520 

$week

   1    2    3    4    5    6    7    8    9   10   11   12   13   14   15 
2284 2688 2688 2688 2688 2688 2688 2688 2688 2688 3056 2688 2688 2688 2688 
  16   17   18   19   20   21   22   23   24   25   26   27   28   29   30 
2688 2688 2688 2688 2688 2688 2688 2688 2688 2688 2688 2688 2688 2688 2688 
  31   32   33   34   35   36   37   38   39   40   41   42   43   44   45 
2688 2688 2688 2688 2688 2688 2688 2688 2688 2688 2688 2688 2688 2688 2304 
  46   47   48   49   50   51   52   53 
2688 2688 2688 2688 2688 2688 2688  384 

$weekday

   Friday    Monday  Saturday    Sunday  Thursday   Tuesday Wednesday 
    19948     19968     19968     19952     19968     19968     19968 
```
We can also make cross tabulations to get a sense of the counts of
two categorical variables.  For example:

```r
# Cross tabulation of month by building
with(d, table(month, building))
```

```
     building
month    2    3    4    5
   1  2971 2971 2971 2971
   2  2688 2688 2688 2688
   3  2972 2972 2972 2972
   4  2880 2880 2880 2880
   5  2976 2976 2976 2976
   6  2880 2880 2880 2880
   7  2976 2976 2976 2976
   8  2976 2976 2976 2976
   9  2880 2880 2880 2880
   10 2976 2976 2976 2976
   11 2880 2880 2880 2880
   12 2880 2880 2880 2880
```
All of these tabular summaries suggest that the data are balanced among the values of the
categorical variables.

#### Divide the Data ####

Now that we have a sense of the structure of the data, we will subdivide the data into meaningful 
groups and make a plot of each group. 
Suppose that we would like to see a time series plot of the energy consumption of each building 
for each day. To accomplish this, we need to divide the data by date to create a distributed 
data frame (`ddf`) object. This can be accomplished by using the `divide()` function from the 
`datadr` package. We will then sort each resulting data frame by `building` and `dateTime` 
using the `arrange()` function from the `plyr` package. 


```r
library(plyr)

# Define a function that will sort each subset by 'building' and 'dateTime'
# The argument, 'x', is a data frame for a single subset
sortFunction <- function(x) {
  arrange(x, building, dateTime)
}

# Divide the data by 'date' and sort the output
byDate <- divide(d, by = "date", postTransFn = sortFunction)
```

Having divided the data, let's look at a single element of the `ddf`, corresponding to the data for
a single day.  Notice how it is a list with two elements, a **key** and a **value**, where the value
is a dataframe containing the data for a single date:  

```r
# Display the structure of the first element of the ddf
str(byDate[1])
```

```
List of 1
 $ :List of 2
  ..$ key  : chr "date=2010-01-01"
  ..$ value:'data.frame':	364 obs. of  12 variables:
  .. ..$ building : int [1:364] 2 2 2 2 2 2 2 2 2 2 ...
  .. ..$ dateTime : POSIXct[1:364], format: "2010-01-01 01:15:00" ...
  .. ..$ year     : int [1:364] 2010 2010 2010 2010 2010 2010 2010 2010 2010 2010 ...
  .. ..$ date     : POSIXct[1:364], format: "2010-01-01" ...
  .. ..$ quarter  : chr [1:364] "Q1" "Q1" "Q1" "Q1" ...
  .. ..$ month    : int [1:364] 1 1 1 1 1 1 1 1 1 1 ...
  .. ..$ monthName: chr [1:364] "January" "January" "January" "January" ...
  .. ..$ week     : int [1:364] 1 1 1 1 1 1 1 1 1 1 ...
  .. ..$ weekday  : chr [1:364] "Friday" "Friday" "Friday" "Friday" ...
  .. ..$ day      : int [1:364] 1 1 1 1 1 1 1 1 1 1 ...
  .. ..$ OAT.F    : num [1:364] 43.8 43.8 43.8 43.8 43.1 ...
  .. ..$ Power.KW : num [1:364] 127 127 124 125 123 ...
  .. ..- attr(*, "split")='data.frame':	1 obs. of  1 variable:
  .. .. ..$ date: POSIXct[1:1], format: "2010-01-01"
  ..- attr(*, "class")= chr [1:2] "kvPair" "list"
```
All the other elements of `byDate` have this same structure--but just for different dates.

#### Define the Panel Function ####

Now let's compute the range of the power so we can use the same axes limits for all 
the plots

```r
# Global axis limits for power and outdoor air temperature
powerLims <- range(d$Power.KW)
tempLims <- range(d$OAT.F)
```
The next step is to define the plotting function, or **panel** function that will be applied
to each subset in the `ddf` to make a separate plot of the power usage over the course of the day
for all four buildings for each date in the data set.

```r
# Create the panel function for plotting power vs. time for each day
power.by.time <- function(x) {

  # 'x' is a data frame for a single subset, or split, of the data

  # Global limits for y axis
  ylim <- powerLims

  # Local limits for x axis
  xlim <- range(x$dateTime)

  # Set plotting options
  par(las = 2, mar = c(4, 4, 0.5, 0.5))

  # Create a blank plot
  with(x, plot(dateTime, Power.KW, type = "n", xlim = xlim, ylim = ylim,
               xlab = "", ylab = "Power (KW)"))

  # Add in the data for each building, giving each building a different color
  for (i in 2:5) {
    with(x[x$building == as.character(i),], 
       lines(dateTime, Power.KW, col = i - 1, lwd = 2))
  }

  # Add a legend to the plot that is positioned near the bottom center
  legend(xlim[1] + 0.5 * diff(xlim), 
         ylim[1],
         paste("Building", 2:5),
         lty = 1, 
         col = c(2:5) - 1, 
         lwd = 3, 
         yjust = 0)

  # Returning NULL is required by trelliscope when the plotting function is 
  # base R code (as opposed to plots generated by lattice or ggplot packages)
  return(NULL)

} # power.by.time()
```
Let's test our panel function on the eighth subset of the data:

```r
# Test the plot on a single subset
power.by.time(byDate[[8]][[2]])
```

![plot of chunk unnamed-chunk-16](figures/knitr/unnamed-chunk-16-1.png) 
#### Define Cognostics ####

We now will define the **cognostics** that correspond to the panel function we just defined.
Cognostiscs are measures of interest that facilitate our cognition for each panel.
They are usually 
scalar valued measurements like summary statistics, but they can also be any character string
that describes information contained in the plot.  The cognostics function takes a single argument
that is a single subset, or split, of the data, and it returns a named list of the 
calculated cognostics.  


```r
kwCog <- function(x) { 

  # 'x' is a data frame for a single subset, or split, of the data

  list(

    # Compute the max and min power consumed for each day
    max = cog(max(x$Power.KW, na.rm = TRUE), desc = "Max Power (KW)"),
    min = cog(min(x$Power.KW, na.rm = TRUE), desc = "Min Power (KW)"),
  
    # Compute the mean and range power
    # Note how some common statistics are built into trelliscope with their own 
    # cognostics functions. For example, cogMean() and cogRange().
    meanPower = cogMean(x$Power.KW, desc = "Mean Power (KW)"),
    rangePower = cogRange(x$Power.KW, desc = "Range of Power (Max - Min) (KW)"),
  
    # Note that we use 'unique()' below because, for each subset, the value of 
    # month, week, and day are repeated for all the rows in the subset for a 
    # single date. So we use unique() to get singel text string for these date variables
    month = cog(unique(x$monthName), desc = "Month Name"),
    week = cog(unique(x$week), desc = "Week in 2010"),
    day = cog(unique(x$day), desc = "Julian Day in 2010")

  ) # close the list

} # kwCog()

# Test the cognostics function for the 73rd subset
kwCog(byDate[[73]][[2]])
```

```
$max
[1] 373.5434

$min
[1] 164.8856

$meanPower
[1] 235.155

$rangePower
[1] 208.6579

$month
[1] "March"

$week
[1] 11

$day
[1] 73
```

#### Make the Trelliscope Display ####

We now have the necessary pieces to create the `trelliscope` visual data base (vdb).  First
we open a connection to the visualization database (vdb) using `vdbConn()` 
and then we create the display using `makeDisplay()`, which writes the requisite files to
the vdb:

```r
# Open connection to the trelliscope visualization database (vdb)
vdbConn("vdb_power", autoYes = TRUE)

# Create the display using Trelliscope's makeDisplay() function.  This writes
# the various plots to the vdb that can then be viewed with trelliscope.
makeDisplay(byDate, name = "Power_by_Day",
            desc = "Power time series for 2010 buildings by day",
            panelFn = power.by.time, cogFn = kwCog)
```

#### A second, related display ####

Using the same division of the data (by date), we can create an additional, related display of 
outdoor air temperature versus time.  We start by defining the panel function:


```r
# Let's also create a related display of power versus temperature by date
power.v.temp <- function(x) {

  # Get the axes limits
  xlim <- tempLims
  ylim <- powerLims

  # Set plotting parameters
  par(las = 1, mar = c(4, 4, 0.5, 0.5))

  # Create a blank plot for outdoor air temp vs. power
  with(x, plot(OAT.F, Power.KW, type = "n", xlim = xlim, ylim = ylim,
               xlab = "Outside Air Temp (F)", ylab = "Power (KW)"))

  # Add points for each building with a different color
  for (i in 2:5) {
    with(x[x$building == as.character(i),], points(OAT.F, Power.KW, col = i - 1))
  }

  # Add in the legend
  legend(xlim[1], ylim[2],
         paste("Building", 2:5),
         pch = 1,
         col = c(2:5) - 1)

  # Returning NULL is required by trelliscope when the plotting function is 
  # base R code (as opposed to plots generated by lattice or ggplot)
  return(NULL)

} # power.v.temp()

# Test the plot on a single subset of the ddf (the 8th subset, in this case)
power.v.temp(byDate[[8]][[2]])
```

![plot of chunk unnamed-chunk-19](figures/knitr/unnamed-chunk-19-1.png) 

Now let's create the visual database for this view using `makeDisplay()`.  We'll use the 
same cognostic function that we defined earlier, and this call to `makeDisplay()` will
write to the same vdb connection we previously created by calling `vdbConn()`:

```r
# Make the trelliscope display
makeDisplay(byDate, name = "Power_vs_Temp_by_Day",
            desc = "Power vs. Temperature for 2010 buildings by day",
            panelFn = power.v.temp, cogFn = kwCog)
```
#### Launch the Trelliscope Viewer ####

Having completed the following essential steps:

- Divided the data using `divide()`
- Defined the panel and cognostic functions
- Connected to a vdb using `vdbConn()`
- Created the `trelliscope` displays using `makeDisplay()`

we are now ready to launch the `trelliscope` viewer using `view()`.  

Note that you'll want to use Firefox or Chrome.  If the display launches in another browser,
you can copy the URL in that browser and paste it into Firefox or Chrome.


```r
# use this port when running locally (on your own computer)
myport <- 8100 
view(port = myport)
```
