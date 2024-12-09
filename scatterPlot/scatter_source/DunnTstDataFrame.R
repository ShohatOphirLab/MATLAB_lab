DunnTstDataFrame<-function(currentName,Stat,path_to_scripts,groupsNames){
  #install.packages("gtools")
 # library(gtools)
  current_dir =getwd()
  setwd(path_to_scripts)
  files.sources = list.files()
  sapply(files.sources, source)
  setwd(current_dir)
  
  
  dunnTst<-data.frame()
  dunnTst<-currentName
  all_names_from_comp<-Stat[[1]][["comparisons"]]
  #ll_names_from_comp<-change_row_names(all_names_from_comp,path_to_scripts,groupsNames,FALSE)
  
  
  seprated_names<-(strsplit(all_names_from_comp, '\\-'))
  
  #trying to make the same order all the time
  for(i in 1:length(all_names_from_comp)){
    seprated_names[[i]]<-seprated_names[[i]][order(nchar(seprated_names[[i]]), seprated_names[[i]])]
    seprated_names[[i]][1]<-gsub(" ", "",  seprated_names[[i]][1])
    seprated_names[[i]][2]<- gsub(" ", "",  seprated_names[[i]][2])
  }  
  
  # stats_data<-change_row_names(stats_data,path_to_scripts,groupsNames,TRUE)
  all_names_from_comp<-((sapply((seprated_names), 
                                 function(x)paste(x,collapse = '-'))))
  
  seprated_names<-paste()
  all_values_from_comp<-Stat[[1]][["P"]]
  dunnTst<-cbind(dunnTst,as.data.frame(t(all_values_from_comp)))
  colnames(dunnTst)<-c("name",all_names_from_comp)
  dunnTst$test<-Stat[[2]]
  dunnTst$pVal <-Stat[[3]]
  
  return(dunnTst)
}