

require(R.matlab)
library(base)
library(openxlsx)
library(igraph)
library(ggplot2)
library(cowplot)
library(ggpubr)
library(ggsignif)
library(nortest)
library(fmsb)
library(argparser, quietly=TRUE)
library(stringr)
library("readxl")

the_path = 'D:/all_data_of_shir/shir_ben_shushan/Shir Ben Shaanan/old/Grouped vs Single/Grouped'

setwd(the_path)
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
  
  ave_kinetic.df<-as.data.frame(read.csv('averages per movie.csv'))
  ave_classifiers.df<-as.data.frame(read.csv('all_classifier_averages.csv'))
  ave_bl.df<-as.data.frame(read.csv('bout_length_scores.csv'))
  ave_frq.df<-as.data.frame(read.csv('frequency_scores.csv'))
  network.df<-as.data.frame(read.csv('network.csv'))
  
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

  write.csv(all.df, 'combined per movie.csv',row.names = F)
  write.csv(new.df, 'averages per condition.csv', row.names = F)
  

