computeStat<-function(csv_file_name,dir,groupsNames,path_to_scripts){
  library(dplyr)
  current_dir =getwd()
  setwd(path_to_scripts)
  files.sources = list.files()
  sapply(files.sources, source)
  setwd(current_dir)
  
  
  #largest_number_of_movies(dir,num_of_pop,path_to_scripts)
  
  datalist = list()
  df1<-as.data.frame(read.csv(paste(dir[1,1],"/",csv_file_name,sep = "")))
  first<-df1[ , grepl( "value" , names( df1 ) ) ]
  first<- unname(first)
  
  first$id <-as.factor(groupsNames[1])
  
  
  for (i in 2:num_of_pop){
    df_temp<-as.data.frame(read.csv(paste(dir[i,1],"/",csv_file_name,sep = "")))
    df_temp<-df_temp[ , grepl( "value" , names( df_temp ) ) ]
    df_temp<- unname(df_temp)
    df_temp$id <-as.factor(groupsNames[i])
    
    #first <-rbind(first,df_temp)
    
    first<-rbind(first,df_temp)
  }
  
  
  
  names_all<-df1[ , grepl( "file" , names( df1 ) ) ]
  all_name<-as.character(names_all[1,1:ncol(names_all)])
  featuers_comb<-c()
  
  
  for(i in 1:num_of_pop){
    Data <- subset(first, id %in% groupsNames[i])
    
    temp<-NULL
    for(feature in 1:ncol(names_all)){
      temp<-rbind(temp,as.list(Data[feature]))
    }
    
    featuers_comb<-cbind(featuers_comb,temp)
    
  }
  
  
  rownames(featuers_comb)<-all_name
  
  
  
  for(i in 1:ncol(names_all)){
    allStat<-statProcess(groupsNames,featuers_comb[i,],path_to_scripts)
    
    #i need to write this to dataframe
    if(num_of_pop<3){
      print(all_name[i])
      print(allStat[[1]]$p.value)
      dat <- data.frame(name =all_name[i],pVal = allStat[[1]]$p.value)
      dat$test <- allStat[[2]]  # maybe you want to keep track of which iteration produced it?
      datalist[[i]] <- dat # add it to your list
      
    }
    else{
      if(allStat[[2]]=="Dunn"){
        datalist[[i]]<-DunnTstDataFrame(all_name[i],allStat,path_to_scripts,groupsNames)
        
      }
      else{
        datalist[[i]]<-AnovaToDataFrame(all_name[i],allStat,path_to_scripts,groupsNames)
      }
      
    }
    
  }
  allData = do.call(bind_rows, datalist)
  allData
  group_name_dir = tools::file_path_sans_ext(dirname((dir[1,1])))
  setwd(group_name_dir)
  
  csv_file_name <-paste("stats",csv_file_name)
  write.csv(allData, csv_file_name, row.names = F)
  
  
}
