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

dot<<-0
xsize<<-0
font_size<<-0
width<<-0
height<<-0
number_of_flies= 10
num_of_movies =0


rgb_2_hex <- function(r,g,b){rgb(r, g, b, maxColorValue = 1)}


#to debug
if (with_rgb == TRUE){
  
  p <- arg_parser("path of the color")
  
  # Add command line arguments
  p <- add_argument(p,"path",
                    help = "path",
                    flag = FALSE)
  
  # Parse the command line arguments
  argv <- parse_args(p)
  
}


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

compute_stat<-function(csv_file_name,dir){
  datalist = list()
  setwd(dir[1,1])
  df1<-as.data.frame(read.csv(csv_file_name))
  first<-df1[ , grepl( "value" , names( df1 ) ) ]
  first$id <-as.factor(groupsNames[1])
  for (i in 2:num_of_pop){
    setwd(dir[i,1])
    df_temp<-as.data.frame(read.csv(csv_file_name))
    df_temp<-df_temp[ , grepl( "value" , names( df_temp ) ) ]
    df_temp$id <-as.factor(groupsNames[i])
    first<-bind_cols(first,df_temp)
  }
  
  indexs<-c()
  indexs<-which(grepl( "id" , names( first ) ))
  names_all<-df1[ , grepl( "file" , names( df1 ) ) ]
  all_name<-as.character(names_all[1,1:ncol(names_all)])
  featuers_comb<-c()
  
  #the j is for the feature names and i is for the number oof pop
  
  for(j in 1:ncol(names_all)){
    temp<-c()
    temp<-cbind(temp,(as.list(first[j])))
    for(i in 2:num_of_pop){
      temp<-cbind(temp,(as.list(first[indexs[i-1]+j])))
    }
    
    featuers_comb<-rbind(featuers_comb,temp)
    
  }
  rownames(featuers_comb)<-all_name
  
  for(i in 1:ncol(names_all)){
    names = c()
    for (j in 1:num_of_pop) {
      names = c(names, rep(groupsNames[j], length(unlist(featuers_comb[j]))))
    }
    value = rapply(featuers_comb[i,], c)
    data = data.frame(names, value)
    data$names <- as.character(data$names)
    data$names <- factor(data$names, levels=unique(data$names))
    
    
    len_stat <- getStatisticData(featuers_comb[i,], names, value, data)
    #i need to write this to dataframe
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
    
  }
  big_data = do.call(rbind, datalist)
  big_data
  csv_file_name <-paste("stats",csv_file_name)
  write.csv(big_data, csv_file_name, row.names = F)
  
  
  
}

Stat_sig<-function(dir){
  
  compute_stat("all_classifier_averages.csv",dir)
  compute_stat("averages per movie.csv",dir)
  compute_stat("bout_length_scores.csv",dir)
  compute_stat("frequency_scores.csv",dir)
}

