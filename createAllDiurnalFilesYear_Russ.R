#!/usr/bin/env Rscript

library("ncdf4")
library(plyr)
library("PhenologyBayesModeling")
library(doParallel)

#detect cores.
#n.cores <- detectCores()
n.cores <- 6

#register the cores.
registerDoParallel(cores=n.cores)


createNDVI_GOES_diurnal <- function(lat,long,siteID,startDay,endDay,orbitVersion){
  #load/calcuate GOES NDVI data
  lat.rd <- lat*2*pi/360
  long.rd <- long*2*pi/360
  
  Ind2 <- getDataIndex(getABI_Index(lat.rd,long.rd,orbitVersion="OLD"),2,orbitVersion=orbitVersion)
  Ind3 <- getDataIndex(getABI_Index(lat.rd,long.rd,orbitVersion="OLD"),3,orbitVersion=orbitVersion)
  ACM.ind <- getDataIndex(getABI_Index(lat.rd,long.rd,orbitVersion="OLD"),"ACM",orbitVersion=orbitVersion)
  
  i2 <- Ind2[1]
  j2 <- Ind2[2]
  i3 <- Ind3[1]
  j3 <- Ind3[2]
  
  NDVI.vals <- list()
  
  days <- seq(startDay,endDay,1)
  day.time.vals <- list()
  for(i in 1:length(days)){
    #print(days)
    days[i] <- as.numeric(days[i])
    if(as.numeric(days[i]) < 10){
      days[i] <- paste("00",as.character(days[i]),sep="")
    }
    else if(as.numeric(days[i]) < 100){
      days[i] <- paste("0",as.character(days[i]),sep="")
    }
  }
  for (i in 1:length(days)){
    print(days)
    days[i] <- as.numeric(days[i])
    if(days[i] < 10){
     days[i] <- paste("00",as.character(days[i]),sep="")
    }
    else if(days[i] < 100){
     days[i] <- paste("0",as.character(days[i]),sep="")
    }
    print(days[i])
    days[i] <- as.character(days[i])
    filestrACM <- paste("OR_ABI-L2-ACMC-M3_G16_s2017",days[i],sep="")
    ACM.files <- dir(path="GOES_Data2017",pattern=filestrACM)
    print(length(ACM.files))
    if(!dir.exists((paste("GOES_Data2017/",dir(path="GOES_Data2017",pattern=filestrACM),sep="")))){
      if(length(ACM.files>1)){
        for(j in 1:length(ACM.files)){
          day.time <- substr(ACM.files[j],24,34)
          #print(j)
          print(day.time)
          day.time.vals <- c(day.time.vals,day.time)
          filePath <- paste("GOES_Data2017/",ACM.files[j],sep="")
          #print(filePath)
          ACM.file <-nc_open(paste("GOES_Data2017/",ACM.files[j],sep=""))
          #print(dim(ncvar_get(ACM.file, "BCM")))
          #print(ACM.ind)
          clouds <- ncvar_get(ACM.file,"BCM")[ACM.ind[1],ACM.ind[2]]
          if(!is.na(clouds)){
            if (clouds ==0){
              filestrC03 <- paste("OR_ABI-L1b-RadC-M3C03_G16_s",day.time,sep="")
              filestrC02 <- paste("OR_ABI-L1b-RadC-M3C02_G16_s",day.time,sep="")
              filePathC02 <- paste("GOES_Data2017/",dir(path="GOES_Data2017",pattern=filestrC02),sep="")
              filePathC03 <- paste("GOES_Data2017/",dir(path="GOES_Data2017",pattern=filestrC03),sep="")
              if(nchar(filePathC02)>20 & nchar(filePathC03)>20){
                R2.file <- nc_open(paste("GOES_Data2017/",dir(path="GOES_Data2017",pattern=filestrC02),sep=""))
                R3.file <- nc_open(paste("GOES_Data2017/",dir(path="GOES_Data2017",pattern=filestrC03),sep=""))
                R3.DQF <- ncvar_get(R3.file,"DQF")
                R2.DQF <- ncvar_get(R2.file,"DQF")
                if(R3.DQF[i3,j3]==0 & R2.DQF[i2,j2]==0 & R2.DQF[i2,j2]==0 & R2.DQF[(i2+1),j2]==0 & R2.DQF[i2,(j2+1)]==0 & R2.DQF[(i2+1),(j2+1)]==0){
                  NDVI.val <- getSpecificNDVI(Ind2,Ind3,day.time)
                }
                else{
                  NDVI.val <- NA
                }
              }
              else{
                NDVI.val <- NA
              }
            }
            else{
              NDVI.val <- NA
            }
          }
          else{
            NDVI.val <- NA
          }
          NDVI.vals <- c(NDVI.vals,NDVI.val)
        }
      }
    }
  }
  
  fileName <- paste("GOES_NDVI_Diurnal",siteID,"_",startDay,"_",endDay,"_kappaDQF.csv",sep="")
  output <- rbind(t(day.time.vals),NDVI.vals)
  write.table(output,file=fileName,sep=",",col.names=FALSE,row.names=FALSE)
}


