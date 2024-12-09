
orgenize_interval_and_timestamps<-function(df_mat,path_to_scripts){
  
  #this function take the big data frame and orgenize to be according to the 
  #tail","head","onset","terminus so we can build dynmaic networks 
  
  
  
  current_dir =getwd()
  setwd(path_to_scripts)
  files.sources = list.files()
  sapply(files.sources, source)
  setwd(current_dir)
  
  #REMOVE 0 (MEAN NO INTERACTION)
  for(i in 1:ncol(df_mat)){
    for(j in 1:nrow(df_mat)){
      if(length(unlist(df_mat[i,j])) == 0){
        df_mat[i,j] <- lapply(df_mat[i,j], function(x)x[lengths(x) == 0] <- 0)
      }
    }
  }
  
  df_mat<-na.omit(df_mat)
  
  
  
  #10 flys
  colnames(df_mat)<-c("1","2","3","4","5","6","7","8","9","10")
  rownames(df_mat)<-c("1","2","3","4","5","6","7","8","9","10")
  nodes<-c("1","2","3","4","5","6","7","8","9","10")
  nodes<-as.data.frame(nodes)
  all<-data.frame()
  
  for(i in 1:number_of_flys){
    for(j in 1:number_of_flys){
      if(length(unlist(sub_list_mat[i,j]))!=0){
        temp_num_frames<-unlist(df_mat[i,j])
        tobind<-c(colnames(df_mat[i]),rownames(df_mat[j,]))
        tobind<-as.data.frame(t(tobind))
        #the value from where the diffrence is bigger than 120 in the next frame
        seq_inter<- temp_num_frames[diff(temp_num_frames)>120]
        if(length(seq_inter)> 0){
          num_of_seq_iter<-length(seq_inter)
          current_iindex<-1
          for(k in 1:num_of_seq_iter){
            tobind<-c(colnames(df_mat[i]),rownames(df_mat[j,]))
            tobind<-as.data.frame(t(tobind))
            
            index<-which(temp_num_frames == seq_inter[k])
            tt_temp_num_frames<-as.data.frame(temp_num_frames)
            temp_all_inter<-tt_temp_num_frames[current_iindex:index,]
            current_iindex<-index+1
            tobind<-cbind(tobind,temp_all_inter[1])
            tobind<-cbind(tobind,temp_all_inter[length(temp_all_inter)])
            colnames(tobind)<-c("tail","head","onset","terminus")
            
            all<-rbind(all,tobind)
          }
          
        }else{
          tobind<-cbind(tobind,temp_num_frames[1])
          tobind<-cbind(tobind,temp_num_frames[length(temp_num_frames)])
          colnames(tobind)<-c("tail","head","onset","terminus")
          all<-rbind(all,tobind)
          
        }
        
      }
      
    }
  }
  
  colnames(all)<-c("tail","head","onset","terminus")
  
  all["head"] <- as.numeric(unlist(all["head"]))
  all["tail"] <- as.numeric(unlist(all["tail"]))
  
  return(all)
}