stats_main<-function(dir){
  
  Stat_sig(dir)
  ave_kinetic.df<-as.data.frame(read.csv('stats averages per movie.csv'))
  ave_classifiers.df<-as.data.frame(read.csv('stats all_classifier_averages.csv'))
  ave_bl.df<-as.data.frame(read.csv('stats bout_length_scores.csv'))
  ave_frq.df<-as.data.frame(read.csv('stats frequency_scores.csv'))
  
  
  group_name_dir = tools::file_path_sans_ext(dirname((dir[1,1])))
  setwd(group_name_dir)
  net_stat_len.df<-as.data.frame(read.csv("stats of length network.csv"))
  net_stat_num.df<-as.data.frame(read.csv("stats of number network.csv"))
  
  all<-rbind(ave_kinetic.df,ave_classifiers.df,ave_bl.df,ave_frq.df,net_stat_len.df,net_stat_num.df)
  all$name<- str_replace(all$name, "scores_", "")
  all$name<- str_replace(all$name, ".mat", "")
  
  
  if(num_of_pop<3){
    fdr<-p.adjust(all$p_val, method ="fdr", n = length(all$p_val))
    all$fdr<-fdr
  }
  
  csv_file_name <-"all_togrther.csv"
  write.csv(all, csv_file_name, row.names = F)
  
  

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
#function avg per movie of assa
averagesPerMovieByFile<-function(){
  
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
          tmp_ave.df<-  data.frame(dir=curr.dir, file=files[j], fly=i, value=mean(tmp.df$value)) #make average per fly
          row_ave.df<- rbind(row_ave.df, tmp_ave.df) #add average of each fly to others in the same movie
        }
        tmp_movie_ave.df<-data.frame(dir=dir[k], file=files[j], value=mean(row_ave.df$value))
        
        if (index==1)
          movie_ave.df<-data.frame(dir=dir[k], file=files[j], value=mean(row_ave.df$value)) #make average per movie
        if (index==1)  
          col.df<- row_ave.df
        else {
          col.df<- cbind(col.df, row_ave.df)
          movie_ave.df<-cbind(movie_ave.df, tmp_movie_ave.df) #combine averages per movie
        }
        col.df<- cbind(col.df, row_ave.df)
        row_ave.df<- NULL
      }
    }
    if (k==1)
      total_movie_ave.df<- movie_ave.df
    else 
      total_movie_ave.df<-rbind(total_movie_ave.df, movie_ave.df)
    
    ordered_ave<- col.df[order(col.df$file),]
    final.df<-rbind(final.df, ordered_ave)
  }
  write.csv(total_movie_ave.df, 'averages per movie.csv', row.names=F)
  
}
#help function for creat network
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
importClassifierFilesAndCalculatePerFrame<-function(){
  dir<-list.dirs(recursive = F)
  print(dir)
  allscore.df<-data.frame()
  score.df<-data.frame()
  totalscore.df<-data.frame()
  finalavepermovie.df<-data.frame()
  
  first<-T
  for(k in 1:length(dir)){
    curr.dir<-(paste0(dir[k],'/')) 
    print(k)
    print(curr.dir)
    files<-list.files(path=paste0(curr.dir), pattern = 'scores')
    avepermovie.df<-data.frame()
    first<-T
    for(j in 1:length(files)){
      file<-readMat(paste0(curr.dir,'/',files[j])) #read each mat file
      score.df<-data.frame()
      for (i in 1:length(file$allScores[[4]])){
        tmp.df <- data.frame(dir=dir[k], files=files[j], fly=i, value=as.numeric(file$allScores[[4]][[i]][[1]])) # convert format of data for each fly
        if (mean(tmp.df$value)!=0){
          scores.table<-(table(tmp.df$value))/(length(tmp.df$value)) #calculate frequency of behavior
          tmpflyscore.df<-data.frame(dir=dir[k], files=files[j], fly=i, values=(scores.table[2])) 
          score.df<-rbind(score.df, tmpflyscore.df)
        }
        else{
          tmpflyscore.df<-data.frame(dir=dir[k], files=files[j], fly=i, values=(scores.table[2])) 
          score.df<-rbind(score.df, tmpflyscore.df)
        }
      }
      if (first){
        avepermovie.df<-data.frame(dir=dir[k], file=files[j], value=mean(score.df$values))
      }
      else{
        tmp_avepermovie.df<-data.frame(dir=dir[k], file=files[j], value=mean(score.df$values)) #calculate average per movie
        avepermovie.df<-cbind(avepermovie.df, tmp_avepermovie.df) #add averages to one list
      }
      
      if (first){
        allscore.df<-score.df
        first<-F
      }
      else
        allscore.df<-cbind(allscore.df,score.df) # merge all files in each movie
      
    }
    totalscore.df<-rbind(totalscore.df, allscore.df) #merge all into one table according to file name
    finalavepermovie.df<-rbind(finalavepermovie.df, avepermovie.df)
  }
  
  write.csv(totalscore.df, 'all_classifier_scores.csv', row.names = F)
  write.csv(finalavepermovie.df, 'all_classifier_averages.csv', row.names = F)
  
}


