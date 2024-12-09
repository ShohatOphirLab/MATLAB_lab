netWorkParamsCalcuPerSpcificGroup<-function(dir,the_i_pop,path_to_scripts,lengthParams,numberParams,xlsxFile,num_of_pop,scaled){
  
  current_dir =dir
  setwd(path_to_scripts)
  files.sources = list.files()
  sapply(files.sources, source)
  setwd(current_dir)
  
  
  if(!(basename(dir) == colnames(lengthParams)[the_i_pop])){
    
    warning("something is wrong with the scripts that per spcific group and something iis wrong with the names and the order ans the logic")
  }
  
  
  
  
  
  densL<-c()
  varience<-c()
  modL<-c()
  sdL<-c()
  strL<-c()
  betL<-c()
  densN<-c()
  modN<-c()
  sdN<-c()
  strN<-c()
  betN<-c()
  
  allData <- read.xlsx(xlsxFile)
  numberOfMovies<-c()
  #parametrs name
  paramsNames <- c("Density", "Modularity", "SD Strength", "Strength", "Betweenness Centrality")
  length<-c()
  number<-c()
  
  cur_pop <- (the_i_pop + 1) * 2
  numberOfMovies<- allData[the_i_pop, 3]
  
  #avg of flys in current group expriemnt
  num_of_flies<-getNumOfFliesAvg(allData[1:numberOfMovies[1], cur_pop],path_to_scripts)

  
  #for some reason i calculate for all and take onluy the index i want 
 for (i in 1:length(paramsNames)) {

      length[i] <- mean(unlist(lengthParams[i,the_i_pop]))
      number[i] <-mean(unlist(numberParams[i,the_i_pop]))
 
  } 
  
  
  
  my_index<-the_i_pop
  Variance<-c(sd(unlist(lengthParams[1,my_index])),sd(unlist(lengthParams[2,my_index])),sd(unlist(lengthParams[3,my_index])),sd(unlist(lengthParams[4,my_index])),sd(unlist(lengthParams[5,my_index])),sd(unlist(numberParams[1,my_index])),sd(unlist(numberParams[2,my_index])),sd(unlist(numberParams[3,my_index])),sd(unlist(numberParams[4,my_index])),sd(unlist(numberParams[5,my_index])))
  

  
  densL<-as.numeric(as.data.frame((length[1])))
  modL<-as.numeric(as.data.frame((length[2])))
  sdL<-as.numeric(as.data.frame((length[3])))
  strL <- as.numeric(as.data.frame((length[4])))/sqrt(num_of_flies)
  betL <- as.numeric(as.data.frame((length[5])))/sqrt(num_of_flies)
  densN <- as.numeric(as.data.frame((number[1])))
  modN <- as.numeric(as.data.frame((number[2])))
  sdN <- as.numeric(as.data.frame((number[3])))
  strN <- as.numeric(as.data.frame((number[4])))/sqrt(num_of_flies)
  betN <- as.numeric(as.data.frame((number[5])))/sqrt(num_of_flies)
  
  
  #the reason i do for each population the get their valus and write it in their dir
  setwd(current_dir)
  file<-c("density(LOI)","modularity(LOI)","sd strength(LOI)","strength(LOI)","betweens(LOI)","density(NOI)","modularity(NOI)","sd strength(NOI)","strength(NOI)","betweens(NOI)")  
  value<-c(densL,modL,sdL,strL,betL,densN,modN,sdN,strN,betN)
  network.df<-data.frame(file,value,Variance)
  if(scaled == TRUE){
    write.csv(network.df, 'ScalednetworkParams.csv', row.names = F)
    
  }else{
    write.csv(network.df, 'networkParams.csv', row.names = F)
    
  }
  
}

