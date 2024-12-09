averagesPerMovieByFile<-function(dir,path_to_scripts){
  current_dir =dir
  setwd(path_to_scripts)
  files.sources = list.files()
  sapply(files.sources, source)
  setwd(current_dir)
  
  dir<-list.dirs(recursive = F)
  print(dir)
  
  col_ave.df<-data.frame()
  row_ave.df<- data.frame()
  final.df<-data.frame()
  included_list.df<-as.data.frame(read.csv2('included.csv', header = F, colClasses = "character"))  
  included<-as.character(included_list.df$V1)
  
  for(k in 1:length(dir)){
    curr.dir<-(paste0(dir[k],'/perframe/')) 
    print(k)
    print(curr.dir)
    files<-list.files(path=paste0(curr.dir))
    index<-0
    for(j in 1:length(files)){ 
      if (files[j] %in% included){
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
          movie_ave.df<-data.frame(dir=dir[k], file=files[j], value=mean(row_ave.df$value)) #make average per movie
          col.df<- row_ave.df
        }else{
          col.df<- cbind(col.df, row_ave.df)
          movie_ave.df<-cbind(movie_ave.df, tmp_movie_ave.df) #combine averages per movie
        }
        row_ave.df<- NULL
      }
    }
    if (k==1){
      total_movie_ave.df<- movie_ave.df
      all_col.df<-col.df
    }else{
      total_movie_ave.df<-rbind(total_movie_ave.df, movie_ave.df)
      all_col.df<-rbind(all_col.df, col.df)
    }
    
    #ordered_ave<- col.df[order(col.df$file),]
    #final.df<-rbind(final.df, ordered_ave)
  }
  write.csv(total_movie_ave.df, 'averages per movie.csv', row.names=F)
  write.csv(all_col.df, 'averages per fly per movie.csv', row.names=F)
  
  
}