creatNetwork2popforscatter<-function(current_path){
  setwd(current_path)
  group_name_dir = tools::file_path_sans_ext(dirname((current_path)))
  setwd(group_name_dir)
  #we need to make this file befor using this script
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
  setwd(current_path)
  names<-c("density(LOI)","modularity(LOI)","sd strength(LOI)","strength(LOI)","betweens(LOI)","density(NOI)","modularity(NOI)","sd strength(NOI)","strength(NOI)","betweens(NOI)")  
  values<-c(densL,modL,sdL,strL,betL,densN,modN,sdN,strN,betN)
  network.df<-data.frame(names,values,varience)
  View(network.df)
  colnames(network.df) <- c("file", "value","Variance")
  write.csv(network.df, 'network.csv', row.names = F)
  
}



netWorkStats<-function(current_path){
  datalist = list()
  datalist_num = list()
  
  setwd(current_path)
  group_name_dir = tools::file_path_sans_ext(dirname((current_path)))
  setwd(group_name_dir)
  #we need to make this file befor using this script
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
  all_name<-paramsNames
  all_name_NOI<-paste("NOI",all_name)
  all_name_LOI<-paste("LOI",all_name)
  
  
  for (i in 1:length(paramsNames)) {
    len_stat<-statistic_to_csv_of_network(groupsNames, lengthParams[i,])
    
    if(num_of_pop<3){
      print(all_name_LOI[i])
      print(len_stat[[1]]$p.value)
      dat <- data.frame(name =all_name_LOI[i],p_val = len_stat[[1]]$p.value)
      dat$test <- len_stat[[2]]  # maybe you want to keep track of which iteration produced it?
      datalist[[i]] <- dat # add it to your list
      
    }
    else{
      if(len_stat[[2]]=="Kruskal"){
        rownames(len_stat[[1]][["p.value"]])<-gsub("Males_", "", rownames(len_stat[[1]][["p.value"]]))
        colnames(len_stat[[1]][["p.value"]])<-gsub("Males_", "", colnames(len_stat[[1]][["p.value"]]))
        p_adj_k<-as.data.frame(len_stat[[1]][["p.value"]])
        p_adj_kk<-to_dataframe(p_adj_k,all_name_LOI[i])
        datalist[[i]]<-p_adj_kk
      }
      else{
        rownames(len_stat[[1]][["names"]])<-gsub("Males_", "", rownames(len_stat[[1]][["names"]]))
        stats_data<-as.data.frame(len_stat[[1]][["names"]]) 
        stats_data<-change_row_names(stats_data)
        list_rowname<-rownames(stats_data)
        data_frame_p_adj<-data.frame(name =all_name_LOI[i],t(stats_data[,-1:-3]))
        colnames(data_frame_p_adj)<-c("name",list_rowname)
        datalist[[i]]<-data_frame_p_adj
      }
      
    }
    len_data = do.call(rbind, datalist)
    len_data
    
    #####################################################################################
    num_stat<-statistic_to_csv_of_network(groupsNames, numberParams[i,])
    
    if(num_of_pop<3){
      print(all_name_NOI[i])
      print(num_stat[[1]]$p.value)
      dat <- data.frame(name =all_name_NOI[i],p_val = num_stat[[1]]$p.value)
      dat$test <- num_stat[[2]]  # maybe you want to keep track of which iteration produced it?
      datalist_num[[i]] <- dat # add it to your list
      
    }
    else{
      if(num_stat[[2]]=="Kruskal"){
        rownames(num_stat[[1]][["p.value"]])<-gsub("Males_", "", rownames(num_stat[[1]][["p.value"]]))
        colnames(num_stat[[1]][["p.value"]])<-gsub("Males_", "", colnames(num_stat[[1]][["p.value"]]))
        p_adj_k_num<-as.data.frame(num_stat[[1]][["p.value"]])
        p_adj_kk_num<-to_dataframe(p_adj_k_num,all_name_NOI[i])
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
        data_frame_p_adj<-data.frame(name =all_name_NOI[i],t(stats_data[,-1:-3]))
        colnames(data_frame_p_adj)<-c("name",list_rowname_num)
        datalist_num[[i]]<-data_frame_p_adj
      }
      
    }
    num_data = do.call(rbind, datalist_num)
    num_data
    
    csv_file_name <-"stats of number network.csv"
    write.csv(num_data, csv_file_name, row.names = F)
    
    csv_file_name <-"stats of length network.csv"
    write.csv(len_data, csv_file_name, row.names = F)

    
  }
  
  
  
}

