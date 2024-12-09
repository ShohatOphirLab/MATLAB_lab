windowBar<-function(current_index,pb,number_of_operation,path_to_scripts){
  
  current_dir =getwd()
  setwd(path_to_scripts)
  files.sources = list.files()
  sapply(files.sources, source)
  setwd(current_dir)
  
  current_index<-current_index+1
  pctg <- paste(round(current_index/number_of_operation *100, 0), "% completed")
  setWinProgressBar(pb, current_index, label = pctg) # The label will override the label set on the
  return(current_index)
  
}