siteData <- read.csv("GOES_Paper_Sites.csv",header=TRUE)
siteName <- as.character(siteData[9,1])
lat <- as.numeric(siteData[9,2])
long <- as.numeric(siteData[9,3])

timeFrames <- matrix(ncol=3,nrow=24)
timeFrames[1,] <- c(182,186,"OLD") 
timeFrames[2,] <- c(187,193,"OLD") 
timeFrames[3,] <- c(194,200,"OLD") 
timeFrames[4,] <- c(201,206,"OLD") 
timeFrames[5,] <- c(207,212,"OLD")
timeFrames[6,] <- c(213,218,"OLD") 
timeFrames[7,] <- c(219,224,"OLD") 
timeFrames[8,] <- c(225,230,"OLD") 
timeFrames[9,] <- c(231,236,"OLD")
timeFrames[10,] <- c(237,242,"OLD") 
timeFrames[11,] <- c(243,250,"OLD") 
timeFrames[12,] <- c(251,256,"OLD")
timeFrames[13,] <- c(257,261,"OLD")
timeFrames[14,] <- c(262,267,"OLD")
timeFrames[15,] <- c(268,273,"OLD")
timeFrames[16,] <- c(274,279,"OLD")
timeFrames[17,] <- c(280,285,"OLD")
timeFrames[18,] <- c(286,291,"OLD")
timeFrames[19,] <- c(292,302,"OLD")
timeFrames[20,] <- c(303,311,"OLD")
timeFrames[21,] <- c(312,317,"OLD")
timeFrames[22,] <- c(318,321,"OLD")

 
timeFrames[23,] <- c(342,351,"NEW")
timeFrames[24,] <- c(352,365,"NEW") #Dec 2



# timeFrames[1,] <- c(189,200,"OLD") #July1
# timeFrames[2,] <- c(201,212,"OLD") #July2
# 
# timeFrames[3,] <- c(220,231,"OLD")
# timeFrames[4,] <- c(232,243,"OLD") #Aug 2
# 
# timeFrames[5,] <- c(251,261,"OLD")
# timeFrames[6,] <- c(262,273,"OLD") #Sept 2
# 
# timeFrames[7,] <- c(312,321,"OLD")
# timeFrames[8,] <- c(322,334,"OLD") #Nov 2
# 
# timeFrames[9,] <- c(342,351,"NEW")
# timeFrames[10,] <- c(352,365,"NEW") #Dec 2

# timeFrames <- matrix(ncol=2,nrow=5)
# timeFrames[1,] <- c(189,189) #July1
# #timeFrames[2,] <- c(201,202) #July2
# 
# timeFrames[2,] <- c(220,220)
# #timeFrames[4,] <- c(232,233) #Aug 2
# 
# timeFrames[3,] <- c(251,251)
# #timeFrames[6,] <- c(262,263) #Sept 2
# 
# timeFrames[4,] <- c(312,312)
# #timeFrames[8,] <- c(322,323) #Nov 2
# 
# timeFrames[5,] <- c(342,342)
# #timeFrames[10,] <- c(352,353) #Jan 2

output <- foreach(i = 1:24) %dopar% {
  startDay <- timeFrames[i,1]
  endDay <- timeFrames[i,2]
  orbitVersion <- timeFrames[i,3]
  print(timeFrames[i,])
  createNDVI_GOES_diurnal(lat=lat, long=long, siteID=siteName,startDay=startDay,endDay=endDay,orbitVersion = orbitVersion)
  print(paste(i, "done",sep=" "))
}