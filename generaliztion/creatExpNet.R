library(igraph)
library(openxlsx)
library(ggplot2)
library(cowplot)
library(ggpubr)
library(ggsignif)
library(nortest)
library(fmsb)
library(argparser, quietly=TRUE)

#global varible
astric_sts<<-0
line_stat<<-0
font_size<<-0
width<<-0
height<<-0
number_of_flies = 0
with_rgb = TRUE
num_of_pop<<-c()
allColorData<<-c()
colors_of_groups<<-data.frame()

#from rgb to hex
rgb_2_hex <- function(r,g,b){rgb(r, g, b, maxColorValue = 1)}

#to debug
if (with_rgb == TRUE){

  p <- arg_parser("path of the color")
    
    # Add command line arguments
  p <- add_argument(p,"path",
                      help = "path",
                      flag = FALSE)
  
    # Parse the command line arguments
  argv <- parse_args(p)

}

#________________________________________________________ function zone


calculateNetworksParams <- function(net, folderPath, graphName, vertexSize,fileName) {
  # all
  vertexNumber = gorder(net)
  par(mfrow=c(1,1), mar=c(1,1,1,1))
  l <- layout_in_circle(net)
  jpeg(file.path(folderPath, paste("network ", graphName, ".jpg", sep = "")))
  plot(net, layout = l)
  dev.off()
  
  # density
  density <- sum(E(net)$weight) / (vertexNumber * (vertexNumber - 1) / 2)
  #print(paste("density = ", density))
  x <- c(1 - density, density)
  labels <- c("","Density")
  jpeg(file.path(folderPath, paste("density ", graphName, ".jpg", sep = "")))
  pie(x, labels)
  dev.off()
  
  # modularity
  #This function tries to find densely connected subgraphs
  wtc <- cluster_walktrap(net)
  modularity <- modularity(wtc)
  #print(paste("modularity = ", modularity))
  jpeg(file.path(folderPath, paste("modularity ", graphName, ".jpg", sep = "")))
  plot(wtc, net)
  dev.off()
  
  # strength std
  sdStrength <- sd(strength(net, weights = E(net)$weight))
  #print(paste("sd strength = ", sdStrength))
  
  
  #individual
  
  # strength
  #Summing up the edge weights of the adjacent edges for each vertex.
  #this part it the part that show if the network not staurtated in 10 % 
  max_interaction <- 0.9*((number_of_flies*(number_of_flies-1))/2)
  #print(net)
  a<-E(net)
  b<-length(a)
  if (b <max_interaction){
    all.df<-data.frame(file_name = fileName)
    message("unsaturted network the number of connection is ")
    message(b)
    message("the address is ")
    message(fileName)
    write.csv(all.df, 'unsaturted_network.csv',row.names = F)
    
  }
  strength <- strength(net, weights = E(net)$weight)
  
  #print("strength: ")
  #print(strength)
  jpeg(file.path(folderPath, paste("strength ", graphName, ".jpg", sep = "")))
  plot(net, vertex.size=strength*vertexSize, layout = l)
  dev.off()
  
  # betweenness centality 
  betweenness <- betweenness(net, v = V(net), directed = FALSE, weights = E(net)$weight)
  #print("betweenness: ")
  #print(betweenness)
  return(list(density, modularity, sdStrength, strength, betweenness))
}
#calculating the params of the group with calculateNetworksParams for length and number groups
calculateGroupParams <- function(fileNames, maxNumberOfInteration) {
  density <- vector()
  modularity <- vector()
  sdStrength <- vector()
  strength <- vector()
  betweenness <- vector()
  #number of files we want
  for (i in 1:length(fileNames)) {
    #when debuging see what is inside matfile
    matFile <- fileNames[i]
    mat <- scan(toString(matFile))
    #because the matrix is smetric and there is 100 value so it is 10
    numCol <- sqrt(length(mat))
    number_of_flies<<-numCol
    #all this just to transform to mat format?
    mat <- matrix(mat, ncol = numCol, byrow = TRUE)
    #creat the net itself
    net <- graph_from_adjacency_matrix(mat, mode = "undirected", weighted = TRUE)
    folderPath <- dirname(toString(matFile))
    #numberParams
    if (maxNumberOfInteration > 0) {
      #normalization to the number of the max interaction to the weights of the network this is not happning in lengthparams
      E(net)$weight <- E(net)$weight / maxNumberOfInteration
      E(net)$width <- E(net)$weight*7
      #the 7 and 25?? is for the vertex size for visualization beacuse the lenght value are smaller than the number values
      cur <- calculateNetworksParams(net, folderPath, "number of interaction", 7,fileNames[i])
    } else {
      #which means length of interaction
      E(net)$width <- E(net)$weight*10
      
      cur <- calculateNetworksParams(net, folderPath, "length of interction", 25,fileNames[i])
    }
    #for each of the movies
    density <- c(cur[1], density)
    modularity <- c(cur[2], modularity)
    sdStrength <- c(cur[3], sdStrength)
    strength <- c(cur[4], strength)
    betweenness <- c(cur[5], betweenness)
  }
  
  return(list(density, modularity, sdStrength, strength, betweenness))
}
getStatisticTest <- function(x, y) {
  dataX <- shapiro.test(unlist(x))
  if (dataX$p.value < 0.05)
    return("wilcox.test")
  dataY <- shapiro.test(unlist(y))
  if (dataY$p.value < 0.05)
    return("wilcox.test")
  return("t.test")
}
getStatisticData <- function(groupsParams, names, value, data) {
  #statistic data about each paramter density, modularity, sdStrength, strength, betweenness
  for (i in 1:length(groupsParams)) {
    shapDist <- shapiro.test(unlist(groupsParams[[i]]))
    #22.11.21 changed p value to 0.1
    if (shapDist$p.value < 0.1) {
      if (length(groupsParams) < 3) {
        stats <- wilcox.test(value~names, data)
        return(list(stats, "Wilcoxen"))
      } else {
        kruskal.test(value~names, data)
        stats <- pairwise.wilcox.test(data$value, data$names, p.adjust.method = 'fdr')
        return(list(stats, "Kruskal"))
      }
    }
  }
  if (length(groupsParams) < 3) {
    stats <- t.test(value~names, data)
    return(list(stats, "T Test"))
  } else {
    aov.res <- aov(value~names, data)
    summary(aov.res)
    stats <- TukeyHSD(aov.res)
    return(list(stats, "Anova"))
  }
}
addStatsToGraph <- function(statsData, g, value, names, data) {
  aov.res <- aov(value~names, data)
  templet <- TukeyHSD(aov.res)
  if (statsData[2] == "Wilcoxen" || statsData[2] == "T Test") {
    templet$names[,4] <- statsData[[1]]$p.value
  } else if (statsData[2] == "Kruskal") {
    size <- dim(statsData[[1]]$p.value)
    k = 1
    for (i in 1:size[1]) {
      for (j in i:size[2]) {
        templet$names[k,4] <- statsData[[1]]$p.value[j,i]
        row.names(templet$names)[k] <- paste(row.names(statsData[[1]]$p.value)[j], "-", colnames(statsData[[1]]$p.value)[i], sep = "")
        k = k + 1
      }
    }
  } else if (statsData[2] == "Anova") {
    templet <- statsData[[1]]
  }
  my_anova <- data.frame(cbind(templet$names, make_contrast_coord(length(levels(data$names)))))
  my_anova$astks <- pval_to_asterisks(my_anova$p.adj)
  
  tiny_anova <- my_anova[my_anova$p.adj < 0.05,]
  tiny_anova <- tiny_anova[order(tiny_anova$len, decreasing = FALSE),]
  if (max(value) <= 1) {
    lowest.y <- max(value) + 0.1
    highest.y <- lowest.y + (nrow(tiny_anova) * 0.5)
  } else {
    lowest.y <- max(value) + 0.5
    highest.y <- lowest.y + nrow(tiny_anova)
  }
  margin.y <- 0.1
  actual.ys <- seq(lowest.y, highest.y, length.out = nrow(tiny_anova))
  tiny_anova$ys <- actual.ys
  bp_ask <- g + annotate("segment", x = tiny_anova$str, y = tiny_anova$ys, xend = tiny_anova$end, yend = tiny_anova$ys, colour = "black", size = line_stat)
  bp_ask <- bp_ask + annotate("text", x = tiny_anova$ave, y = (tiny_anova$ys + (margin.y/nrow(tiny_anova))) , xend = tiny_anova$end, yend = tiny_anova$ys, label = tiny_anova$astks, size = astric_sts)
  return(bp_ask)
}
make_contrast_coord <- function(n) {
  tmp <- do.call(rbind,lapply(1:n, (function(i){
    do.call(rbind,lapply(1:n, (function(j){
      if(j > i) {
        c(i,j)
      }
    })))
  })))
  tmp <- data.frame(tmp)
  colnames(tmp) <- c("str", "end")
  tmp$ave <- apply(tmp, 1, mean)
  tmp$len <- apply(tmp, 1, (function(vct){ max(vct) - min(vct) }))
  return(tmp)
}
pval_to_asterisks <- function(p_vals) {
  astk <- sapply(as.numeric(as.character(p_vals)), (function(pv){
    if (pv >= 0 & pv < 0.001) {
      "***"
    } else if (pv >= 0 & pv < 0.01) {
      "**"
    }  else if (pv >= 0 & pv < 0.05) {
      "*"
    } else {
      NA
    }
  }))
  return(astk)
}
createRadarPlot <- function(data, paramsNames, graphFolder, maxValues, groupName, color) {
  data <- as.data.frame(t(data))
  colnames(data) <- paramsNames
  data <- rbind(rep(0,length(paramsNames)) , data)
  data <- rbind(maxValues , data)
  jpeg(file.path(graphFolder, paste("Radar Plot ", groupName, ".jpg", sep = "")))
  radarchart( data  , axistype=1, pfcol=color)
  dev.off()
}
plotParamData <- function(groupsNames, groupsParams, graphFolder, graphTitle) {
  numOfFlies = length(groupsParams[[1]][[1]])
  names = c()
  numbers = c()
  colors =c()
  for (i in 1:length(groupsNames)) {
    names = c(names, rep(groupsNames[i], length(unlist(groupsParams[i]))))
    numbers = c(numbers, rnorm(ceiling(length(unlist(groupsParams[i]))/numOfFlies)))
  }
  value = rapply(groupsParams, c)
  data = data.frame(names, value)
  data$names <- as.character(data$names)
  data$names <- factor(data$names, levels=unique(data$names))
  g <- qplot(x = names, y = value, data = data, geom = c("boxplot"),  fill=names , ylab = graphTitle, outlier.shape = NA)+theme_classic(base_size = font_size) 
  if(with_rgb == TRUE){  g <- g + scale_fill_manual(values=as.character(colors_of_groups$X1))
  }
  else{
    g <- g + scale_fill_manual(values=as.character(colors_of_groups$X1))
  }
  #
  #to see without the dots just comment this lines below
  #to plot in diffrent way the strenght ans betweenes
  if (numOfFlies > 1) {
    colors = rep(numbers, each = numOfFlies)
    g <- g + geom_jitter(width = 0.2, height = 0, aes(color = as.factor(colors[1:nrow(data)]))) + scale_colour_hue()
  } else {
    g <- g + geom_jitter(width = 0.2, height = 0)
  }
  #remove outlier do logscale
  g<-g +scale_y_continuous(trans = "log10")
  
  name_of_y = paste(graphTitle," In Log Scale")
  g<-g + labs(y = name_of_y) 
  g <- g + theme(legend.position="none")
  
  statsData <- getStatisticData(groupsParams, names, value, data)
  
  g <- addStatsToGraph(statsData, g, value, names, data)
  ggsave(filename = file.path(graphFolder, paste(graphTitle, " ", statsData[[2]], ".jpg", sep = "")), g, width = width, height = height, units = "cm")
  
  #_____delete param file

}

