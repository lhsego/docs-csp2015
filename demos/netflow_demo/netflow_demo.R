###############################################################################
#### NetFlow Example
#### Using DataDR and Trelliscope with Hadoop for distributed computing.
###############################################################################

# The NetFlow dataset is a simulated dataset of computer network traffic. 
# The packet data is captured at the firewall and aggregated into session
# records. Each record identifies the source and destination of the first 
# seen packet in that session. You can see more information about the data here:  
# http://hcil2.cs.umd.edu/newvarepository/VAST%20Challenge%202013/challenges/MC3%20-%20Big%20Marketing/
# The variables in the dataset are described below:
# 
# dateTimeStr - date/timestamp in the form 20130411085433.710938 
#       (2013-04-11 08:54:33.710938)
# ipLayerProtocol - IP layer protocol code
# ipLayerProtocolCode - text name of IP protocol code (e.g. 6=TCP)
# firstSeenSrcIp - IP address of the source of the first packet seen
# firstSeenDestIp - IP address of the destination of the first packet seen in 
#       this session
# firstSeenSrcPort - source port of the first packet captured in this session
# firstSeenDestPort - destination port of the first packet captured in this 
#       session
# moreFragments - if nonzero, this session continues into a subsequent record
# contFragments - if nonzero, this record is not the first session record but 
#       a continuation
# durationSeconds - session duration in seconds
# firstSeenSrcPayloadBytes - total payload bytes in this session from packets 
#       originating at the firstSeenSrcIp
# firstSeenDestPayloadBytes - total payload bytes in this session from packets 
#       originating at the firstSeenDstIp
# firstSeenSrcTotalBytes - total header+payload bytes in this session from 
#       packets originating at the firstSeenSrcIp
# firstSeenDestTotalBytes - total header+payload bytes in this session from 
#       packets originating at the firstSeenDstIp
# firstSeenSrcPacketCount - total number of packets in this session 
#       originating at the firstSeenSrcIp
# firstSeenDestPacketCount - total number of packets in this session 
#       originating at the firstSeenDstIp
# recordForceOut - if nonzero the record was flushed to data file before 
#       session timeout (15 minutes) usually by program shutdown


# Load necessary libraries and initialize environment
library(datadr)
library(trelliscope)

################################################################################
#### Let's set the working directory for this example. You may have to change the
#### path in the command below to correctly point to the 'netflow_demo' directory
setwd("netflow_demo")

# Remove any left-over objects in the Global environment
rm(list = ls())

###############################################################################
#### To see the Trelliscope display execute this section. The code that creates
#### these displays is below, but cannot be run locally.

vdbConn("vdb_netflow", autoYes = TRUE)
myport <- 8100 # use this when running locally on your own computer
# myport <- Sys.getenv("TR_PORT") # use this on demo cluster
view(port = myport)


###############################################################################
#### From here on, this example can only be run on a cluster with Hadoop
#### running and installed

###############################################################################
#### Analyze the NetFlow dataset using Hadoop and create Trelliscope displays.
#### There will be a Hadoop cluster at the CSP demo to allow participants
#### to explore this example. 

# Load libraries
library(Rhipe)
library(cyberTools)
rhinit()
rhoptions(file.types.remove.regex="(/_meta|/_rh_meta|/_outputs|/_SUCCESS|/_LOG|/_log|rhipe_debug|rhipe_merged_index_db)")

# Set time zone to "UTC" for use with dates in the data
Sys.setenv(TZ = "UTC")

# Set working directory on HDFS
hdfs.setwd(Sys.getenv("HDFS_USER_VAST"))

# Look for text data file in HDFS
rhls("raw/nf") 

# Make a date parsing function to use during data ingest
nfTransform <- function(x) {
  x$date <- as.POSIXct(as.numeric(as.character(x$TimeSeconds)), origin = "1970-01-01", tz = "UTC")
  x[,setdiff(names(x), c("TimeSeconds", "parsedDate", "dateTimeStr"))]  
}

# Initiate a connection to existing csv text file on HDFS
csvConn <- hdfsConn("raw/nf", type = "text")

# Initiate a new connection where parsed NetFlow data will be stored
nfConn <- hdfsConn("nfRaw", autoYes=TRUE) 

# Read in NetFlow data - returns a ddf
nfRaw <- drRead.csv(csvConn, output = nfConn, postTransFn = nfTransform)

