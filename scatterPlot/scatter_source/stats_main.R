stats_main<-function(dir,groupsNames,path_to_scripts){
  current_dir =getwd()
  setwd(path_to_scripts)
  files.sources = list.files()
  sapply(files.sources, source)
  setwd(current_dir)
  
  Stat_sig(dir,groupsNames,path_to_scripts)
  ave_kinetic.df<-as.data.frame(read.csv('stats averages per movie.csv'))
  ave_classifiers.df<-as.data.frame(read.csv('stats all_classifier_averages.csv'))
  ave_bl.df<-as.data.frame(read.csv('stats bout_length_scores.csv'))
  ave_frq.df<-as.data.frame(read.csv('stats frequency_scores.csv'))
  
  
  group_name_dir = tools::file_path_sans_ext(dirname((dir[1,1])))
  setwd(group_name_dir)
  net_stat_len.df<-as.data.frame(read.csv("stats of length network.csv"))
  net_stat_num.df<-as.data.frame(read.csv("stats of number network.csv"))
  
  all<-rbind(ave_kinetic.df,ave_classifiers.df,ave_bl.df,ave_frq.df)
  all$name<- str_replace(all$name, "scores_", "")
  all$name<- str_replace(all$name, ".mat", "")
  
  all_net<-rbind(net_stat_len.df,net_stat_num.df)
  
  
  if(num_of_pop<3){
    fdr<-p.adjust(all$p_val, method ="fdr", n = length(all$p_val))
    all$fdr<-fdr
  }
  #I dont need to do fdr ? i need to check 
  
  csv_file_name <-"all_together.csv"
  write.csv(all, csv_file_name, row.names = F)
  
  csv_file_name_net <-"all_together_net.csv"
  write.csv(all_net, csv_file_name_net, row.names = F)
  unlink("stats of length network.csv")
  unlink("stats of number network.csv")
  
  
  
}
