---
output: html_document
---
# Computer network traffic 

The NetFlow dataset is a simulated dataset of computer network traffic. 
The packet data is captured at the firewall and aggregated into session
records. Each record identifies the source and destination of the first 
seen packet in that session. You can see more information about the data 
[here](http://hcil2.cs.umd.edu/newvarepository/VAST%20Challenge%202013/challenges/MC3%20-%20Big%20Marketing/).  
The variables in the data are described below:

Variable | Description
---------|-----------------
dateTimeStr | date/timestamp in the form 20130411085433.710938 (2013-04-11 08:54:33.710938)
ipLayerProtocol | IP layer protocol code
ipLayerProtocolCode | text name of IP protocol code (e.g. 6=TCP)
firstSeenSrcIp | IP address of the source of the first packet seen
firstSeenDestIp | IP address of the destination of the first packet seen in this session
firstSeenSrcPort | source port of the first packet captured in this session
firstSeenDestPort | destination port of the first packet captured in this session
moreFragments | if nonzero, this session continues into a subsequent record
contFragments | if nonzero, this record is not the first session record but a continuation
durationSeconds | session duration in seconds
firstSeenSrcPayloadBytes | total payload bytes in this session from packets originating at the firstSeenSrcIp
firstSeenDestPayloadBytes | total payload bytes in this session from packets originating at the firstSeenDstIp
firstSeenSrcTotalBytes | total header+payload bytes in this session from packets originating at the firstSeenSrcIp
firstSeenDestTotalBytes | total header+payload bytes in this session from packets originating at the firstSeenDstIp
firstSeenSrcPacketCount | total number of packets in this session originating at the firstSeenSrcIp
firstSeenDestPacketCount | total number of packets in this session originating at the firstSeenDstIp
recordForceOut | if nonzero the record was flushed to data file before session timeout (15 minutes) usually by program shutdown

# Preliminaries 

Let's set the working directory for this example. You need to change the path in the call to `setwd()` below to correctly point to the `netflow_demo` directory.


```r
setwd("netflow_demo")
```

And let's remove any possible left-over objects in the Global environment:

```r
rm(list = ls())
```

And load the requisite packages:

```r
library(trelliscope)
library(plyr)
```

# Pre-made Trelliscope Displays 

The following will launch two pre-made trelliscope displays:
- Hourly counts of connections vs time 
- Hourly counts of connections vs source/destination
where each panel shows data for a specific host or destination IP address. 

The purpose of this activity is to launch the trelliscope display and then explore the data---to look for patterns, bad data, anomalies, etc. The code required to generate these displays is shown next.


```r
vdbConn("vdb_netflow", autoYes = TRUE)
myport <- 8100 # use this when running locally on your own computer
# myport <- Sys.getenv("TR_PORT") # use this on demo cluster
view(port = myport)
```

## Challenge question

The following question is provided, free of charge, to help you become better acquainted with the trelliscope interface. The question will not be graded; it is strictly for learning purposes. 

- There is a set of workstations that were infected with malware and now form a botnet. This botnet has strated a recurring Denial of Service attack against an external IP address. Can you find the machines in question? (Hint: Look for high numbers of outgoing connections)

# Trelliscope and Hadoop

The time has come for you, the user, to do some of the coding work. In particular, the following demo will teach you how to use hadoop and trelliscope together to visually analyze a large and complete data set. Luckily for us, we've already covered this demo [here](http://tessera.io/docs-r-intro-bootcamp/#activity-22-using-tessera-with-hadoop-to-analyze-large-data). The necessary information will be covered in sections 2.2 and 2.3 of the [R boot camp](http://tessera.io/docs-r-intro-bootcamp/). We encourage you to go step by step through the process, particuarly since Hadoop has a steep learning curve.   
