DunnTstDataFrame<-function(currentName,Stat,path_to_scripts,groupsNames){
  
  
  current_dir =getwd()
  setwd(path_to_scripts)
  files.sources = list.files()
  sapply(files.sources, source)
  setwd(current_dir)
  
  
  dunnTst<-data.frame()
  dunnTst<-currentName
  all_names_from_comp<-Stat[[1]][["comparisons"]]
  #all_names_from_comp<-change_row_names(all_names_from_comp,path_to_scripts,groupsNames,FALSE)
  
  all_values_from_comp<-Stat[[1]][["P"]]
  dunnTst<-cbind(dunnTst,as.data.frame(t(all_values_from_comp)))
  colnames(dunnTst)<-c("name",all_names_from_comp)
  dunnTst$test<-Stat[[2]]
  dunnTst$pVal <-Stat[[3]]
  
  return(dunnTst)
}