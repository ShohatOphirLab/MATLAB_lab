reagrange_string<-function(string,path_to_scripts,name_permutation){
  
  current_dir =getwd()
  setwd(path_to_scripts)
  files.sources = list.files()
  sapply(files.sources, source)
  setwd(current_dir)
  
  #find the original name and adjust it to its authurized name
  
  for (i in 1:length(name_permutation)){
    if(grepl(name_permutation[[i]][1], string) & grepl(name_permutation[[i]][2], string)){
      string<-paste(name_permutation[[i]][2],"-",name_permutation[[i]][1])
      print(string)
      break
    }
  }
  
  #temp<-str_split(name_permutation[i], "-")
  
  return(string)
}