AnovaToDataFrame<-function(currentName,Stat,path_to_scripts,groupsNames){
  
  #library(gtools)
  current_dir =getwd()
  setwd(path_to_scripts)
  files.sources = list.files()
  sapply(files.sources, source)
  setwd(current_dir)
  
  stats_data<-as.data.frame(Stat[[1]][["names"]]) 
  
  seprated_names<-(strsplit(rownames(stats_data), '\\-'))
  
  #trying to make the same order all the time
  for(i in 1:length(rownames(stats_data))){
    seprated_names[[i]]<-seprated_names[[i]][order(nchar(seprated_names[[i]]), seprated_names[[i]])]
    seprated_names[[i]][1]<-gsub(" ", "",  seprated_names[[i]][1])
    seprated_names[[i]][2]<- gsub(" ", "",  seprated_names[[i]][2])
  }  
  
 # stats_data<-change_row_names(stats_data,path_to_scripts,groupsNames,TRUE)
  rownames(stats_data)<-((sapply((seprated_names), 
                                 function(x)paste(x,collapse = '-'))))
  list_rowname<-rownames(stats_data)
  data_frame_p_adj<-data.frame(name =currentName,t(stats_data[,-1:-3]),test=Stat[[2]])
  colnames(data_frame_p_adj)<-c("name",list_rowname,"test")
  data_frame_p_adj$pVal<-Stat[[3]]
  return(data_frame_p_adj)
  
}