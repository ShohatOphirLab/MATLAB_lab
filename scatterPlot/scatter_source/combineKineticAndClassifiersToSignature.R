combineKineticAndClassifiersToSignature<-function(dir,path_to_scripts){
  
  current_dir =dir
  print(current_dir)
  setwd(path_to_scripts)
  files.sources = list.files()
  sapply(files.sources, source)
  setwd(current_dir)
  
  all.df<-data.frame()
  bl_frq.df<-data.frame()
  all_bl.df<-data.frame()
  all_freq.df<-data.frame()
  ave_kinetic.df<-data.frame()
  network.df<-data.frame()
  ave_frq.df<-data.frame()
  ave_classifiers.df<-data.frame()
  ave_bl.df<-data.frame()
  avg_of_bl.df<-data.frame()
  avg_of_frq.df<-data.frame()
  tmp_new.df<-data.frame()
  
  ave_kinetic.df<-as.data.frame(read.csv(paste(current_dir,"/",'averages per movie.csv',sep="")))
  ave_classifiers.df<-as.data.frame(read.csv(paste(current_dir,"/",'all_classifier_averages.csv',sep="")))
  ave_bl.df<-as.data.frame(read.csv(paste(current_dir,"/",'bout_length_scores.csv',sep="")))
  ave_frq.df<-as.data.frame(read.csv(paste(current_dir,"/",'frequency_scores.csv',sep="")))
  network.df<-as.data.frame(read.csv(paste(current_dir,"/",'ScalednetworkParams.csv',sep="")))
  

  
  new.df<-data.frame()
  all.df<-cbind(ave_classifiers.df, ave_kinetic.df)
  all.df<-cbind(all.df, ave_bl.df)
  all.df<-cbind(all.df, ave_frq.df)
  
  for (k in 1:length(all.df)){
    
    if (is.numeric(all.df[[k[1]]])){
      all.df[[k-1]]<-factor(all.df[[k-1]])
      print(levels(all.df[[k-1]]))
      tmp_new.df<-data.frame(file=levels(all.df[[k-1]]), value=mean(all.df[[k]]), Variance=sd(all.df[[k]])) # create average per condition
      new.df<-rbind(new.df, tmp_new.df) # make list of averages per condition of all features
    }
  }
  #network don't need to be proccesed 
  new.df<-rbind(new.df,network.df)
  
  write.csv(all.df, paste(current_dir,"/",'combined per movie.csv',sep=""),row.names = F)
  write.csv(new.df, paste(current_dir,"/",'averages per condition.csv',sep=""), row.names = F)
  
  
}