#________________________________________________________ main zone

#where we choosing the files we want for analysis
xlsxFile <- choose.files(default = "", caption = "Select expData_0_to_27000 file")
#all data is the data from the exel in the first sheet
allData <- read.xlsx(xlsxFile)
#reading the color excel
if(with_rgb==TRUE){
  allColorData <- read.xlsx(argv$path)
  num_of_pop<-nrow(allColorData)
}else{
  #test for myself
  library(openxlsx)
  allColorData <- as.data.frame(read.xlsx("D:/test/color.xlsx"))
  num_of_pop<<-nrow(allColorData)
}

if(with_rgb==TRUE){
  param_dir = tools::file_path_sans_ext(dirname((argv$path)))
  params<-data.frame()
  setwd(param_dir)
  params <- as.data.frame(read.xlsx("params.xlsx"))
  
}else{
  params<-data.frame()
  params <- as.data.frame(read.xlsx("D:/test/params.xlsx"))
  
}


height<<-params$height
width<<-params$width
font_size<<-params$font
astric_sts<<-params$asterisk
line_stat<<-astric_sts/6
if(params$delete == 1){
  unlink(argv$path)
}
#_________________________________________________________color zone

#creat zeros data frame with number of row is 1 and number of colum like the number of population
colors_of_groups<<-as.data.frame(lapply(structure(.Data=1:1,.Names=1:1),function(x) numeric(num_of_pop)))
#rgb and start from 2 because the first colom is names
for (i in 1:num_of_pop){
    colors_of_groups$X1[i]<-rgb_2_hex(allColorData[i,2:4])
}
colors_of_groups$X1<-factor(colors_of_groups$X1, levels = as.character(colors_of_groups$X1))