boutLengthAndFrequencyForClassifiers<-function(){
  str1 = "frequency"
  str2 = "bout length"
  dir<-list.dirs(recursive = F)
  print(dir)
  ave_bl<-data.frame()
  total_bl<-data.frame()
  total_all<-data.frame()
  per_fly_freq<-data.frame()
  total_freq_all<-data.frame()
  ave_bl_fly<-data.frame()
  first<-T
  for(k in 1:length(dir)){
    curr.dir<-(paste0(dir[k],'/')) 
    print(k)
    print(curr.dir)
    files<-list.files(path=paste0(curr.dir), pattern = 'scores')
    first<-T
    total.df<-data.frame()
    total_freq.df<-data.frame()
    for(j in 1:length(files)){
      file<-readMat(paste0(curr.dir,'/',files[j])) #read each mat file
      ave_bl<-data.frame()
      for (i in 1:length(file$allScores[[4]])){
        tmp.df <- data.frame(dir=dir[k], files=files[j], fly=i, value=as.numeric(file$allScores[[4]][[i]][[1]])) # convert format of data for each fly
        
        ### get bout length for each fly ###
        counter<-0
        bl_vector<-data.frame()
        first_bout<-0
        for (m in 1:length(tmp.df$value)){ # get bout length of one fly
          if ((tmp.df$value[m]==1)&(first_bout==0)){
            counter<-1
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
        ave_bl<-rbind(ave_bl,as.numeric(colMeans(bl_vector, na.rm = T, dims = 1))) # combine average bout lengths of all flies per movie
        per_fly_freq<-rbind(per_fly_freq, as.numeric(lengths(bl_vector)/length(tmp.df$value))) # combine frequency of all flies
      }
      ave_per_movie<-mean(colMeans(ave_bl, na.rm = T, dims = 1))
      ave_freq_movie<-colMeans(per_fly_freq, na.rm = T, dims = 1)
      if (is.numeric(mean(ave_bl))==F){
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
  #remove all the na
  total_all[is.na(total_all)] <- 0
  write.csv(total_all, 'bout_length_scores.csv', row.names = F)
  write.csv(total_freq_all, 'frequency_scores.csv', row.names = F)
  
}
#creat the final csv for creating the scatter plot ,calculating the var in here
combineKineticAndClassifiersToSignature<-function(){
  all.df<-data.frame()
  bl_frq.df<-data.frame()
  all_bl.df<-data.frame()
  all_freq.df<-data.frame()
  ave_kinetic.df<-data.frame()
  network.df<-data.frame()
  ave_frq.df<-data.frame()
  ave_classifiers.df<-data.frame()
  ave_bl.df<-data.frame()
  avg_of_bl.df<-data.frame()
  avg_of_frq.df<-data.frame()
  tmp_new.df<-data.frame()
  
  ave_kinetic.df<-as.data.frame(read.csv('averages per movie.csv'))
  ave_classifiers.df<-as.data.frame(read.csv('all_classifier_averages.csv'))
  ave_bl.df<-as.data.frame(read.csv('bout_length_scores.csv'))
  ave_frq.df<-as.data.frame(read.csv('frequency_scores.csv'))
  network.df<-as.data.frame(read.csv('network.csv'))
  
  new.df<-data.frame()
  all.df<-cbind(ave_classifiers.df, ave_kinetic.df)
  all.df<-cbind(all.df, ave_bl.df)
  all.df<-cbind(all.df, ave_frq.df)
  
  for (k in 1:length(all.df)){
    
    if (is.numeric(all.df[[k[1]]])){
      all.df[[k-1]]<-factor(all.df[[k-1]])
      print(levels(all.df[[k-1]]))
      tmp_new.df<-data.frame(file=levels(all.df[[k-1]]), value=mean(all.df[[k]]), Variance=sd(all.df[[k]])) # create average per condition
      new.df<-rbind(new.df, tmp_new.df) # make list of averages per condition of all features
    }
  }
  #network don't need to be proccesed 
  new.df<-rbind(new.df,network.df)
  
  write.csv(all.df, 'combined per movie.csv',row.names = F)
  write.csv(new.df, 'averages per condition.csv', row.names = F)
  
  
}

scaleing<-function(csv_file_name,dir){
  temp<-data.frame()
  setwd(dir[1,1])
  comb<-as.data.frame(read.csv(csv_file_name))
  v <- rep(tools::file_path_sans_ext(basename(((dir[1,1])))), num_of_movies)
  library("dplyr") # or library("tidyverse")
  comb <- cbind(id = v,comb)
  for(i in 2:num_of_pop){
    setwd(dir[i,1])
    temp<-as.data.frame(read.csv(csv_file_name))
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
    bb<-as.data.frame(splited[i])
    bb<-select(bb, -ends_with("id"))
    write.csv(bb, csv_file_name, row.names = F)
  }
  
  
}


## i need to do stat in here



for_Scaleing<-function(dir){
  #do the scaling for each group
  scaleing("all_classifier_averages.csv",dir)
  scaleing("averages per movie.csv",dir)
  scaleing("bout_length_scores.csv",dir)
  scaleing("frequency_scores.csv",dir)
}


vizual<-function(){
  
  library("readxl")
  library(openxlsx)
  temp.df<-data.frame()
  all.df<-data.frame()
  
  if(with_rgb==TRUE){
    allColorData <- read.xlsx(argv$path)
    num_of_pop<<-nrow(allColorData)
  }else{
    allColorData <- as.data.frame(read.xlsx("D:/test/color.xlsx"))
  }
  
  colors_of_groups<<-as.data.frame(lapply(structure(.Data=1:1,.Names=1:1),function(x) numeric(num_of_pop)))
  #rgb and start from 2 because the first colom is names
  for (i in 1:num_of_pop){
    colors_of_groups$X1[i]<-rgb_2_hex(allColorData[i,2:4])
  }
  colors_of_groups$X1<-factor(colors_of_groups$X1, levels = as.character(colors_of_groups$X1))

  if(with_rgb==TRUE){
    param_dir = tools::file_path_sans_ext(dirname((argv$path)))
    params<-data.frame()
    setwd(param_dir)
    params <- as.data.frame(read.xlsx("params.xlsx"))
    
  }
  else{
    params<-data.frame()
    params <- as.data.frame(read.xlsx("D:/test/params.xlsx"))
    
  }

  library(ggplot2)
  library(gridExtra)
  all_colors<-as.character(colors_of_groups$X1)
  #full_title = paste(name1,"vs",name2)
  
  order_name<-c()
  order_name<-  as.data.frame(read_excel(choose.files(caption = "Select order file")))
  library(dplyr)
  
  for(i in 1:num_of_pop){
    capt =paste('Select avg per condition for ',i,' pop')
    xlsxFile <- choose.files(caption = capt)
    xlsxName <- tools::file_path_sans_ext(basename(dirname(xlsxFile)))
    temp.df<-as.data.frame(read.csv(xlsxFile))
    temp.df$file<-gsub("Aggregation", "Social Clustering", temp.df$file)
    name = xlsxName
    group_name_in_pop = tools::file_path_sans_ext(dirname((xlsxFile)))
    number_of_movies =length(list.dirs(path=group_name_in_pop, full.names=T, recursive=F ))
    temp.df$id =name
    temp.df$Variance=temp.df$Variance/(sqrt(number_of_movies))
    temp.df$file<-tools::file_path_sans_ext(temp.df$file)
    temp.df$file<- str_replace(temp.df$file, "scores_", "")
    temp.df$file<-gsub("Aggregation", "Social Clustering", temp.df$file)
    temp.df<-semi_join(temp.df, order_name, by = "file")
    order_name<-semi_join(order_name, temp.df, by = "file")
    temp.df$file<-as.character(temp.df$file)
    order_name$file<-as.character(order_name$file)
    temp.df$file <- factor(temp.df$file, levels=order_name$file)
    all.df <- rbind(all.df, temp.df)
  }
  t <- ggplot(all.df, aes(x=value, y=file, group=id, color=id))
  t<- t+geom_point(size =dot)
  t<-t+ scale_color_manual(values = as.character(colors_of_groups$X1))
  t<-t+ geom_pointrange(mapping=aes(xmax=value+Variance, xmin=value-Variance), size=0.08)+
    xlim(-(xsize),(xsize))+theme_minimal(base_size = font_size)
  
  setwd((choose.dir(caption = "Select folder for saving the scatter plot")))
  print(t)
  ggsave(plot = t, filename = "scatterplot.pdf", height=height, width=width)
  
  
}



if(with_rgb==TRUE){
  allColorData <- read.xlsx(argv$path)
  num_of_pop<<-nrow(allColorData)
  
}else{
  #test for myself
  library(openxlsx)
  allColorData <- as.data.frame(read.xlsx("D:/test/color.xlsx"))
  num_of_pop<<-nrow(allColorData)
}


if(with_rgb=="TRUE"){
  param_dir = tools::file_path_sans_ext(dirname((argv$path)))
  setwd(param_dir)
  params<-data.frame()
  params <- as.data.frame(read.xlsx("params.xlsx"))
}else{
  params<-data.frame()
  params <- as.data.frame(read.xlsx("D:/test/params.xlsx"))
}

dot<<-params$dot
xsize<<-params$xsize
font_size<<-params$font
width<<-params$width
height<<-params$height



dir=as.data.frame(lapply(structure(.Data=1:1,.Names=1:1),function(x) numeric(num_of_pop)))
for (i in 1:num_of_pop){
  dir[i,1]<-allColorData$group_name[i]
}


dir$X1<-gsub("\\\\", "/", dir$X1)
for(i in 1:num_of_pop){
  dir[i,1]<-str_trim(dir[i,1], side = c("right"))
}


if(params$change_or_run == 2){
  for (i in 1:num_of_pop){
    setwd(dir[i,1])
    group_name <<- tools::file_path_sans_ext(basename((dir[i,1])))
    num_of_movies <<-length(list.dirs(path=dir[i,1], full.names=T, recursive=F ))
    averagesPerMovieByFile()
    setwd(dir[i,1])
    importClassifierFilesAndCalculatePerFrame()
    setwd(dir[i,1])
    boutLengthAndFrequencyForClassifiers()
    
  }
  #everyone is in the same dir and also this function go one dir up
  
  
  #i don't think i need to do this more than 1 time but i do it more times just for the names.when I will have tiime ii iwll fix this
  for (i in 1:num_of_pop){
    netWorkStats(dir[i,1])
  }
  
  
  stats_main(dir)
  #first stat than scalling
  for_Scaleing(dir)
  
  for (i in 1:num_of_pop){
    #the group name if for saving each paramter of the network in spicific var
    group_name <<- tools::file_path_sans_ext(basename((dir[i,1])))
    creatNetwork2popforscatter(dir[i,1])
  }
  
  for(i in 1:num_of_pop){
    #for each net there is different valus 
    setwd(dir[i,1])
    num_of_movies <<-length(list.dirs(path=dir[i,1], full.names=T, recursive=F ))
    combineKineticAndClassifiersToSignature()
  }
  
  vizual()
  
  
  if(with_rgb==TRUE){
      # delete a file of color but not the values params 
      unlink(argv$path)
      
  }
}

if(params$change_or_run == 1){
  vizual()
}


