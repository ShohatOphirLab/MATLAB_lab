
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
num_of_pop<-0
colors_of_groups<<-data.frame()
with_rgb = FALSE

number_of_flies= 10
num_of_movies =0
datalist<-c()
datalist_num<-c()
num_of_pop <-3


change_row_names<-function(stats_data){
  
  list_row_name<-rownames(stats_data)
  
  for(i in 1:length(list_row_name)){
    
    list_row_name[i]<-reagrange_string(list_row_name[i])
    
  }
  
  rownames(stats_data)<-list_row_name
  return(stats_data)
}


reagrange_string<-function(string){
  temp<-str_split(string, "-")
  string<-paste(temp[[1]][2],"-",temp[[1]][1])
  return(string)
}


to_dataframe<-function(p_adj_k,name){
  p_adj_k <- as.data.frame(p_adj_k)
  p_adj_k.name <- vector("character")
  p_adj_k.value <- vector("numeric")
  
  for (i in 1:ncol(p_adj_k) )
    for (j in i:length(p_adj_k) ) {
      p_adj_k.name <- c(p_adj_k.name,paste(colnames(p_adj_k[i]),"-",rownames(p_adj_k)[j]))
      p_adj_k.value <- c(p_adj_k.value,p_adj_k[j,i])
    }
  
  
  v <- order(p_adj_k.value,decreasing = F)
  data_frame<-data.frame(name =name,t(p_adj_k.value[v]))
  colnames(data_frame)<-c("name",p_adj_k.name[v])
  return (data_frame)
}

getStatisticData <- function(groupsParams, names, value, data) {
  #statistic data about each paramter density, modularity, sdStrength, strength, betweenness
  for (i in 1:length(groupsParams)) {
    shapDist <- shapiro.test(unlist(groupsParams[[i]]))
    #22.11.21 changed p value to 0.1
    if (shapDist$p.value < 0.1) {
      if (length(groupsParams) < 3) {
        stats <- wilcox.test(value~names, data)
        return(list(stats, "Wilcoxen"))
      } else {
        kruskal.test(value~names, data)
        stats <- pairwise.wilcox.test(data$value, data$names, p.adjust.method = 'fdr')
        
        return(list(stats, "Kruskal"))
      }
    }
  }
  if (length(groupsParams) < 3) {
    stats <- t.test(value~names, data)
    return(list(stats, "T Test"))
  } else {
    aov.res <- aov(value~names, data)
    summary(aov.res)
    stats <- TukeyHSD(aov.res)
    return(list(stats, "Anova"))
  }
}


statistic_to_csv_of_network<-function(groupsNames, groupsParams){
  names = c()
  for (i in 1:length(groupsNames)) {
    names = c(names, rep(groupsNames[i], length(unlist(groupsParams[i]))))
  }
  value = rapply(groupsParams, c)
  data = data.frame(names, value)
  data$names <- as.character(data$names)
  data$names <- factor(data$names, levels=unique(data$names))
  statsData <- getStatisticData(groupsParams, names, value, data)
  return(statsData)
  
}


calculateNetworksParams <- function(net, folderPath, graphName, vertexSize,fileName) {
  print(fileName)
  vertexNumber = gorder(net)
  par(mfrow=c(1,1), mar=c(1,1,1,1))
  l <- layout_in_circle(net)
  density <- sum(E(net)$weight) / (vertexNumber * (vertexNumber - 1) / 2)
  wtc <- cluster_walktrap(net)
  modularity <- modularity(wtc)
  sdStrength <- sd(strength(net, weights = E(net)$weight))
  strength <- strength(net, weights = E(net)$weight)
  betweenness <- betweenness(net, v = V(net), directed = FALSE, weights = E(net)$weight)
  
  return(list(density, modularity, sdStrength, strength, betweenness))
}

calculateGroupParams <- function(fileNames, maxNumberOfInteration) {
  density <- vector()
  modularity <- vector()
  sdStrength <- vector()
  strength <- vector()
  betweenness <- vector()
  for (i in 1:length(fileNames)) {
    matFile <- fileNames[i]
    mat <- scan(toString(matFile))
    numCol <- sqrt(length(mat))
    mat <- matrix(mat, ncol = numCol, byrow = TRUE)
    net <- graph_from_adjacency_matrix(mat, mode = "undirected", weighted = TRUE)
    folderPath <- dirname(toString(matFile))
    if (maxNumberOfInteration > 0) {
      E(net)$weight <- E(net)$weight / maxNumberOfInteration
      E(net)$width <- E(net)$weight*7
      cur <- calculateNetworksParams(net, folderPath, "number of interaction", 7,fileNames[i])
    } else {
      E(net)$width <- E(net)$weight*10
      cur <- calculateNetworksParams(net, folderPath, "length of interction", 25,fileNames[i])
    }
    density <- c(cur[1], density)
    modularity <- c(cur[2], modularity)
    sdStrength <- c(cur[3], sdStrength)
    strength <- c(cur[4], strength)
    betweenness <- c(cur[5], betweenness)
  }
  
  return(list(density, modularity, sdStrength, strength, betweenness))
}



