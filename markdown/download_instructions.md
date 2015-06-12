<!--
Comments:
To create index.html, do this in R:

   library(buildDocs)
   setwd("~/Work/github/docs-csp2015")
   buildDocs("analysis", outLoc=".", copyrightText="")

   # Comment out copyright text, and 'Previous' and 'Next' links since they
   # aren't relevant (and they break).  Ignore the warning.
   library(Smisc)
   streamEdit(list(c = list(at = "<p>&copy; , ", type = "html", fixed = TRUE), 
                   c = list(at = "id=\"previous\">&larr;", type = "html", fixed = TRUE), 
                   c = list(at = "id=\"next\">Next &rarr;", type = "html", fixed = TRUE)), 
              inFile = "index.html", outFile = "index.html")

Then in a text editor edit links in 1&2 to remove interior <a> tags on each 
(so that the links open in new tabs).
-->

# Tessera Demo at the Conference on Statistical Practice 2015 #

## CSP 2015 Demo ##

### Introduction ###

The Tessera team presented an interactive demo at the 
<a href="http://www.amstat.org/meetings/csp/2015/" target="_blank">
2015 Conference on Statistical Practice</a> in 
New Orleans on February 21, 2015.

There were three demonstration activities involving different data sets:
- Housing sales
- Power utilization in retail buildings
- Computer network traffic

Each demonstration contains four components:
- A description of the data set
- Simple code for launching a pre-created `trelliscope` view you can use to explore the data
- A set of challenge questions to guide your exploration of the data
- The R code used to create the `trelliscope` view

These three demos are documented on this site, and you can run them on your
own if you like.  To do so, you will first need to install some of
the Tessera tools

### Download Demo Materials ###

To run these demonstrations, you will first need to install R along with
a local installation of Tessera.  A local installation means that Tessera can
run on your own computer without requiring a computational backend like Hadoop.

#### Installation of R and Tessera

1. If you do not already have the most recent version of R, please download and
install it here: <a href="http://cran.r-project.org" target="_blank">
http://cran.r-project.org</a>. 

2. Optional: You may find the RStudio development environment an easier way
to program in R, but it is not necessary. You may download it here:
<a href="http://www.rstudio.com/" target="_blank">http://www.rstudio.com</a>.

3. Open R and execute the following commands to install Tessera and other libraries 
you'll need for the demos:
   
   ```r
      install.packages(c("devtools", "plyr", "maps"))
      library(devtools)
      install_github("tesseradata/datadr")
      install_github("tesseradata/trelliscope")
      install_github("hafen/housingData")
   ```
   **For Windows users:**  when installing `devtools`, you may notice a warning like the following:
   
   ```r
   > library(devtools)
   WARNING: Rtools is required to build R packages, but no version of Rtools compatible with R 3.1.2 was found. (Only the following incompatible version(s) of Rtools were found:3.2)
   Please download and install Rtools 3.1 from http://cran.r-project.org/bin/windows/Rtools/ and then run find_rtools().
   ```
  **For Mac users:** when installing `devtools`, you may notice a similar warning indicating that `Xcode` is required.  

  For both Windows and Mac users, you can ignore these warnings because the Tessera packages do not include C or Fortran code that 
  requires compilation.

4. You will need the Firefox or Chrome browser installed on your computer.  Internet Explorer and Safari 
sometimes have problems displaying Trelliscope views.


#### Download demonstration files
 
1. Download the CSP Tessera demo files and unzip them on your computer:
[Tessera_demo_CSP2015.zip](Tessera_demo_CSP2015.zip)

2. The zip file contains a folder called **demos**.  Set your working directory in R to this folder,
using something like `setwd("mypaths_to_demos/demos")`.  The **demos** folder 
contains a folder for each of the three demos:  **power_demo**, **housing_demo**, and **netflow_demo**.
Each demonstration folder has a single **.R** file which contains the code for the demonstration. Open that 
file in your editor of choice and begin!

