

setwd("netflow_demo")



rm(list = ls())



library(trelliscope)
library(plyr)



vdbConn("vdb_netflow", autoYes = TRUE)
myport <- 8100 # use this when running locally on your own computer
# myport <- Sys.getenv("TR_PORT") # use this on demo cluster
view(port = myport)


