getStatisticData <- function(groupsParams, names, value, data,path_to_scripts) {
  # i used this packeg of dunn test because the output of the compers look almost the same
  library(dunn.test)
  current_dir =getwd()
  setwd(path_to_scripts)
  files.sources = list.files()
  sapply(files.sources, source)
  setwd(current_dir)
  
  #statistic data about each paramter density, modularity, sdStrength, strength, betweenness
  for (i in 1:length(groupsParams)) {
    shapDist <- shapiro.test(unlist(groupsParams[[i]]))
    #22.11.21 changed p value to 0.1
    if (shapDist$p.value < 0.1) {
      if (length(groupsParams) < 3) {
        stats <- wilcox.test(value~names, data,exact=FALSE)
        return(list(stats, "Wilcoxen"))
      } else {
        Kruskal<-kruskal.test(value~names, data)
        stats <- dunn.test(data$value,data$names, method="none",list = FALSE)
        return(list(stats, "Dunn",Kruskal[["p.value"]],"pVal"))
      }
    }
  }
  if (length(groupsParams) < 3) {
    stats <- t.test(value~names, data)
    return(list(stats, "T Test"))
  } else {
    #The output includes the columns F value and Pr(>F) corresponding to the p-value of the test.
    aov.res <- aov(value~names, data)
    aov.resF<-summary(aov.res)
    stats <- TukeyHSD(aov.res)
    return(list(stats, "Anova",aov.resF[[1]][["Pr(>F)"]][1],"pVal"))
  }
}