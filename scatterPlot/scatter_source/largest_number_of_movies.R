largest_number_of_movies<-function(dir,num_of_pop,path_to_scripts){
  current_dir =getwd()
  setwd(path_to_scripts)
  files.sources = list.files()
  sapply(files.sources, source)
  setwd(current_dir)
  
  
  
  max_iter<-0
  for(i in 1:num_of_pop){
    if(length(list.dirs(path = dir[i,1],recursive = FALSE)) > max_iter)
      max_iter<-length(list.dirs(path = dir[i,1],recursive = FALSE))
  }
  
  return(max_iter)
}


