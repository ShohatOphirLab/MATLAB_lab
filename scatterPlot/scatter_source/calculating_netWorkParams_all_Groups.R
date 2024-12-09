calculating_netWorkParams_all_Groups<-function(dir,path_to_scripts,xlsxFile,argv,debbug_path_color,with_rgb){
  
  current_dir =dir
  setwd(path_to_scripts)
  files.sources = list.files()
  sapply(files.sources, source)
  setwd(current_dir)
  
  
  allColorData<-data.frame()
  lengthParams <- c()
  numberParams <- c()
  numberOfMovies<-c()
  
  group_name_dir = tools::file_path_sans_ext(dirname((current_dir)))
  setwd(group_name_dir)
  #we need to make this file befor using this script
  #all data is the data from the exel in the first sheet
  allData <- read.xlsx(xlsxFile)
  if(with_rgb==TRUE){
    allColorData <- read.xlsx(argv$path)
    num_of_pop<-nrow(allColorData)
  }else{
    #test for myself
    library(openxlsx)
    allColorData <- as.data.frame(read.xlsx(debbug_path_color))
    num_of_pop<<-nrow(allColorData)
  }

  
  #this loop calculte for all groupes 
  for (i in 1:allData$Number.of.groups[1]) {
    cur <- (i + 1) * 2
    print(i)
    numberOfMovies[i]<- allData[i, 3]
    lengthParams <- cbind(lengthParams, calculateGroupParams(allData[1:numberOfMovies[i], cur], 0,path_to_scripts))
    numberParams <- cbind(numberParams, calculateGroupParams(allData[1:numberOfMovies[i], cur + 1], allData$Max.number.of.interaction[1],path_to_scripts))
  }
  return(list(lengthParams,numberParams))
}