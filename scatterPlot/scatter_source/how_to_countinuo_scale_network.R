creatNetwork2popforscatter<-function(group_name,dir,the_i_pop,path_to_scripts){
  
  current_dir =dir
  setwd(path_to_scripts)
  files.sources = list.files()
  sapply(files.sources, source)
  setwd(current_dir)
  
  #parametrs name
  paramsNames <- c("Density", "Modularity", "SD Strength", "Strength", "Betweenness Centrality")
  #6 is because there is 5 paramters
  length<-as.data.frame(lapply(structure(.Data=1:6,.Names=1:6),function(x) numeric(num_of_pop)))
  number<-as.data.frame(lapply(structure(.Data=1:6,.Names=1:6),function(x) numeric(num_of_pop)))
  
  cur_pop <- (the_i_pop + 1) * 2
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
  
  #unlisting all so we could scale
  num<-apply(numberParams, 1, unlist)
  lengh<-apply(lengthParams, 1, unlist)
  
  for (j in 1:length(paramsNames)){
    scaled_num<-scale(as.numeric(unlist(num[j])))
    scaled_len<-scale(as.numeric(unlist(lengh[j])))
    #if it is for bc or stength the after scaleing need to be diffrent
    if(j == 4 || j == 5 ){
      #creat list of everythiing to sub pop of number of flys
      spl_num <- split(scaled_num, ceiling(seq_along(scaled_num)/num_of_flies))
      spl_num<-unname(spl_num)
      clist<-c()
      len_of_all_pop<-length(spl_num)
      for (i in 1:len_of_all_pop){
        clist<-cbind(clist,c(spl_num[i]))
      }
      num_of_sub_pop <-len_of_all_pop/num_of_pop
      splited<-split(clist, ceiling(seq_along(clist)/num_of_sub_pop))
      splited<-unname(splited)
      for(m in 1:length(splited)){
        numberParams[j,m]<-splited[m]
        
      }
      ####################### for len
      
      spl_len <- split(scaled_len, ceiling(seq_along(scaled_len)/num_of_flies))
      spl_len<-unname(spl_len)
      clist<-c()
      len_of_all_pop<-length(spl_len)
      for (i in 1:len_of_all_pop){
        clist<-cbind(clist,c(spl_len[i]))
      }
      num_of_sub_pop <-len_of_all_pop/num_of_pop
      splited<-split(clist, ceiling(seq_along(clist)/num_of_sub_pop))
      splited<-unname(splited)
      for(m in 1:length(splited)){
        lengthParams[j,m]<-splited[m]
      }
    }else{
      subPopLen<-(length(scaled_num))/num_of_pop
      for(m in 1:num_of_pop){
        splited<-split(scaled_num, ceiling(seq_along(scaled_num)/subPopLen))
        splited<-unname(splited)
        numberParams[j,m]<-as.list(splited[m])
      }
      
      subPopLen<-(length(scaled_len))/num_of_pop
      for(m in 1:num_of_pop){
        splited<-split(scaled_len, ceiling(seq_along(scaled_len)/subPopLen))
        splited<-unname(splited)
        lengthParams[j,m]<-as.list(splited[m])
      }
    }
    
    
  }
  
  for (i in 1:length(paramsNames)) {
    for(j in 1:num_of_pop){
      length[j,i+1] <- mean(unlist(lengthParams[i,j]))
      number[j,i+1] <-mean(unlist(numberParams[i,j]))
      
    }
    
  }
  
  
  
  index_name <- function(input_name,groupsNames){
    
    for (i in 1:length(groupsNames)){
      if(input_name == groupsNames[i]){
        return (i)
      }
    }
  }
  
  my_index = index_name(group_name,groupsNames)
  varience<<-c(sd(unlist(lengthParams[1,my_index])),sd(unlist(lengthParams[2,my_index])),sd(unlist(lengthParams[3,my_index])),sd(unlist(lengthParams[4,my_index])),sd(unlist(lengthParams[5,my_index])),sd(unlist(numberParams[1,my_index])),sd(unlist(numberParams[2,my_index])),sd(unlist(numberParams[3,my_index])),sd(unlist(numberParams[4,my_index])),sd(unlist(numberParams[5,my_index])))
  
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
  
  
  densL<<-densL1[my_index]
  modL<<-modL1[my_index]
  
  sdL<<-sdL1[my_index]
  
  strL<<-strL1[my_index]/sqrt(number_of_flies)
  
  
  betL<<-betL1[my_index]/sqrt(number_of_flies)
  
  
  densN<<-densN1[my_index]
  
  
  modN<<-modN1[my_index]
  
  
  sdN<<-sdN1[my_index]
  
  
  strN<<-strN1[my_index]/sqrt(number_of_flies)
  
  
  betN<<-betN1[my_index]/sqrt(number_of_flies)
  #the reason i do for each population the get their valus and write it in their dir
  setwd(current_dir)
  names<-c("density(LOI)","modularity(LOI)","sd strength(LOI)","strength(LOI)","betweens(LOI)","density(NOI)","modularity(NOI)","sd strength(NOI)","strength(NOI)","betweens(NOI)")  
  values<-c(densL,modL,sdL,strL,betL,densN,modN,sdN,strN,betN)
  network.df<-data.frame(names,values,varience)
  View(network.df)
  colnames(network.df) <- c("file", "value","Variance")
  write.csv(network.df, 'network.csv', row.names = F)
  
}

