ScaleNetwork<-function(numberParams,lengthParams,num_of_pop,xlsxFile){
  
  current_dir =getwd()
  setwd(path_to_scripts)
  files.sources = list.files()
  sapply(files.sources, source)
  setwd(current_dir)
  
  # I assum the number of flys are equal at every group
  numFlys<-getNumofFlys(xlsxFile,path_to_scripts,1)
  paramsNames <- c("Density", "Modularity", "SD Strength", "Strength", "Betweenness Centrality")
  #unlisting all so we could scale
  num<-apply(numberParams, 1, unlist)
  lengh<-apply(lengthParams, 1, unlist)
  
  for (j in 1:length(paramsNames)){
    scaledNum<-scale(as.numeric(unlist(num[j])))
    scaledLen<-scale(as.numeric(unlist(lengh[j])))
    #if it is for bc or stength the after scaleing need to be diffrent
    if(j == 4 || j == 5){
      #creat list of everythiing to sub pop of number of flys
      splitedNum <- split(scaledNum, ceiling(seq_along(scaledNum)/numFlys))
      splitedNum<-unname(splitedNum)
      clist<-c()
      LenAllpop<-length(splitedNum)
      for (i in 1:LenAllpop){
        clist<-cbind(clist,c(splitedNum[i]))
      }
      num_of_sub_pop <-LenAllpop/num_of_pop
      splited<-split(clist, ceiling(seq_along(clist)/num_of_sub_pop))
      splited<-unname(splited)
      for(m in 1:length(splited)){
        numberParams[j,m]<-list(splited[m])
        
      }
      ####################### 
      #LENGTH
      
      splitedLen <- split(scaledLen, ceiling(seq_along(scaledLen)/numFlys))
      splitedLen<-unname(splitedLen)
      clist<-c()
      LenAllpop<-length(splitedLen)
      for (i in 1:LenAllpop){
        clist<-cbind(clist,c(splitedLen[i]))
      }
      num_of_sub_pop <-LenAllpop/num_of_pop
      splited<-split(clist, ceiling(seq_along(clist)/num_of_sub_pop))
      splited<-unname(splited)
      for(m in 1:length(splited)){
        lengthParams[j,m]<-list(splited[m])
      }
    }else{
      subPopLen<-(length(scaledNum))/num_of_pop
      for(m in 1:num_of_pop){
        splited<-split(scaledNum, ceiling(seq_along(scaledNum)/subPopLen))
        splited<-unname(splited)
        numberParams[j,m]<-list(splited[m])
      }
      
      subPopLen<-(length(scaledLen))/num_of_pop
      for(m in 1:num_of_pop){
        splited<-split(scaledLen, ceiling(seq_along(scaledLen)/subPopLen))
        splited<-unname(splited)
        lengthParams[j,m]<-list(splited[m])
      }
    }
    
    
  }
  return(list(lengthParams,numberParams))
}