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
temp<-data.frame()
num_of_pop =2
dir<<-as.data.frame(lapply(structure(.Data=1:1,.Names=1:1),function(x) numeric(num_of_pop)))
num_of_movies = 12
library(data.table)  
library(dplyr)
groupname1= "Gropued"
groupname2= "Single"



#scaleing<-function(csv_file_name){
csv_file_name="bout_length_scores.csv"
  for (i in 1:num_of_pop){
    dir[i,1]<-choose.dir(default = "", caption = "Select folder")
  }
  
  
  
  setwd(dir[1,1])
  comb<-as.data.frame(read.csv(csv_file_name))
  v <- rep(groupname1, num_of_movies)
  library("dplyr") # or library("tidyverse")
  comb <- cbind(id = v,comb)
  for(i in 2:num_of_pop){
    setwd(dir[i,1])
    temp<-as.data.frame(read.csv(csv_file_name))
    v <- rep(groupname2, num_of_movies)
    temp <- cbind(id = v,temp)
    comb<-bind_rows(comb,temp)
  }
  
  #need to do loop here
  
  comb$id <- as.factor(comb$id)
  
  
  
  library(dplyr)
  
  scaled<-comb %>%
    mutate_if(is.numeric, scale)
  
  
  splited<-split(scaled, scaled$id)
  

  for(i in 1:num_of_pop){
    setwd(dir[i,1])
    bb<-as.data.frame(splited[i])
    bb<-select(bb, ends_with("id"))
    write.csv(bb, csv_file_name, row.names = T)
  }
  
  
#}



#scaleing("averages per movie.csv")
