library(RStata)

options("RStata.StataPath"    = "/usr/local/bin/")
options("RStata.StataVersion" = 16)
#chooseStataBin()


setwd("/home/albarran/Dropbox/UABCourse/TopicsCausalInference/")

stata("./code/01nsw.do")

st_src <- "

webuse abdata
sum

"
stata(st_src)
