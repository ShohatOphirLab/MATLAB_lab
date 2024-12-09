scaleing<-function(csv_file_name,dir,path_to_scripts){
  
  current_dir =getwd()
  setwd(path_to_scripts)
  files.sources = list.files()
  sapply(files.sources, source)
  setwd(current_dir)
  

  temp<-data.frame()
  #setwd(dir[1,1])
  comb<-as.data.frame(read.csv(paste(dir[1,1],"/",csv_file_name,sep = "")))
  num_of_movies<-length(list.dirs(path=dir[1,1], recursive=F ))
  v <- rep(tools::file_path_sans_ext(basename(((dir[1,1])))), num_of_movies)
  library("dplyr") # or library("tidyverse")
  comb <- cbind(id = v,comb)
  for(i in 2:num_of_pop){
    #setwd(dir[i,1])
    temp<-as.data.frame(read.csv(paste(dir[i,1],"/",csv_file_name,sep = "")))
    num_of_movies<-length(list.dirs(path=dir[i,1], recursive=F ))
    v <- rep(tools::file_path_sans_ext(basename(((dir[i,1])))), num_of_movies)
    temp <- cbind(id = v,temp)
    comb<-bind_rows(comb,temp)
  }
  
  comb$id <- as.factor(comb$id)
  library(dplyr)
  
  scaled<-comb %>%
    mutate_if(is.numeric, scale)
  
  
  splited<-split(scaled, scaled$id)
  
  
  for(i in 1:num_of_pop){
    setwd(dir[i,1])
    bb<-as.data.frame(splited[[basename(dir[i,1])]])
    bb<-select(bb, -ends_with("id"))
    write.csv(bb, csv_file_name, row.names = F)
  }
  
  
}
