require(R.matlab)
library(base)
setwd('F:/statistic_test/MalesGrouped') # where is the data folders

dir<-list.dirs(recursive = F)
print(dir)
ave_bl<-data.frame()
total_bl<-data.frame()
total_all<-data.frame()
per_fly_freq<-data.frame()
total_freq_all<-data.frame()
ave_bl_fly<-data.frame()
first<-T
for(k in 1:length(dir)){
  curr.dir<-(paste0(dir[k],'/')) 
  print(k)
  print(curr.dir)
  files<-list.files(path=paste0(curr.dir), pattern = 'scores')
  first<-T
  total.df<-data.frame()
  total_freq.df<-data.frame()
  for(j in 1:length(files)){
    file<-readMat(paste0(curr.dir,'/',files[j])) #read each mat file
    ave_bl<-data.frame()
    for (i in 1:length(file$allScores[[4]])){
      tmp.df <- data.frame(dir=dir[k], files=files[j], fly=i, value=as.numeric(file$allScores[[4]][[i]][[1]])) # convert format of data for each fly
      
      ### get bout length for each fly ###
      counter<-0
      bl_vector<-data.frame()
      first_bout<-0
      for (m in 1:length(tmp.df$value)){ # get bout length of one fly
        if ((tmp.df$value[m]==1)&(first_bout==0)){
          counter<-1
          first_bout<-1
        }
        else if (tmp.df$value[m]==1) {
          counter<-counter+1
        }
        else if ((tmp.df$value[m]==0)&(first_bout==1)) {
          if (counter>10){ # minimum length of bout in frames
            bl_vector<-rbind(bl_vector, counter) # add all bouts to one data frame for one fly
            counter<-0
          }
        }
      }
      ave_bl_fly<-mean(bl_vector)
      ave_bl<-rbind(ave_bl,as.numeric(colMeans(bl_vector, na.rm = T, dims = 1))) # combine average bout lengths of all flies per movie
      per_fly_freq<-rbind(per_fly_freq, as.numeric(lengths(bl_vector)/length(tmp.df$value))) # combine frequency of all flies
    }
    ave_per_movie<-colMeans(ave_bl, na.rm = T, dims = 1)
    ave_freq_movie<-colMeans(per_fly_freq, na.rm = T, dims = 1)
    if (is.numeric(ave_bl)==F){
      ave_per_movie<-data.frame(0)
    }
    total_bl <- data.frame(dir=dir[k], files=files[j], value=as.numeric(ave_per_movie)) # data frame per file
    total_freq <- data.frame(dir=dir[k], files=files[j], value=as.numeric(ave_freq_movie)) # frequency per file
    total.df<-rbind(total.df, total_bl) #add to averages of all files per directory
    total_freq.df<-rbind(total_freq.df, total_freq) #frequency of all files per directory
  }
  ### add average bout length to data frame of averages per movie ###
  if (is.numeric(total_all$value)==F){
    total_all<-total.df
    total_freq_all<-total_freq.df
  }
  else{
    total_all<-cbind(total_all, total.df)
    total_freq_all<-cbind(total_freq_all, total_freq.df)
  }
  
}
warnings()
write.csv(total_all, 'bout_length_scores.csv', row.names = F)
write.csv(total_freq_all, 'frequency_scores.csv', row.names = F)
