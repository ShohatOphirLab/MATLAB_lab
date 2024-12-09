mainScale<-function(dir,xlsxFile,path_to_scripts,groupsNames,lengthParams,numberParams,num_of_pop){
  current_dir =getwd()
  setwd(path_to_scripts)
  files.sources = list.files()
  sapply(files.sources, source)
  setwd(current_dir)
  
  ListedparamsScaled<-ScaleNetwork(numberParams,lengthParams,num_of_pop,xlsxFile)
  lengthParamsScaled<- as.data.frame(ListedparamsScaled[1])
  numberParamsScaled<- as.data.frame(ListedparamsScaled[2])
  
  
  #did scaleing for all groups and now we calculate the mean and sd 
 for(i in 1:num_of_pop){
  netWorkParamsCalcuPerGroup(dir[i,1],i,path_to_scripts,lengthParamsScaled,numberParamsScaled,xlsxFile,num_of_pop,TRUE)
  
 }
  #scaleing all other features
  for_Scaleing(dir,path_to_scripts)

}