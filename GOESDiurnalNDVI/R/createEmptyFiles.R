#' Creates empty files for days missing cloud mask data or radiance data
#'
#' @param siteData matrix of site data where the sites are in individual rows and the columns are siteName, latitude, longitude, timezone
#' @param year The desired year
#' @param day The desired day of year
#' @export
createEmptyFiles <- function(siteData,year,day){
  for(i in 1:length(siteData)){
    siteName <- as.character(siteData[i,1])
    fileName <- paste("GOES_NDVI_Diurnal",siteName,"_",year,day,".csv",sep="")
    write.table(NA,file=fileName,sep=",",col.names=FALSE,row.names=FALSE)
  }
}
