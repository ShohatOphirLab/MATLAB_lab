change_row_names<-function(stats_data,path_to_scripts,groupsNames,is_anova){
  
  current_dir =getwd()
  setwd(path_to_scripts)
  files.sources = list.files()
  sapply(files.sources, source)
  setwd(current_dir)
  
  library(combinat)
  
  
  if(is_anova == TRUE){
    list_row_name<-rownames(stats_data)
    
  }else{
    list_row_name<-stats_data
  }
  if(length(groupsNames)!=0){
    name_permutation<- combn(groupsNames, 2,simplify = FALSE)
    
  }else{
    stop("hereeeeeeeeeee")
  }
  
  
  # i need to change the order of the names to something const to both 
  #i need to find in rearnage string the names as they are found and return them 
  for(i in 1:length(list_row_name)){
    
    list_row_name[i]<-reagrange_string(list_row_name[i],path_to_scripts,name_permutation)
    
  }
  
  if(is_anova == TRUE){
    rownames(stats_data)<-list_row_name
    
  }else{
    stats_data<-list_row_name
  }
  return(stats_data)
}