#_______________________________________________________________param zone
lengthParams <- c()
numberParams <- c()
numberOfMovies<-c()
print(dirname(xlsxFile))
setwd(dirname(xlsxFile))
for (i in 1:allData$Number.of.groups[1]) {
  cur <- (i + 1) * 2
  numberOfMovies[i]<- allData[i, 3]
  #the params are density, modularity, sdStrength, strength, betweenness
  lengthParams <- cbind(lengthParams, calculateGroupParams(allData[1:numberOfMovies[i], cur], 0))
  numberParams <- cbind(numberParams, calculateGroupParams(allData[1:numberOfMovies[i], cur + 1], allData$Max.number.of.interaction[1]))
}
#__________________________________________________arranging the names of folders
xlsxName <- tools::file_path_sans_ext(basename(xlsxFile))
xlsxParts <- strsplit(xlsxName, '_')
framesString <- paste(xlsxParts[[1]][2], "-", xlsxParts[[1]][4])
lengthFolder = file.path(dirname(toString(xlsxFile)), paste("Length of interactions graphs ", framesString));
dir.create(lengthFolder, showWarnings = FALSE)
numberFolder = file.path(dirname(toString(xlsxFile)), paste("Number of interactions graphs ", framesString));
dir.create(numberFolder, showWarnings = FALSE)
#parametrs name
paramsNames <- c("Density", "Modularity", "SD Strength", "Strength", "Betweenness Centrality")
groupsNames <- as.character(na.omit(allData$Groups.names))

