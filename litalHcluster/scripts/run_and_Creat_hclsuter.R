

run_and_Creat_hclsuter<-function(full_path_to_dirs,path_to_scripts,font_size){
  
#  full_path_to_dirs = "F:/hadar/GH/together/color.xlsx"
  
  ##path_to_scripts = "D:/MATLAB/runAll/litalHcluster/scripts"
##  font_size = 14
  
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
  library(progress)
  library(dplyr)

  
  current_dir =getwd()
  setwd(path_to_scripts)
  files.sources = list.files()
  sapply(files.sources, source)
  setwd(current_dir)


allDirsData <- read.xlsx(full_path_to_dirs)
num_of_pop<<-nrow(allDirsData)
param_dir = tools::file_path_sans_ext(dirname((full_path_to_dirs)))







dir=as.data.frame(lapply(structure(.Data=1:1,.Names=1:1),function(x) numeric(num_of_pop)))
for (i in 1:num_of_pop){
  dir[i,1]<-allDirsData$groupNameDir[i]
  dir[i,1]<-str_trim(dir[i,1], side = c("right"))
}

dir$X1<-gsub("\\\\", "/", dir$X1)
for(i in 1:num_of_pop){
  if(dir.exists(dir[i,1])){
    print("exist!!")
  }
}

groupsNames <- as.character(basename(allDirsData$groupNameDir))


setwd(param_dir)
## need to save the file in the perent folder
file_check_not_doubled<-as.data.frame(read.xlsx("files_for_dup.xlsx"))
#anothertest<-as.data.frame(read.csv("F:/allGroups/Females_Grouped/averages per condition.csv"))
all_together<-data.frame()
num_of_removed_valus<-0
for(i in 1:num_of_pop){
  full_path_avg_per_con<-paste0(dir[i,1],"\\","averages per condition.csv")
  df<-as.data.frame(read.csv(full_path_avg_per_con))
  show_remove<-anti_join(file_check_not_doubled,df , by = "file")
  if(i!=1 & num_of_removed_valus!=nrow(show_remove)){
    
    error_message<-paste(groupsNames[i],"population there are not the same number of featrues",nrow(show_remove))
    stop(error_message)
  
  }else{
    num_of_removed_valus<-nrow(show_remove)
    df<-semi_join(df, file_check_not_doubled, by = "file")
  }

  

  df$file<- str_replace(df$file, "scores_", "")
  #df$file<- str_replace(df$file, "bout_length", "bout length")
  #df$file<-gsub("Aggregation", "Social Clustering", df$file)
  #df$file<-gsub("Interaction_Assa", "Approach", df$file)
  df$file<- str_replace(df$file, ".mat", "")
  
  colnamedf<-data.frame()
  colnamedf<-as.data.frame(t(df$value))
  colnames(colnamedf)<-t(df$file)
  

  rownames(colnamedf)<-c(basename(dir[i,1]))
 
  all_together<-rbind(all_together,colnamedf)
}





#numric_together<-as.matrix(all_together)
#heatmap(numric_together, scale = "none")


library("pheatmap")
library(seriation)
library(dendextend)
library(svDialogs)

t <- pheatmap(all_together,fontsize_col =font_size)
t

setwd((choose.dir(caption = "Select folder for saving the heatmap")))
ggsave(plot = t, filename = "heatmap.jpeg",units = "cm")


##################
phtmap <- pheatmap(all_together)
row_dend <- phtmap[[1]]
#HADAR
ind_order_lables <- phtmap[["tree_col"]][["order"]]
col_bend <- phtmap[["tree_col"]][["labels"]]
hadar <- col_bend[ind_order_lables]
hadar = rev(hadar)
## hadar

write.csv(hadar,"C:/Users/labophir/Downloads/forheat.csv", row.names=F)
#sorting by rows and alphbeticly
#############

# change <- dlg_list(c("yes","no"), multiple = TRUE,title="change heatmap name order?",Sys.info()
# )$res
# 
# if(change == "yes"){
#   res<-c()
#   for(i in 1:num_of_pop){
#     res[i] <- dlg_list(groupsNames, multiple = TRUE,title="order for the heatmap")$res
#   }
#   row_dend<-rotate(row_dend,res)
#   t<-pheatmap(all_together, cluster_rows =as.hclust(row_dend),fontsize_col =font_size )
#   setwd((choose.dir(caption = "Select folder for saving the heatmap")))
#   
#   ggsave(plot = t, filename = "heatmap.jpeg", units = "cm")
# }else{
#   t <- pheatmap(all_together,fontsize_col =font_size)
#   
#   setwd((choose.dir(caption = "Select folder for saving the heatmap")))
#   ggsave(plot = t, filename = "heatmap.jpeg",units = "cm")
#   
# }
# show(t)

#list_of_names<-c("Males_Grouped","Males_Mated","Males_Singels","Females_Mated","Females_Grouped","Females_Singles")


#row_dend <- rotate(row_dend, order = sort(rownames(all_together)[get_order(row_dend)]))
#row_dend<-rotate(row_dend,res)
#pheatmap(all_together, cluster_rows =as.hclust(row_dend))

#pheatmap(all_together,cluster_rows = FALSE,show_colnames  = T)


# # Finding distance matrix
# distance_mat <- dist(all_together, method = 'euclidean')
# distance_mat

# Fitting Hierarchical clustering Model
# to training dataset
#set.seed(240) # Setting seed
#Hierar_cl <- hclust(distance_mat, method = "average")
#Hierar_cl
#plot(Hierar_cl)
# Plotting dendrogram

# Choosing no. of clusters
# Cutting tree by height
#abline(h = 110, col = "green")


}
