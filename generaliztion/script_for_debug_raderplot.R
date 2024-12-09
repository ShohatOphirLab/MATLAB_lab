data <-as.numeric(number[1,2:6])
graphFolder<-lengthFolder
maxValues<-lengthMaxValues
groupName<-groupsNames[1]
test<-as.numeric(colors_of_groups)
comma_vec <- paste(test, collapse = ", ")
comma_vec

#color<-rgb(allColorData[1,1:3])


#data<-lengthAvg1
#graphFolder<-lengthFolder
#maxValues<-lengthMaxValues
#groupName<-groupsNames[1]
#color<-"#4DB3E6"
data <- as.data.frame(t(data))
colnames(data) <- paramsNames
data <- rbind(rep(0,length(paramsNames)) , data)
data <- rbind(maxValues , data)
jpeg(file.path(graphFolder, paste("Radar Plot ", groupName, ".jpg", sep = "")))
radarchart( data  , axistype=1, pfcol=color)
dev.off()