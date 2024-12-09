calculateGroupParams <- function(fileNames, maxNumberOfInteration,path_to_scripts) {
  
  current_dir =getwd()
  setwd(path_to_scripts)
  files.sources = list.files()
  sapply(files.sources, source)
  setwd(current_dir)
  
  density <- vector()
  modularity <- vector()
  sdStrength <- vector()
  strength <- vector()
  betweenness <- vector()
  for (i in 1:length(fileNames)) {
    matFile <- fileNames[i]
    mat <- scan(toString(matFile))
    numCol <- sqrt(length(mat))
    mat <- matrix(mat, ncol = numCol, byrow = TRUE)
    net <- graph_from_adjacency_matrix(mat, mode = "undirected", weighted = TRUE)
    folderPath <- dirname(toString(matFile))
    if (maxNumberOfInteration > 0) {
      E(net)$weight <- E(net)$weight / maxNumberOfInteration
      E(net)$width <- E(net)$weight*7
      cur <- calculateNetworksParams(net, folderPath, "number of interaction", 7,fileNames[i],path_to_scripts)
    } else {
      E(net)$width <- E(net)$weight*10
      cur <- calculateNetworksParams(net, folderPath, "length of interction", 25,fileNames[i],path_to_scripts)
    }
    density <- c(cur[1], density)
    modularity <- c(cur[2], modularity)
    sdStrength <- c(cur[3], sdStrength)
    strength <- c(cur[4], strength)
    betweenness <- c(cur[5], betweenness)
  }
  
  return(list(density, modularity, sdStrength, strength, betweenness))
}
