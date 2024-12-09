netWorkStats<-function(current_path,xlsxFile,path_to_scripts,groupsNames,lengthParams,numberParams){
  
  current_dir =getwd()
  setwd(path_to_scripts)
  files.sources = list.files()
  sapply(files.sources, source)
  setwd(current_dir)
  
  datalist = list()
  datalist_num = list()
  
  
  setwd(current_path)
  group_name_dir = tools::file_path_sans_ext(dirname((current_path)))
  setwd(group_name_dir)
  #we need to make this file befor using this script
  
  
  all_name<-c("Density", "Modularity", "SD Strength", "Strength", "Betweenness Centrality")
  all_name_NOI<-paste("NOI",all_name)
  all_name_LOI<-paste("LOI",all_name)
  
  
  
  for (i in 1:length(all_name)) {
    lenStat<-statProcess(groupsNames, lengthParams[i,],path_to_scripts)

    if(num_of_pop<3){
      print(all_name_LOI[i])
      print(lenStat[[1]]$p.value)
      dat <- data.frame(name =all_name_LOI[i],pVal = lenStat[[1]]$p.value)
      dat$test <- lenStat[[2]]  #what is the test
      datalist[[i]] <- dat # add it to your list

    }else{
      ##check in creatExpNet what she did in addStatsToGraph function
      if(lenStat[[2]]=="Dunn"){

        datalist[[i]]<-DunnTstDataFrame(all_name_LOI[i],lenStat,path_to_scripts,groupsNames)
      }
      else{
        print(i)
        datalist[[i]]<-AnovaToDataFrame(all_name_LOI[i],lenStat,path_to_scripts,groupsNames)
      }

    }


    #####################################################################################
    numStat<-statProcess(groupsNames, numberParams[i,],path_to_scripts)

    if(num_of_pop<3){
      print(all_name_NOI[i])
      print(numStat[[1]]$p.value)
      dat <- data.frame(name =all_name_NOI[i],pVal = numStat[[1]]$p.value)
      dat$test <- numStat[[2]]  # maybe you want to keep track of which iteration produced it?
      datalist_num[[i]] <- dat # add it to your list

    }else{
      if(numStat[[2]]=="Dunn"){
        datalist_num[[i]]<-DunnTstDataFrame(all_name_NOI[i],numStat,path_to_scripts,groupsNames)

      }
      else{
        datalist_num[[i]]<-AnovaToDataFrame(all_name_NOI[i],numStat,path_to_scripts,groupsNames)
      }

    }



  }
  
  #creating the datalists and then binding them together
  
  lenData = do.call(rbind, datalist)
  lenData
  
  
  numData = do.call(rbind, datalist_num)
  numData
  
  csv_file_name <-"stats of number network.csv"
  write.csv(numData, csv_file_name, row.names = F)
  
  csv_file_name <-"stats of length network.csv"
  write.csv(lenData, csv_file_name, row.names = F)
  
  
}
