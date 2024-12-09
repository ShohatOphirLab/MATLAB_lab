statProcess<-function(groupsNames, groupsParams,path_to_scripts){
  
  current_dir =getwd()
  setwd(path_to_scripts)
  files.sources = list.files()
  sapply(files.sources, source)
  setwd(current_dir)
  
  names = c()
  for (i in 1:length(groupsNames)) {
    names = c(names, rep(groupsNames[i], length(unlist(groupsParams[i]))))
  }
  value = rapply(groupsParams, c)
  data = data.frame(names, value)
  data$names <- as.character(data$names)
  data$names <- factor(data$names, levels=unique(data$names))
  statsData <- getStatisticData(groupsParams, names, value, data,path_to_scripts)
  return(statsData)
}
