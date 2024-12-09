


#calculating the params of the group with calculateNetworksParams for length and number groups
require(R.matlab)
library(base)
library(openxlsx)
library(igraph)
library(ggplot2)
library(cowplot)
library(ggpubr)
library(ggsignif)
library(nortest)
library(fmsb)
library(argparser, quietly=TRUE)
library(stringr)
library("readxl")
calculateNetworksParams <- function(net, folderPath, graphName, vertexSize,fileName) {
  # all
  print(fileName)
  vertexNumber = gorder(net)
  par(mfrow=c(1,1), mar=c(1,1,1,1))
  l <- layout_in_circle(net)
  
  # density
  density <- sum(E(net)$weight) / (vertexNumber * (vertexNumber - 1) / 2)
  
  
  # modularity
  #This function tries to find densely connected subgraphs
  wtc <- cluster_walktrap(net)
  modularity <- modularity(wtc)
  
  
  # strength std
  sdStrength <- sd(strength(net, weights = E(net)$weight))
  
  
  #individual
  
  # strength
  #Summing up the edge weights of the adjacent edges for each vertex.
  print(net)
  strength <- strength(net, weights = E(net)$weight)
  
  
  
  # betweenness centality 
  betweenness <- betweenness(net, v = V(net), directed = FALSE, weights = E(net)$weight)
  
  return(list(density, modularity, sdStrength, strength, betweenness))
}
calculateGroupParams <- function(fileNames, maxNumberOfInteration) {
  density <- vector()
  modularity <- vector()
  sdStrength <- vector()
  strength <- vector()
  betweenness <- vector()
  #number of files we want
  for (i in 1:length(fileNames)) {
    #when debuging see what is inside matfile
    matFile <- fileNames[i]
    mat <- scan(toString(matFile))
    #because the matrix is smetric and there is 100 value so it is 10
    numCol <- sqrt(length(mat))
    #all this just to transform to mat format?
    mat <- matrix(mat, ncol = numCol, byrow = TRUE)
    #creat the net itself
    net <- graph_from_adjacency_matrix(mat, mode = "undirected", weighted = TRUE)
    folderPath <- dirname(toString(matFile))
    #numberParams
    if (maxNumberOfInteration > 0) {
      #normalization to the number of the max interaction to the weights of the network this is not happning in lengthparams
      E(net)$weight <- E(net)$weight / maxNumberOfInteration
      E(net)$width <- E(net)$weight*7
      #the 7 and 25?? is for the vertex size for visualization beacuse the lenght value are smaller than the number values
      cur <- calculateNetworksParams(net, folderPath, "number of interaction", 7,fileNames[i])
    } else {
      #which means length of interaction
      E(net)$width <- E(net)$weight*10
      
      cur <- calculateNetworksParams(net, folderPath, "length of interction", 25,fileNames[i])
    }
    #for each of the movies
    density <- c(cur[1], density)
    modularity <- c(cur[2], modularity)
    sdStrength <- c(cur[3], sdStrength)
    strength <- c(cur[4], strength)
    betweenness <- c(cur[5], betweenness)
  }
  
  return(list(density, modularity, sdStrength, strength, betweenness))
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
group_name<-c()
number_of_pop =2
number_of_features = 11
number_of_flies= 10
number_of_movies <-c()
current_path = 'D:/all_data_of_shir/shir_ben_shushan/Shir Ben Shaanan/old/Grouped vs Single/Single'

  setwd(current_path)
  group_name = "Single"
  group_name_dir = tools::file_path_sans_ext(dirname((current_path)))
  setwd(group_name_dir)
  
  #where we choosing the files we want for analysis
  #all data is the data from the exel in the first sheet
  allData <- read.xlsx("expData_0_to_27000.xlsx")
  library(openxlsx)
  allColorData <- as.data.frame(read.xlsx("D:/test/color.xlsx"))
  num_of_pop<<-nrow(allColorData)
  
  lengthParams <- c()
  numberParams <- c()
  numberOfMovies<-c()
  for (i in 1:allData$Number.of.groups[1]) {
    #it is depened on the poisiton of the colom in the execl so we can get the length and number files
    cur <- (i + 1) * 2
    numberOfMovies[i]<- allData[i, 3]
    #the params are density, modularity, sdStrength, strength, betweenness
    lengthParams <- cbind(lengthParams, calculateGroupParams(allData[1:numberOfMovies[i], cur], 0))
    numberParams <- cbind(numberParams, calculateGroupParams(allData[1:numberOfMovies[i], cur + 1], allData$Max.number.of.interaction[1]))
  }
  
  
  #parametrs name
  paramsNames <- c("Density", "Modularity", "SD Strength", "Strength", "Betweenness Centrality")
  #light or dark
  groupsNames <- as.character(na.omit(allData$Groups.names))
  length<-as.data.frame(lapply(structure(.Data=1:6,.Names=1:6),function(x) numeric(num_of_pop)))
  number<-as.data.frame(lapply(structure(.Data=1:6,.Names=1:6),function(x) numeric(num_of_pop)))
  
  for (i in 1:num_of_pop){ 
    lengthAvg<-paste0("lengthAvg",as.character(i))
    length[i,1]<-lengthAvg
  }
  for (i in 1:num_of_pop){ 
    numberAvg<-paste0("numberAvg",as.character(i))
    number[i,1]<-numberAvg
  }
  
  
  
  
  num_of_pop =2
  num<-apply(numberParams, 1, unlist)
  lengh<-apply(lengthParams, 1, unlist)
  for (j in 1:5){
    scaled_num<-scale(as.numeric(unlist(num[j])))
    scaled_len<-scale(as.numeric(unlist(lengh[j])))
    
    for(m in 1:num_of_pop){
      start =1
      end = 
      if(m!=1) {
        start = (length(scaled_num)/num_of_pop)*(m-1)
        
      }
      numberParams[j,m]<-list(scaled_num[(start+1):((length(scaled_num)/num_of_pop)*m)])
    }
    
    for(m in 1:num_of_pop){
      start =1
      if(m!=1) {
        start = (length(scaled_len)/num_of_pop)*(m-1)
      }
      lengthParams[j,m]<-list(scaled_len[(start+1):((length(scaled_len)/num_of_pop)*m)])
    }
    
  }



  for (i in 1:length(paramsNames)) {
    #the whole row i of lengthParams/numberParams
    #calculating the mean of each population
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
  
  
  
  
  #density,mudilarity,sd strength,strength,bewtweenss SE
  varience<<-c(sd(unlist(lengthParams[1,my_index])),sd(unlist(lengthParams[2,my_index])),sd(unlist(lengthParams[3,my_index])),sd(unlist(lengthParams[4,my_index])),sd(unlist(lengthParams[5,my_index])),sd(unlist(numberParams[1,my_index])),sd(unlist(numberParams[2,my_index])),sd(unlist(numberParams[3,my_index])),sd(unlist(numberParams[4,my_index])),sd(unlist(numberParams[5,my_index])))
  
  
  
  
  
  densL<-as.numeric(as.data.frame(t(length[2])))
  modL<-as.numeric(as.data.frame(t(length[3])))
  sdL<-as.numeric(as.data.frame(t(length[4])))
  strL <- as.numeric(as.data.frame(t(length[5])))
  betL <- as.numeric(as.data.frame(t(length[6])))
  densN <- as.numeric(as.data.frame(t(number[2])))
  modN <- as.numeric(as.data.frame(t(number[3])))
  sdN <- as.numeric(as.data.frame(t(number[4])))
  strN <- as.numeric(as.data.frame(t(number[5])))
  betN <- as.numeric(as.data.frame(t(number[6])))
  
  densL<<-densL[my_index]
  
  modL<<-modL[my_index]
  
  sdL<<-sdL[my_index]
  
  strL<<-strL[my_index]/sqrt(number_of_flies)
  

  betL<<-betL[my_index]/sqrt(number_of_flies)
  
  
  densN<<-densN[my_index]
  
  
  modN<<-modN[my_index]
  
  
  sdN<<-sdN[my_index]
  
  
  strN<<-strN[my_index]/sqrt(number_of_flies)
  
  
  betN<<-betN[my_index]/sqrt(number_of_flies)
  
  
  setwd(current_path)
  names<-c("density(LOI)","modularity(LOI)","sd strength(LOI)","strength(LOI)","betweens(LOI)","density(NOI)","modularity(NOI)","sd strength(NOI)","strength(NOI)","betweens(NOI)")  
  values<-c(densL,modL,sdL,strL,betL,densN,modN,sdN,strN,betN)
  network.df<-data.frame(names,values,varience)
  colnames(network.df) <- c("file", "value","Variance")
  write.csv(network.df, 'network.csv', row.names = F)
  
  
