#!/usr/bin/env Rscript

install.packages("/projectnb/dietzelab/kiwheel/NEFI_pheno/PhenologyBayesModeling",repo=NULL)
library("ncdf4")
library(plyr)
library("PhenologyBayesModeling")
library(doParallel)
library("rjags")
library("runjags")
library(doParallel)

#detect cores.
n.cores <- 6

#register the cores.
#registerDoParallel(cores=n.cores)

siteData <- read.csv("GOES_Paper_Sites.csv",header=TRUE)
iseq <- c(seq(1,6))
print(iseq)
print(dim(siteData))
#output <- 
#foreach(s = iseq) %dopar% {
for(s in iseq){
  print("inside foreeach")
  siteName <- as.character(siteData[s,1])
  diurnalFits <- intersect(dir(pattern="varBurn4.RData"),dir(pattern=siteName))
  c.vals <- numeric()
  prec.vals <- numeric()
  days <- numeric()
  counts <- numeric()
  meds <- numeric()
  outDataFile <- paste(siteName,"_diurnalFitData_median.RData",sep="")
  if(!file.exists(outDataFile)){
    for(i in 1:length(diurnalFits)){
      print(diurnalFits[i])
      load(diurnalFits[i])
      if(typeof(var.burn)!=typeof(FALSE)){
        out.mat <- as.matrix(var.burn)
        print(colnames(out.mat))
        c <- mean(out.mat[,2])
        prec <- 1/var(out.mat[,2])
        med <- median(out.mat[,2])
        dy <- strsplit(diurnalFits[i],"_")[[1]][2]
        dayDataFile <- intersect(intersect(dir(path="dailyNDVI_GOES",pattern=paste(dy,".csv",sep="")),dir(path="dailyNDVI_GOES",pattern=siteName)),dir(path="dailyNDVI_GOES",pattern="GOES_diurnal"))
        print(dayDataFile)
        dayData <- read.csv(paste("dailyNDVI_GOES/",dayDataFile,sep=""),header=FALSE)
        ct <- length(dayData[2,][!is.na(dayData[2,])])
        if(ct>1){
          c.vals <- c(c.vals,c)
          prec.vals <- c(prec.vals,prec)
          counts <- c(counts,ct)
          days <- c(days,dy)
          meds <- c(meds,med)
        }
      }
    }
    data <- list()
    for(i in 1:length(days)){
      if(days[i]<182){
        days[i] <- as.numeric(days[i]) + 365
      }
    }
    data$x <- as.numeric(days)
    data$y <- as.numeric(c.vals)
    data$obs.prec <- as.numeric(prec.vals)
    data$n <- length(data$x)
    data$meds <- as.numeric(meds)
    #data$size <- as.numeric(counts)
    print(dim(data$x))
    print(dim(data$y))
    print(data$x)
    save(data,file=outDataFile)
    print("Done with creating Data")
  }
  varBurnFileName <- paste(siteName,"_overall_varBurn_median.RData",sep="")
  if(file.exists(varBurnFileName)){
    load(outDataFile)
    j.model <- createBayesModel.DB_Overall(data=data)
    var.burn <- runMCMC_Model(j.model=j.model,variableNames = c("TranS","bS","TranF","bF","d","c","k","prec"))
    save(var.burn,file=paste(siteName,"_overall_varBurn2.RData",sep=""))
  }
}

