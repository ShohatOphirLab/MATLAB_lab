getNumofFlys<-function(xlsxFile,path_to_scripts,the_i_pop){
  
  current_dir =getwd()
  setwd(path_to_scripts)
  files.sources = list.files()
  sapply(files.sources, source)
  setwd(current_dir)
  
  allData <- read.xlsx(xlsxFile)
  numberOfMovies<-c()
  #parametrs name

  cur_pop <- (the_i_pop + 1) * 2
  numberOfMovies<- allData[the_i_pop, 3]
  
  #avg of flys in current group expriemnt
  num_of_flies<-getNumOfFliesAvg(allData[1:numberOfMovies[1], cur_pop],path_to_scripts)
  return(num_of_flies) 
}