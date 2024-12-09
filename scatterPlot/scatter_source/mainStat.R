mainStat<-function(dir,xlsxFile,path_to_scripts,groupsNames,lengthParams,numberParams,num_of_pop){
  
  current_dir =getwd()
  setwd(path_to_scripts)
  files.sources = list.files()
  sapply(files.sources, source)
  setwd(current_dir)
  
  netWorkStats(dir[1,1],xlsxFile,path_to_scripts,groupsNames,lengthParams,numberParams)
  StatPerFeature(dir,groupsNames,path_to_scripts)
  
  
  #AFTER CERATING THE STAT WE COMBINE THEM FOR ONE CSV FILE
  
  

  
  #WRITING AND READING FROM THE FATHER DIR
  group_name_dir = tools::file_path_sans_ext(dirname((dir[1,1])))
  setwd(group_name_dir)
  net_stat_len.df<-as.data.frame(read.csv("stats of length network.csv"))
  net_stat_num.df<-as.data.frame(read.csv("stats of number network.csv"))
  ave_kinetic.df<-as.data.frame(read.csv('stats averages per movie.csv'))
  ave_classifiers.df<-as.data.frame(read.csv('stats all_classifier_averages.csv'))
  ave_bl.df<-as.data.frame(read.csv('stats bout_length_scores.csv'))
  ave_frq.df<-as.data.frame(read.csv('stats frequency_scores.csv'))
  
  all<-bind_rows(ave_kinetic.df,ave_classifiers.df,ave_bl.df,ave_frq.df,net_stat_len.df,net_stat_num.df)
  all$name<- str_replace(all$name, "scores_", "")
  all$name<- str_replace(all$name, ".mat", "")
  
  
  
  #DOING FDR TO ALL OF THEM 
  fdr<-p.adjust(all$pVal, method ="fdr", n = length(all$pVal))
  all$fdr<-fdr
  
  csv_file_name <-"all_together.csv"
  write.csv(all, csv_file_name, row.names = F)
  unlink("stats of length network.csv")
  unlink("stats of number network.csv")
  unlink('stats averages per movie.csv')
  unlink('stats all_classifier_averages.csv')
  unlink('stats bout_length_scores.csv')
  unlink('stats frequency_scores.csv')
}