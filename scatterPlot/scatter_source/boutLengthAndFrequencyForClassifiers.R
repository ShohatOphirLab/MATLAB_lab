boutLengthAndFrequencyForClassifiers<-function(dir,path_to_scripts){
  current_dir =dir
  setwd(path_to_scripts)
  files.sources = list.files()
  sapply(files.sources, source)
  setwd(current_dir)
  library(dplyr)
  str1 = "frequency"
  str2 = "bout length"
  dir<-list.dirs(recursive = F)
  print(dir)
  ave_bl<-data.frame()
  total_bl<-data.frame()
  total_all<-data.frame()
  per_movie_freq<-data.frame()
  total_freq_all<-data.frame()
  ave_bl_fly<-data.frame()
  first<-TRUE
  for(k in 1:length(dir)){
    curr.dir<-(paste0(dir[k],'/')) 
    print(k)
    print(curr.dir)
    files<-list.files(path=paste0(curr.dir), pattern = 'scores')
    first<-TRUE
    total.df<-data.frame()
    total_freq.df<-data.frame()
    for(j in 1:length(files)){
      file<-readMat(paste0(curr.dir,'/',files[j])) #read each mat file
      #i is the number of flys
      for (i in 1:length(file$allScores[[4]])){
        #gives the value in each frame if there was movement or not (0 or 1)
        tmp.df <- data.frame(dir=dir[k], files=files[j], fly=i, value=as.numeric(file$allScores[[4]][[i]][[1]])) # convert format of data for each fly
        
        ### get bout length for each fly ###
        counter<-0
        bl_vector<-data.frame(0)
        first_bout<-0
        for (m in 1:length(tmp.df$value)){ # get bout length of one fly
          if ((tmp.df$value[m]==1)&(first_bout==0)){
            counter<-1
            #there is the first bout?
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
        #ave_bl_fly<-mean(bl_vector)
        #frq calculated by the number of accurance that is happening
        ave_bl<-rbind(ave_bl,as.numeric(colMeans(bl_vector, na.rm = T, dims = 1))) # combine average bout lengths of all flies per movie
        #calculating the number of instans that had movemnt (e.g 21 accurance divideing by 27001 frames)
        #multiply with 30 beacuse we wanted to change from perframe to seconds
        per_movie_freq<-rbind(per_movie_freq, as.numeric(lengths(bl_vector)/((length(tmp.df$value))/30))) # combine frequency of all flies
      }
      ave_per_movie<-colMeans(ave_bl, na.rm = T, dims = 1)
      ave_freq_movie<-colMeans(per_movie_freq, na.rm = T, dims = 1)
      #I THINK I FIXES THAT PROBLEM WITH INIT THE BL VECTOR TO DATAFRAME OF ZEROS AND ALSO CHANGE FROM MEAN TO COL MEAN BECAUSE THE DF WONT ALLOW TO DO MEAN (I THIINK BECASUE OF THE TITLE OF THE DF)
      if (is.numeric(colMeans(ave_bl))==FALSE){
        ave_per_movie<-data.frame(0)
      }
      total_bl <- data.frame(dir=dir[k], files=paste(str2,files[j]), value=as.numeric(ave_per_movie)) # data frame per file
      total_freq <- data.frame(dir=dir[k], files=paste(str1,files[j]), value=as.numeric(ave_freq_movie)) # frequency per file
      if(j==1){
        #total.df<-data.frame(dir=dir[k], file=files[j], value=mean(row_ave.df$value)) #make average per movie
        total.df <- data.frame(dir=dir[k], files=paste(str2,files[j]), value=as.numeric(ave_per_movie)) # data frame per file
        total_freq.df <- data.frame(dir=dir[k], files=paste(str1,files[j]), value=as.numeric(ave_freq_movie)) # frequency per file
        
      }
      else{
        library(dplyr)
        total.df<-bind_cols(total.df, total_bl) #add to averages of all files per directory
        total_freq.df<-bind_cols(total_freq.df, total_freq) #frequency of all files per directory
        
      }
    }
    ### add average bout length to data frame of averages per movie ###
    if(k==1){
      total_all<-total.df
      total_freq_all<-total_freq.df
    }
    else{
      total_all<-bind_rows(total_all,total.df)
      total_freq_all<-bind_rows(total_freq_all,total_freq.df)
      
    }
    
  }
  write.csv(total_all, 'bout_length_scores.csv', row.names = F)
  write.csv(total_freq_all, 'frequency_scores.csv', row.names = F)
  
  # for hadar
  #writeMat(con = "bout_length.mat", myTable_bout = total_all)
  #writeMat(con = "frequency_scores.mat", myTable_freq = total_freq_all)
}