# Look at the nfRaw object 
nfRaw 

# Update attributes to calculate summary statistics
nfRaw <- updateAttributes(nfRaw)

# nfRaw can be reloaded in any subsequent R session using the following command
# nfRaw <- ddf(hdfsConn("nfRaw"))

# Look at the updated nfRaw object
nfRaw

# Look at data summary (computed during updateAttributes call)
summary(nfRaw)

# Truncate date to minute
nfRaw <- addTransform(nfRaw, fn=function(x) {
   x$timeMinute <- as.POSIXct(trunc(x$date, 0, units="mins"))
   x
})

# Use drAggregate to count sessions per minute per destination IP
bigTimeAgg <- drAggregate(~ timeMinute + firstSeenDestIp, 
                          data = nfRaw)

# Sort by number of sessions
bigTimeAgg <- bigTimeAgg[order(bigTimeAgg$Freq, decreasing=TRUE),]

# convert timeMinute column to a time variable
bigTimeAgg$timeMinute <- as.POSIXct(bigTimeAgg$timeMinute, tz = "UTC")

# Look at the first few rows
head(bigTimeAgg)


#### Trelliscope displays for NetFlow dataset

# Variables to filter on
bigTimes <- sort(unique(bigTimeAgg$timeMinute[bigTimeAgg$Freq > 1000]))
badIPs <- c("10.138.214.18", "10.17.15.10", "10.12.15.152", "10.170.32.110", 
   "10.170.32.181", "10.10.11.102", "10.247.106.27", "10.247.58.182", 
   "10.78.100.150", "10.38.217.48", "10.6.6.7", "10.12.14.15", "10.15.7.85", 
   "10.156.165.120", "10.0.0.42", "10.200.20.2", "10.70.68.127", 
   "10.138.235.111", "10.13.77.49", "10.250.178.101")
httpIPs <- c("172.20.0.15", "172.20.0.4", "172.10.0.4", "172.30.0.4")

# Add a data transformation that filters out some records and adds
# fields for the time rounded to minute and whether the source
# or destination IP is inside the LAN
nfRaw <- addTransform(nfRaw, 
  function(x) {
      suppressMessages(library(cyberTools))
      x$timeMinute <- as.POSIXct(trunc(x$date, 0, units = "mins"))
      x <- subset(x, !(timeMinute %in% bigTimes & 
                         firstSeenSrcIp %in% c(httpIPs, badIPs) & 
                         firstSeenDestIp %in% c(httpIPs, badIPs)))
       if(nrow(x) > 0) {
          return(getHost(x))
       } else {
         x$hostIP <- character(0)
         x$srcIsHost <- logical(0)
         return(x)
       }
  })

# Force the transformation to be calculated immediately
nfWithInternalHost <- recombine(nfRaw, combDdo, 
                          output = hdfsConn("nfWithInternalHost", autoYes=TRUE), 
                          overwrite=TRUE)


# Divide data by host IP
nfByHost <- divide(nfWithInternalHost, by = "hostIP",
                   update=TRUE,
                   output = hdfsConn("nfByHost", autoYes=TRUE) 
  )

# Look at nfByHost
nfByHost

# Look at the distribution of number of rows in nfByHost
plot(log10(splitRowDistn(nfByHost)))

# Use recombine to roll data up to counts by hour for each host
hostTimeAgg <- recombine(nfByHost, 
                         apply = function(x) {
                           timeHour <- as.POSIXct(trunc(x$date, 0, 
                              units = "hours"))
                           res <- data.frame(xtabs(~ timeHour))
                           res$timeHour <- as.POSIXct(res$timeHour)
                           res
                         }, 
                         combine = combDdo()
)

# Initiate a visualization database (VDB) connection
vdbConn("vdb_netflow", autoYes=TRUE)

# Panel function for simple time series plot of frequency
timePanel <- function(x) {
  xyplot(sqrt(Freq) ~ timeHour, data = x, type = c("p", "g"))
}

# Test on a subset
timePanel(hostTimeAgg[[1]][[2]])

