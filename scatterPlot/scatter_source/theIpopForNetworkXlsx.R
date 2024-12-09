theIpopForNetworkXlsx<-function(current_dir,namesInOrder){
  
  
  current =getwd()
  setwd(path_to_scripts)
  files.sources = list.files()
  sapply(files.sources, source)
  setwd(current)
  
  #this function find what is the index iin the xlsx file to claculate in the user wanted order
  currentDirName<-basename(current_dir) 
  
  currentIndexInxlsx<-which(currentDirName == namesInOrder)

  return(currentIndexInxlsx)
}