#______________arrange the data to be generic
#five feature so from 1 to 6
length<-as.data.frame(lapply(structure(.Data=1:6,.Names=1:6),function(x) numeric(num_of_pop)))
number<-as.data.frame(lapply(structure(.Data=1:6,.Names=1:6),function(x) numeric(num_of_pop)))

for (i in 1:num_of_pop){ 
  lengthAvg<-paste0("lengthAvg",as.character(i))
  length[i,1]<-lengthAvg
}
for (i in 1:num_of_pop){ 
  numberAvg<-paste0("numberAvg",as.character(i))
  number[i,1]<-numberAvg
}


#_______________________________________________plot and save the varibels
for (i in 1:length(paramsNames)) {
  #the whole row i of lengthParams/numberParams
  plotParamData(groupsNames, lengthParams[i,], lengthFolder, paramsNames[i])
  plotParamData(groupsNames, numberParams[i,], numberFolder, paramsNames[i])

  #calculating the mean of each population
  for(j in 1:num_of_pop){
    length[j,i+1] <- mean(unlist(lengthParams[i,j]))
    number[j,i+1] <-mean(unlist(numberParams[i,j]))
    
  }

}

#___________________________________________________________Raderplot zone
#max varibles for raderplot for %
lengthMaxValues <- c(0.2,0.25,0.6,1.5,5)
numberMaxValues <- c(0.4,0.2,0.85,3.5,4)
#creation of raderplot
for (i in 1:num_of_pop){
  createRadarPlot(as.numeric(length[i,2:6]),paramsNames,lengthFolder,lengthMaxValues,groupsNames[i],rgb_2_hex(allColorData[i,2:4]))
}
for (i in 1:num_of_pop){
  createRadarPlot(as.numeric(number[i,2:6]),paramsNames,numberFolder,numberMaxValues,groupsNames[i],rgb_2_hex(allColorData[i,2:4]))
}

#____________________________ end of calculation,saving the varibles
densL<-as.numeric(as.data.frame(t(length[2])))
modL<-as.numeric(as.data.frame(t(length[3])))
sdL<-as.numeric(as.data.frame(t(length[4])))
strL <- as.numeric(as.data.frame(t(length[5])))
betL <- as.numeric(as.data.frame(t(length[6])))
densN <- as.numeric(as.data.frame(t(number[2])))
modN <- as.numeric(as.data.frame(t(number[3])))
sdN <- as.numeric(as.data.frame(t(number[4])))
strN <- as.numeric(as.data.frame(t(number[5])))
betN <- as.numeric(as.data.frame(t(number[6])))

if(params$delete == 1){
  unlink(argv$path)
}