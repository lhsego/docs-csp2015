

setwd("power_demo")



rm(list = ls())



library(trelliscope)
library(plyr)



# Load some preconfigured global plotting limits
load("plottingLims.Rdata")

# Open the connection to the pre-existing trelliscope visualization.
# ("vdb_power" is a folder in "power_demo")
vdbConn("vdb_power")

# use this port when running locally on your own computer
myport <- 8100 

# use this port on the AWS demo cluster
# myport <- Sys.getenv("TR_PORT") 

# Launch the trelliscope viewer.  Use Ctrl-C or ESC to stop the reviewer and return
# the R prompt
view(port = myport)

