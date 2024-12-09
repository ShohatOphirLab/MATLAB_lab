getNumOfFliesAvg <- function(fileNames,path_to_scripts) {
  
  current_dir =getwd()
  setwd(path_to_scripts)
  files.sources = list.files()
  sapply(files.sources, source)
  setwd(current_dir)
  numCol<-c()
  
  for(i in 1:length(fileNames)){
    matFile <- fileNames[i]
    mat <- scan(toString(matFile))
    numCol[i] <- sqrt(length(mat))
  }
    return(mean(numCol))
}
