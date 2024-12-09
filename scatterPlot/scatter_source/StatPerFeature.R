StatPerFeature<-function(dir,groupsNames,path_to_scripts){
  
  current_dir =getwd()
  setwd(path_to_scripts)
  files.sources = list.files()
  sapply(files.sources, source)
  setwd(current_dir)
  
  computeStat("all_classifier_averages.csv",dir,groupsNames,path_to_scripts)
  computeStat("averages per movie.csv",dir,groupsNames,path_to_scripts)
  computeStat("bout_length_scores.csv",dir,groupsNames,path_to_scripts)
  computeStat("frequency_scores.csv",dir,groupsNames,path_to_scripts)
}