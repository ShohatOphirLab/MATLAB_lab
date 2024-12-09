all_frames_interaction_above <- function(number_of_flys,sub_list_mat,df_mat) {
  library(ndtv)
  
  
  all<-data.frame()
  
  for(i in 1:number_of_flys){
    for(j in 1:number_of_flys){
      if(length(unlist(sub_list_mat[i,j]))!=0){
        temp_num_frames<-unlist(df_mat[i,j])
        
        #the value from where the diffrence is bigger than 120 in the next frame
        idx <- c(0, cumsum(abs(diff(temp_num_frames)) > 120))
        splited_frames<-split(temp_num_frames, idx)
        if(length(splited_frames)> 0){
          firsts_elemts<<-lapply(splited_frames, `[[`, 1)
          last_elemnts<-lapply(splited_frames, function(x) x[length(x)])
          
          
          for(number_of_elemnts in 1:length(firsts_elemts)){
            tobind<-c(colnames(df_mat[i]),rownames(df_mat[j,]))
            tobind<-as.data.frame(t(tobind))
            tobind<-cbind(tobind,firsts_elemts[number_of_elemnts])
            tobind<-cbind(tobind,last_elemnts[number_of_elemnts])
            colnames(tobind)<-c("tail","head","onset","terminus")
            
            all<-rbind(all,tobind)
            
          }
          
        }else{
          print(i)
          print(j)
          print("check this")
          
        }
        
      }
      
    }
  }
  
  
  return(all)
  
}



#to debug
library(argparser, quietly=TRUE)

with_rgb = TRUE
if (with_rgb == TRUE){
  
  p <- arg_parser("path of the color")
  
  # Add command line arguments
  p <- add_argument(p,"path",
                    help = "path",
                    flag = FALSE)
  
  # Parse the command line arguments
  argv <- parse_args(p)
  
}

#change the \
print(argv$path)

number_of_flys<-10


#my_path<-"D:/EX5_6/choosen_files_colors.csv"

allColorData <- as.data.frame(read.csv(argv$path))

#give each on a color for analysis in a loop 

num_of_pop<-nrow(allColorData)


rgb_2_hex <- function(r,g,b){
  return(rgb(r, g, b, maxColorValue = 1))}

colors_of_groups<<-as.data.frame(lapply(structure(.Data=1:1,.Names=1:1),function(x) numeric(num_of_pop)))
#rgb and start from 2 because the first colom is names
for (i in 1:num_of_pop){
  colors_of_groups$X1[i]<-rgb_2_hex(allColorData[i,2:4])
}
#colors_of_groups$X1<-factor(colors_of_groups$X1, levels = as.character(colors_of_groups$X1))

allColorData<-cbind(allColorData,color =(colors_of_groups$X1) )



library(R.matlab)
library(ndtv)

for(index in 1:num_of_pop){
  
  all<-data.frame()
  
  current_dir<-allColorData$groupNameDir[index]
  setwd(current_dir)
  f <- function(x) {
    if(is.list(x)) lapply(x, f)
    else ifelse(length(x) == 0, 0, x)
  }
  
  
  
  if( file.exists(paste0(current_dir, '/','Allinteraction.mat')) ){
    filepath<-paste0(current_dir, '/','Allinteraction.mat')
    
  }else if( file.exists(paste0(current_dir, '/','AllinteractionWithAngelsub.mat'))){
    filepath<-paste0(current_dir, '/','AllinteractionWithAngelsub.mat')
    
  }else{
    stop("Allinteraction.mat does not exist!!!please creat it with MainInteractionAllNoAngelSub.m ")
    
  }
  
  df <- (readMat(filepath)) # read each MAT file
  sub_list_mat<-matrix(df[["new.interactionFrameMatrix"]],nrow = number_of_flys, ncol = number_of_flys)
  df_mat<-as.data.frame(sub_list_mat)
  
  
  
  
  #REMOVE 0 (MEAN NO INTERACTION)
  for(i in 1:ncol(df_mat)){
    for(j in 1:nrow(df_mat)){
      if(length(unlist(df_mat[i,j])) == 0){
        df_mat[i,j] <- lapply(df_mat[i,j], function(x)x[lengths(x) == 0] <- 0)
      }
    }
  }
  
  df_mat<-na.omit(df_mat)
  
  colnames(df_mat)<-c("1","2","3","4","5","6","7","8","9","10")
  rownames(df_mat)<-c("1","2","3","4","5","6","7","8","9","10")
  nodes<-c("1","2","3","4","5","6","7","8","9","10")
  nodes<-as.data.frame(nodes)
  nodes$name<-c("fly1","fly2","fly3","fly4","fly5","fly6","fly7","fly8","fly9","fly10")
  colnames(nodes)<-c("vertex.id","names")
  #colnames(nodes)<-c("vertex.id")
  nodes$vertex.id<-as.numeric(nodes$vertex.id)
  #other <- do.call(unlist, df_mat)
  all<-data.frame()
  
  
  all<-all_frames_interaction_above(number_of_flys,sub_list_mat,df_mat)
  
  colnames(all)<-c("tail","head","onset","terminus")
  edge.id<-seq_along(1:nrow(all))
  all<-cbind(edge.id,all)
  all$tail<-as.numeric(all$tail)
  all$head<-as.numeric(all$head)
  new_edge<-data.frame(onset=all["onset"],terminus=all["terminus"],tail=all["tail"],head=all["head"])
  new_nodes<-data.frame(onset=all["onset"],terminus=all["terminus"],id=all["tail"])
  tmp_new<-data.frame(onset=all["onset"],terminus=all["terminus"],id=all["head"])
  colnames(tmp_new)<-c("onset","terminus","id")
  colnames(new_nodes)<-c("onset","terminus","id")
  
  new_nodes<-rbind(new_nodes,tmp_new)
  new_nodes$pid<-seq_along(1:nrow(new_nodes))
  
  final_nodes<-new_nodes
  final_nodes$onset<-0
  final_nodes$terminus<-27001
  
  
  vertex<-data.frame(vertex.id=c("1","2","3","4","5","6","7","8","9","10"),col=c(allColorData[index,"color"]))
  
  vertex$vertex.id<-as.numeric(vertex$vertex.id)
  
  nw <- network(unique(new_edge[,c(3,4)]),
                vertex.attr = vertex[,c(1:2)],
                vertex.attrnames = c("vertex.id", "col"),
                directed = F)
  
  net <- networkDynamic(base.net=nw,edge.spells = as.matrix(new_edge), vertex.spells = as.matrix(final_nodes))
  
  compute.animation(net,
                    slice.par = list(start = 1, end = 27001, interval = 60, aggregate.dur = 60, rule = "latest"),verbose=FALSE)
  
  setwd(current_dir)
  render.d3movie(net,filename= paste0(basename(current_dir),"_",".html"),
                 output.mode = "HTML",vertex.col = "col",
                 launchBrowser = TRUE,displaylabels =T,verbose=FALSE)
}





