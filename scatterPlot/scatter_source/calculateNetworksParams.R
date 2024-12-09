calculateNetworksParams <- function(net, folderPath, graphName, vertexSize,fileName,path_to_scripts) {
 
  current_dir =getwd()
  setwd(path_to_scripts)
  files.sources = list.files()
  sapply(files.sources, source)
  setwd(current_dir)
  
  print(fileName)
  vertexNumber = gorder(net)
  par(mfrow=c(1,1), mar=c(1,1,1,1))
  l <- layout_in_circle(net)
  density <- sum(E(net)$weight) / (vertexNumber * (vertexNumber - 1) / 2)
  wtc <- cluster_walktrap(net)
  modularity <- modularity(wtc)
  sdStrength <- sd(strength(net, weights = E(net)$weight))
  strength <- strength(net, weights = E(net)$weight)
  betweenness <- betweenness(net, v = V(net), directed = FALSE, weights = E(net)$weight)
  
  return(list(density, modularity, sdStrength, strength, betweenness))
}