# Cognostics function for simple time series plot
timeCog <- function(x) {
  IP <- attr(x, "split")$hostIP
  curHost <- hostList[hostList$IP == IP,]
  
  list(
    hostName = cog(curHost$hostName, desc = "host name"),
    type = cog(curHost$type, desc = "host type"),
    nobs = cog(sum(x$Freq), "log 10 total number of connections"),
    timeCover = cog(nrow(x), desc = "number of hours containing connections"),
    medHourCt = cog(median(sqrt(x$Freq)), 
         desc = "median square root number of connections"),
    madHourCt = cog(mad(sqrt(x$Freq)), 
         desc = "median absolute deviation square root number of connections"),
    max = cog(max(x$Freq), desc = "maximum number of connections in an hour")
  )
}

# Test on one division
timeCog(hostTimeAgg[[1]][[2]])

# Create the trelliscope display
makeDisplay(hostTimeAgg,
            name = "hourly_count",
            group = "inside_hosts",
            desc = "time series plot of hourly counts of connections for each inside host",
            panelFn = timePanel,
            cogFn = timeCog,
            width = 800, height = 400,
            lims = list(x = "same", y = "same")
)

# Launch trelliscope
myport <- as.numeric(Sys.getenv("TR_PORT"))
view(port=myport)

# Use recombine again to get hourly counts by "incoming", "outgoing"
hostTimeDirAgg <- recombine(nfByHost, 
                   apply = function(x) {
                     x$timeHour <- as.POSIXct(trunc(x$date, 0, units = "hours"))
                     res <- data.frame(xtabs(~ timeHour + srcIsHost, data = x))
                     res$timeHour <- as.POSIXct(res$timeHour)
                     res$direction <- "incoming"
                     res$direction[as.logical(as.character(res$srcIsHost))] <- "outgoing"
                     subset(res, Freq > 0)
                   }, 
                   combine = combDdo()
)

# New panel function that groups data by incoming/outgoing
timePanelDir <- function(x) {
  xyplot(
    sqrt(Freq) ~ timeHour, groups = direction, 
    data = x, type = c("p", "g"), auto.key = TRUE
  )
}

# New cognostics function that calculates metrics for incoming and outgoing separately
timeCog2 <- function(x) {
  IP <- attr(x, "split")$hostIP
  curHost <- hostList[hostList$IP == IP,]
  ind.incoming <- x$direction == "incoming"
  
  cog.values <- list(
    hostName = cog(curHost$hostName, desc = "host name"),
    type = cog(curHost$type, desc = "host type"),
    incomingNobs = cog(sum(x$Freq[ind.incoming]), 
                       desc="log 10 total number of incoming connections"),
    outgoingNobs = cog(sum(x$Freq[!ind.incoming]), 
                  desc="log 10 total number of outgoing connections"),
    incomingTimeCover = cog(sum(ind.incoming), 
                  desc = "number of hours containing incoming connections"),
    outgoingTimeCover = cog(sum(!ind.incoming), 
                  desc = "number of hours containing outgoing connections"),
    incomingMedHourCt = cog(median(sqrt(x$Freq[ind.incoming]), na.rm=TRUE), 
                  desc = "median square root number of incoming connections"),
    outgoingMedHourCt = cog(median(sqrt(x$Freq[!ind.incoming]), na.rm=TRUE), 
                  desc = "median square root number of outgoing connections"),
    incomingMadHourCt = cog(mad(sqrt(x$Freq[ind.incoming])), 
                  desc = "median absolute deviation square root number of incoming connections"),
    outgoingMadHourCt = cog(mad(sqrt(x$Freq[!ind.incoming])), 
                  desc = "median absolute deviation square root number of outgoing connections"),
    incomingMax = cog(max(c(0, x$Freq[ind.incoming])), 
                  desc = "maximum number of incoming connections in an hour"),
    outgoingMax = cog(max(c(0, x$Freq[!ind.incoming])), 
                  desc = "maximum number of outgoing connections in an hour")
  )
  cog.values[unlist(lapply(cog.values, is.na))] <- -1
  cog.values
}

# Create the display
makeDisplay(hostTimeDirAgg,
            name = "hourly_count_src_dest",
            group = "inside_hosts",
            desc = "time series plot of hourly counts of connections for each inside host by source / destination",
            panelFn = timePanelDir,
            width = 800, height = 400,
            cogFn = timeCog2,
            lims = list(x = "same", y = "same"))

# View display
view(port=myport)

# Trelliscope challenge:
# There is a set of workstations that were infected with malware and now form 
# a botnet. This botnet has started a recurring Denial of Service attack
# against an external IP. Can you find the machines in question?
# Hint: look for high numbers of outgoing connections
