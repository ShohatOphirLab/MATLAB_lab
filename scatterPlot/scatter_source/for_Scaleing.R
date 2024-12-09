for_Scaleing<-function(dir,path_to_scripts){
  
  current_dir =getwd()
  setwd(path_to_scripts)
  files.sources = list.files()
  sapply(files.sources, source)
  setwd(current_dir)
  
  #do the scaling for each group
  scaleing("all_classifier_averages.csv",dir,path_to_scripts)
  scaleing("averages per movie.csv",dir,path_to_scripts)
  scaleing("bout_length_scores.csv",dir,path_to_scripts)
  scaleing("frequency_scores.csv",dir,path_to_scripts)
}
