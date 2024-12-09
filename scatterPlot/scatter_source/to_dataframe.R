to_dataframe<-function(p_adj_k,name,test,path_to_scripts){
  
  current_dir =getwd()
  setwd(path_to_scripts)
  files.sources = list.files()
  sapply(files.sources, source)
  setwd(current_dir)
  
  p_adj_k <- as.data.frame(p_adj_k)
  p_adj_k.name <- vector("character")
  p_adj_k.value <- vector("numeric")
  
  for (i in 1:ncol(p_adj_k) )
    for (j in i:length(p_adj_k) ) {
      p_adj_k.name <- c(p_adj_k.name,paste(colnames(p_adj_k[i]),"-",rownames(p_adj_k)[j]))
      p_adj_k.value <- c(p_adj_k.value,p_adj_k[j,i])
    }
  
  
  v <- order(p_adj_k.value,decreasing = F)
  data_frame<-data.frame(name =name,t(p_adj_k.value[v]),test =test)
  colnames(data_frame)<-c("name",p_adj_k.name[v],"test")
  return (data_frame)
}
