<!--
Comments:
To create index.html, do this in R:

   library(buildDocs)
   setwd("~/docs-csp2015")
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

### Download Demo Materials ###

The Tessera team will be presenting an interactive demo at the 
<a href="http://www.amstat.org/meetings/csp/2015/" target="_blank">
2015 Conference on Statistical Practice</a> in 
New Orleans on February 21, 2015.

Participants who would like to download the Tessera tools prior to the demo 
please follow these instructions. These tools will allow you to use and test 
Tessera on your own computer without Hadoop or a similar parallel 
processing backend.

1. If you do not already have the most recent version of R, (version 3.1.2), please download and
install it here: <a href="http://cran.r-project.org" target="_blank">
http://cran.r-project.org</a>. 

2. Optional: You may find the RStudio development environment an easier way
to program in R, but it is not necessary. You may download it here:
<a href="http://www.rstudio.com/" target="_blank">http://www.rstudio.com/</a>.

3. You will need the Firefox or Chrome browser installed on your computer.  Internet Explorer and Safari sometimes have problems displaying Trelliscope views.

4. Open R and execute the following commands to install Tessera and other libraries you'll need for the demos:
   
   ```r
      install.packages(c("devtools", "plyr", "maps"))
      library(devtools)
      install_github("tesseradata/datadr")
      install_github("tesseradata/trelliscope")
      install_github("hafen/housingData")
   ```
   **For Windows users:**  when installing `devtools`, you may notice the following warning, which
   you can ignore:
   
   ```r
   > library(devtools)
   WARNING: Rtools is required to build R packages, but no version of Rtools compatible with R 3.1.2 was found. (Only the following incompatible version(s) of Rtools were found:3.2)
   Please download and install Rtools 3.1 from http://cran.r-project.org/bin/windows/Rtools/ and then run find_rtools().
   ```
 
5. Download the CSP Tessera demo files and unzip them on your computer:
[Tessera_demo_CSP2015.zip](Tessera_demo_CSP2015.zip)

6. The zip file contains a folder called **demos**.  Set your working directory in R to this folder,
using something like `setwd("mypaths/demos")`.  The **demos** folder 
contains a folder for each of the three demos:  **power_demo**, **netflow_demo**, and **housing_demo**.
Each demonstration folder has a single **.R** file which contains the code for the demonstration. Open that 
file in your editor of choice and begin!

#### We look forward to seeing you at CSP! 