current_path ="D:/male_And_female_2/Males/Males_Mated"
setwd(current_path)
group_name_dir = tools::file_path_sans_ext(dirname((current_path)))
setwd(group_name_dir)
allData <- read.xlsx("expData_0_to_27000.xlsx")
lengthParams <- c()
numberParams <- c()
numberOfMovies<-c()
for (i in 1:allData$Number.of.groups[1]) {
  cur <- (i + 1) * 2
  numberOfMovies[i]<- allData[i, 3]
  lengthParams <- cbind(lengthParams, calculateGroupParams(allData[1:numberOfMovies[i], cur], 0))
  numberParams <- cbind(numberParams, calculateGroupParams(allData[1:numberOfMovies[i], cur + 1], allData$Max.number.of.interaction[1]))
}

#parametrs name
paramsNames <- c("Density", "Modularity", "SD Strength", "Strength", "Betweenness Centrality")
groupsNames <- as.character(na.omit(allData$Groups.names))
#6 is because there is 5 paramters
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


num<-apply(numberParams, 1, unlist)
lengh<-apply(lengthParams, 1, unlist)
for (j in 1:5){
  scaled_num<-scale(as.numeric(unlist(num[j])))
  scaled_len<-scale(as.numeric(unlist(lengh[j])))
  
  for(m in 1:num_of_pop){
    start =1
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

#first i will do it generic and than i will implement it here
all_name<-paramsNames


for (i in 1:length(paramsNames)) {
  len_stat<-statistic_to_csv_of_network(groupsNames, lengthParams[i,])
  
  if(num_of_pop<3){
    print(all_name[i])
    print(len_stat[[1]]$p.value)
    dat <- data.frame(name =all_name[i],p_val = len_stat[[1]]$p.value)
    dat$test <- len_stat[[2]]  # maybe you want to keep track of which iteration produced it?
    datalist[[i]] <- dat # add it to your list
    
  }
  else{
    if(len_stat[[2]]=="Kruskal"){
      rownames(len_stat[[1]][["p.value"]])<-gsub("Males_", "", rownames(len_stat[[1]][["p.value"]]))
      colnames(len_stat[[1]][["p.value"]])<-gsub("Males_", "", colnames(len_stat[[1]][["p.value"]]))
      p_adj_k<-as.data.frame(len_stat[[1]][["p.value"]])
      p_adj_kk<-to_dataframe(p_adj_k,all_name[i])
      datalist[[i]]<-p_adj_kk
    }
    else{
      rownames(len_stat[[1]][["names"]])<-gsub("Males_", "", rownames(len_stat[[1]][["names"]]))
      stats_data<-as.data.frame(len_stat[[1]][["names"]]) 
      stats_data<-change_row_names(stats_data)
      list_rowname<-rownames(stats_data)
      data_frame_p_adj<-data.frame(name =all_name[i],t(stats_data[,-1:-3]))
      colnames(data_frame_p_adj)<-c("name",list_rowname)
      datalist[[i]]<-data_frame_p_adj
    }
    
  }
  len_data = do.call(rbind, datalist)
  len_data
  
  #####################################################################################
  num_stat<-statistic_to_csv_of_network(groupsNames, numberParams[i,])
  
  if(num_of_pop<3){
    print(all_name[i])
    print(num_stat[[1]]$p.value)
    dat <- data.frame(name =all_name[i],p_val = num_stat[[1]]$p.value)
    dat$test <- num_stat[[2]]  # maybe you want to keep track of which iteration produced it?
    datalist_num[[i]] <- dat # add it to your list
    
  }
  else{
    if(num_stat[[2]]=="Kruskal"){
      rownames(num_stat[[1]][["p.value"]])<-gsub("Males_", "", rownames(num_stat[[1]][["p.value"]]))
      colnames(num_stat[[1]][["p.value"]])<-gsub("Males_", "", colnames(num_stat[[1]][["p.value"]]))
      p_adj_k_num<-as.data.frame(num_stat[[1]][["p.value"]])
      p_adj_kk_num<-to_dataframe(p_adj_k_num,all_name[i])
      datalist_num[[i]]<-p_adj_kk_num
      
    }
    else{
      print(num_stat[[2]])
      print(num_stat)
      test<-num_stat
      rownames(num_stat[[1]][["names"]])<-gsub("Males_", "", rownames(num_stat[[1]][["names"]]))
      stats_data<-data.frame()
      stats_data<-as.data.frame(num_stat[[1]][["names"]]) 
      stats_data<-change_row_names(stats_data)
      list_rowname_num<-rownames(stats_data)
      data_frame_p_adj<-data.frame()
      data_frame_p_adj<-data.frame(name =all_name[i],t(stats_data[,-1:-3]))
      colnames(data_frame_p_adj)<-c("name",list_rowname_num)
      datalist_num[[i]]<-data_frame_p_adj
    }
    
  }
  num_data = do.call(rbind, datalist_num)
  num_data

}

