netWorkParamsCalcuPerGroup<-function(dir,the_i_pop,path_to_scripts,lengthParams,numberParams,xlsxFile,num_of_pop,scaled){
  
  current_dir =dir
  setwd(path_to_scripts)
  files.sources = list.files()
  sapply(files.sources, source)
  setwd(current_dir)
  
  
  
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
  #6 is because there is 5 paramters
  length<-as.data.frame(lapply(structure(.Data=1:6,.Names=1:6),function(x) numeric(num_of_pop)))
  number<-as.data.frame(lapply(structure(.Data=1:6,.Names=1:6),function(x) numeric(num_of_pop)))
  
  cur_pop <- (the_i_pop + 1) * 2
  numberOfMovies<- allData[the_i_pop, 3]
  
  #avg of flys in current group expriemnt
  num_of_flies<-getNumOfFliesAvg(allData[1:numberOfMovies[1], cur_pop],path_to_scripts)
  for (i in 1:num_of_pop){ 
    lengthAvg<-paste0("lengthAvg",as.character(i))
    length[i,1]<-lengthAvg
  }
  for (i in 1:num_of_pop){ 
    numberAvg<-paste0("numberAvg",as.character(i))
    number[i,1]<-numberAvg
  }
  

  for (i in 1:length(paramsNames)) {
    for(j in 1:num_of_pop){
      length[j,i+1] <- mean(unlist(lengthParams[i,j]))
      number[j,i+1] <-mean(unlist(numberParams[i,j]))
      
    }
    
  }
  
  
  
  my_index<-the_i_pop
  Variance<-c(sd(unlist(lengthParams[1,my_index])),sd(unlist(lengthParams[2,my_index])),sd(unlist(lengthParams[3,my_index])),sd(unlist(lengthParams[4,my_index])),sd(unlist(lengthParams[5,my_index])),sd(unlist(numberParams[1,my_index])),sd(unlist(numberParams[2,my_index])),sd(unlist(numberParams[3,my_index])),sd(unlist(numberParams[4,my_index])),sd(unlist(numberParams[5,my_index])))
  
  densL1<-c()
  modL1<-c()
  sdL1<-c()
  strL1<-c()
  betL1<-c()
  densN1<-c()
  modN1<-c()
  sdN1<-c()
  strN1<-c()
  betN1<-c()
  
  densL1<-as.numeric(as.data.frame(t(length[2])))
  modL1<-as.numeric(as.data.frame(t(length[3])))
  sdL1<-as.numeric(as.data.frame(t(length[4])))
  strL1 <- as.numeric(as.data.frame(t(length[5])))
  betL1 <- as.numeric(as.data.frame(t(length[6])))
  densN1 <- as.numeric(as.data.frame(t(number[2])))
  modN1 <- as.numeric(as.data.frame(t(number[3])))
  sdN1 <- as.numeric(as.data.frame(t(number[4])))
  strN1 <- as.numeric(as.data.frame(t(number[5])))
  betN1 <- as.numeric(as.data.frame(t(number[6])))
  
  
  densL<-densL1[my_index]
  modL<-modL1[my_index]
  
  sdL<-sdL1[my_index]
  
  strL<-strL1[my_index]/sqrt(num_of_flies)
  
  
  betL<-betL1[my_index]/sqrt(num_of_flies)
  
  
  densN<-densN1[my_index]
  
  
  modN<-modN1[my_index]
  
  
  sdN<-sdN1[my_index]
  
  
  strN<-strN1[my_index]/sqrt(num_of_flies)
  
  
  betN<-betN1[my_index]/sqrt(num_of_flies)
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

