all_frames_interaction_above <- function(number_of_flys,sub_list_mat,df_mat) {
  

  
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