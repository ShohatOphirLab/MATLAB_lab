dir<-"D:/iska/WT_starvation_10_15flies_10min_211222/10flies_16h"
setwd(dir)
library(R.matlab)
library(dplyr)
  current_dir =dir
  files.sources = list.files()
  sapply(files.sources, source)
  setwd(current_dir)
  
  dir<-list.dirs(recursive = F)
  print(dir)
  
  col_ave.df<-data.frame()
  row_ave.df<- data.frame()
  final.df<-data.frame()
  #included_list.df<-as.data.frame(read.csv2('included.csv', header = F, colClasses = "character"))  
  #included<-as.character(included_list.df$V1)
  
  for(k in 1:length(dir)){
    curr.dir<-(paste0(dir[k],'/perframe/')) 
    print(k)
    print(curr.dir)
    files<-list.files(path=paste0(curr.dir))
    index<-0
    for(j in 1:length(files)){ 
      
      row_ave.df<-data.frame()
      index<-index+1
      df <- readMat(paste0(curr.dir, '/', files[j])) # read each MAT file
      #print(j)
      
      for(i in 1:length(df$data)){
        tmp.df<- data.frame(dir=dir[k], file=files[j], fly=i, value=as.numeric(df$data[[i]][[1]])) #convert to data frame
        tmp_ave.df<-  data.frame(dir=dir[k], file=files[j], fly=i, value=mean(tmp.df$value)) #make average per fly
        row_ave.df<- rbind(row_ave.df, tmp_ave.df) #add average of each fly to others in the same movie
      }
      tmp_movie_ave.df<-data.frame(dir=dir[k], file=files[j], value=mean(row_ave.df$value))
      
      if (index==1){
        col.df<- row_ave.df
      }else{
        col.df<- bind_cols(col.df, row_ave.df)
      }
      
    }
    if (k==1){
      all_col.df<-col.df
    }else{
      all_col.df<-bind_rows(all_col.df, col.df)
    }
    
    #ordered_ave<- col.df[order(col.df$file),]
    #final.df<-rbind(final.df, ordered_ave)
  }
  write.csv(all_col.df, 'averages per fly per movie.csv', row.names=F)
  
  
