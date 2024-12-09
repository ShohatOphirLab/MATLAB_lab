require(R.matlab)
library(base)
library(openxlsx)
library(igraph)
library(ggplot2)
library(cowplot)
library(ggpubr)
library(ggsignif)
library(nortest)
library(fmsb)
library("dplyr")
library(argparser, quietly=TRUE)
library(stringr)
library("readxl")
library(progress)

num_of_pop<-0
colors_of_groups<<-data.frame()
with_rgb = TRUE

dot<-0
xsize<-0
font_size<-0
width<-0
height<-0
toDelete<-0
type_format<-0
num_of_movies =0

groupsNames <- c()
xlsxFile<-c()


#to debug if i want to run and see the var
if (with_rgb == TRUE){
  
  p <- arg_parser("path of the color")
  # Add command line arguments
  p <- add_argument(p,"path",
                    help = "path",
                    flag = FALSE)
  
  # Parse the command line arguments
  argv <- parse_args(p)
  
}

rgb_2_hex <- function(r,g,b){
  return(rgb(r, g, b, maxColorValue = 1))}



vizual<-function(){
  library("readxl")
  library(openxlsx)
  temp.df<-data.frame()
  all.df<-data.frame()
  
  if(with_rgb==TRUE){
    allColorData <- read.xlsx(argv$path)
    num_of_pop<<-nrow(allColorData)

  }else{
    allColorData <- as.data.frame(read.xlsx(debbug_path_color))
  }

  color_border_hex<-rgb_2_hex(border_color[1,2:4])
  
  
  colors_of_groups<-as.data.frame(lapply(structure(.Data=1:1,.Names=1:1),function(x) numeric(num_of_pop)))
  #rgb and start from 2 because the first colom is names
  for (i in 1:num_of_pop){
    colors_of_groups$X1[i]<-rgb_2_hex(allColorData[i,2:4])
  }

  for(i in 1:num_of_pop){
    colors_of_groups$name[i]<-basename(allColorData$groupNameDir[i])
  
  }
  
  
  colors_of_groups$X1<-factor(colors_of_groups$X1, levels = as.character(colors_of_groups$X1))
  
  ##### hadar
 # param_dir <- "F:/hadar/GH/together/"
  if(with_rgb==TRUE){
    param_dir = tools::file_path_sans_ext(dirname((argv$path)))
    params<-data.frame()
    setwd(param_dir)
    params <- as.data.frame(read.xlsx("params.xlsx"))
    
  }else{
    params<-data.frame()
    params <- as.data.frame(read.xlsx(debbug_path_param))
    
  }
  
  library(ggplot2)
  library(gridExtra)
  all_colors<-as.character(colors_of_groups$X1)
  
  names_for_color<- as.character(colors_of_groups$name)
  
  names(all_colors)<-names_for_color
  #full_title = paste(name1,"vs",name2)
  all.df<-data.frame()
  order_name<-c()
  #getting the dir and fininding the avg per con itself
  path_to_avg_per_con<-allColorData$groupNameDir
  full_path_avg_per_con<-paste0(path_to_avg_per_con,"\\","averages per condition.csv")
  #when I will want to creat in certin order or only spcific features
  #path_to_order_name<-paste0(((path_to_avg_per_con[1])),"\\","order.xlsx")
  ####### hadar
  #path_to_order_name<-"F:/hadar/GH/together/order.xlsx"
  #to change for spcific just change here to path_to_order_name
  order_name<-as.data.frame(read_excel(paste(dirname(path_to_avg_per_con[1]),"\\","order.xlsx",sep ="")))
 # order_name<-as.data.frame(read_excel("D:/MATLAB/flybowl_general/forscatter/order.xlsx"))
  

  library(dplyr)
  
  for(i in 1:num_of_pop){
    groupName <- tools::file_path_sans_ext(basename(dirname(full_path_avg_per_con[i])))
    temp.df<-as.data.frame(read.csv(full_path_avg_per_con[i]))
   # temp.df$file<-gsub("Aggregation", "Social Clustering", temp.df$file)
    #temp.df$file<-gsub("Interaction_Assa", "Approach", temp.df$file)
    temp.df$file<-gsub("Social_Clustering", "Social Clustering", temp.df$file)
    temp.df$file<-gsub("Long_Distance_Approach", "Long Distance Approach", temp.df$file)
   # temp.df$file<-gsub("sort_distance_approach", "Short Distance Approach", temp.df$file)
    
    
    name = groupName
    number_of_movies =length(list.dirs(path=dirname(full_path_avg_per_con[i]), full.names=T, recursive=F ))
    temp.df$id =name
    #the part from SD TO SE
    temp.df$Variance=temp.df$Variance/(sqrt(number_of_movies))
    temp.df$file<-tools::file_path_sans_ext(temp.df$file)
    ## hadar
    temp.df$file<- str_replace(temp.df$file, "scores_", "")
    
    temp.df$file<- str_replace(temp.df$file, "_", " ")
    
    temp.df$file<- str_replace(temp.df$file, "distance_", "distance ")
    
    order_name$file<- str_replace(order_name$file, "_", " ")
    
    
    
    #temp.df$file<-gsub("Aggregation", "Social Clustering", temp.df$file)
    #temp.df$file<-gsub("Interaction_Assa", "Approach", temp.df$file)
    
    # temp.df$file<-gsub("Social_Clustering", "Social Clustering", temp.df$file)
    # temp.df$file<-gsub("Long_Distance_Approach", "Long Distance Approach", temp.df$file)
   # temp.df$file<-gsub("sort_distance_approach", "Short Distance Approach", temp.df$file)
    
    temp.df<-semi_join(temp.df, order_name, by = "file")
    #to check if something is missing
    #test<-anti_join(temp.df, order_name, by = "file")
    order_name<-semi_join(order_name, temp.df, by = "file")
    temp.df$file<-as.character(temp.df$file)
    order_name$file<-as.character(order_name$file)
    temp.df$file <- factor(temp.df$file, levels=order_name$file)
    all.df <- rbind(all.df, temp.df)
  }
  t <- ggplot(all.df, aes(x=value, y=file, group=id, color=id))
  t<- t+geom_point(size =dot)
  t<-t+ geom_point(shape = 1,size = dot,colour = color_border_hex)

  t<-t+ scale_color_manual(values =all_colors)
  t<-t+ geom_pointrange(mapping=aes(xmax=value+Variance, xmin=value-Variance), size=0.08)+
    xlim(-(xsize),(xsize))+theme_minimal(base_size = font_size)
  paths<-((choose.dir(caption = "Select folder for saving the scatter plot")))
  if(type_format==1){
    
    pdf(file = paste(paths,"/","scatterplot.pdf",sep=""), height=height, width=width)
    plot(t)
    dev.off()
  }
  if(type_format==2){
    jpeg( filename = paste(paths,"/","scatterplot.jpeg",sep=""), height=height, width=width,units = "in",res=400)
    plot(t)
    dev.off()

  }
  ## hadar
  if(type_format==3){
    library(svglite)
    #jpeg( filename = paste(paths,"/","scatterplot.jpeg",sep=""), height=height, width=width,units = "in",res=400)
   # Cairo(800,400,file=paste(paths,"/", ".svg", sep=""),type="svg",bg="transparent",height=height, width=width,units = "in",res=400)
    ggsave(file=paste(paths,"/", "scatterplot.svg", sep=""), plot=t, width=width, height=height)
    plot(t)
    dev.off()
    
  }
  
}



#EXTRACTION AND USER INPUT TO LIST OF DIRS
############################################################################################################


debbug_path_color<-"D:/Dekel/day9/together/males/color.xlsx"
debbug_path_param<-"D:/Dekel/day9/together/males/params.xlsx"
debbug_path_border<-"D:/Dekel/day9/together/males/border_color.xlsx"
#the path that have all the scripts in

path_to_scripts<-"D:/MATLAB/runAll/scatterPlot/scatter_source"

#sainity check # 3 trues
if(with_rgb==FALSE){
  print("this only need to bbe true in debug mode")
  file.exists(debbug_path_color)
  file.exists(debbug_path_param)
  file.exists(debbug_path_border)
}


if(file.exists(path_to_scripts)){
  print("path to scritps do exist")
}


if(with_rgb==TRUE){
  #reading from the path the color values
  #check if exist
  file.exists(argv$path)
  allColorData <- read.xlsx(argv$path)
  num_of_pop<<-nrow(allColorData)
  #reading the params from the exel
  param_dir = tools::file_path_sans_ext(dirname((argv$path)))
  setwd(param_dir)
  params<-data.frame()
  params <- as.data.frame(read.xlsx("params.xlsx"))
  border_color<-as.data.frame(read.xlsx("border_color.xlsx"))
  
}else{
  #test for myself
  library(openxlsx)
  allColorData <- as.data.frame(read.xlsx(debbug_path_color))
  num_of_pop<<-nrow(allColorData)
  params<-data.frame()
  params <- as.data.frame(read.xlsx(debbug_path_param))
  border_color <- as.data.frame(read.xlsx(debbug_path_border))
  
}

dot<-params$dot
xsize<-params$xsize
font_size<-params$font
width<-params$width
height<-params$height
vizual_or_run<-params$change
type_format<-params$format
toDelete<-params$deleted

if(with_rgb == FALSE){
  warning("you are in debug mode")
}

#choose the expData file for the network values
xlsxFile <<- choose.files(default = "", caption = "Select expData file")





#to read the group names in the wanted order
groupsNames <<- as.character(basename(allColorData$groupNameDir))
##test to prevent error of calculating
#GET THE ORDER OF NAMES THAT WANTED WITH THE CALCULATION OF NETWORK
xlsxFileRead<-read_excel(xlsxFile)

namesOfGroupsFromxlsx<-data.frame()
namesOfGroupsFromxlsx<-as.data.frame(colnames(xlsxFileRead))

#from the 4th place until how many pop they are is 
namesOfGroupsFromxlsx<-as.data.frame(namesOfGroupsFromxlsx[4:(3+num_of_pop*2),1])

#creat list of dirs 
dir=as.data.frame(lapply(structure(.Data=1:1,.Names=1:1),function(x) numeric(num_of_pop)))
for (i in 1:num_of_pop){
  dir[i,1]<-allColorData$groupNameDir[i]
  dir[i,1]<-str_trim(dir[i,1], side = c("right"))
}

dir$X1<-gsub("\\\\", "/", dir$X1)
for(i in 1:num_of_pop){
  if(dir.exists(dir[i,1])){
    print("exist!!")
  }else{
    stop(paste(dir[i,1]," dir don't exist"))
  }
}



#getting the real order
colnames(namesOfGroupsFromxlsx)<-c("groupname")
namesOfXlsx<-gsub("^(\\S+)\\s+(.*)", "\\1", namesOfGroupsFromxlsx$groupname)
#this is the part that removes the number of interaction dir
namesOfXlsx<-namesOfXlsx[duplicated(namesOfXlsx)]

#TEST NEED TO BE TRUE
if(!nrow(dir) == num_of_pop){
  stop("something off with the color file data ")
}
#check from the 4th place

#check on each one from expdata is iin the same order as the group the user choose
#by useing grep i check the iif true 

#fix - not stop if the order incorrect - need to see if it is imprtant
output<-0
for(i in 1:num_of_pop){
  output<-grep(paste0("^.*", groupsNames[i], ".*$"), namesOfGroupsFromxlsx[i*2,1])
  print(output)
  if(length(output) !=1){
        warning(("the order should be: "))
        warning(paste(" ",namesOfXlsx))
        warning("you choose not in the right order!please check the correct order as you choose in expdata")
  }
}


#sub scripts
setwd(path_to_scripts)
files.sources = list.files()
sapply(files.sources, source)
####BAR GRAPH


number_of_operation<-(5*num_of_pop)+4
current_index<-0

pb <- winProgressBar(title = "Window progress bar", # Window title
                     label = "Percentage completed", # Window label
                     min = 0,      # Minimum value of the bar
                     max = number_of_operation, # Maximum value of the bar
                     initial = 0,  # Initial value of the bar
                     width = 300L) # Width of the window 


  #####COMPUTATION
#####################################################################################

#### the actuall run (if the user choose to run from the start)
if(vizual_or_run == 1){
  #CALCULATING THE PARAMS FOR ALL THE POPULATION TOGETHER
  Listedparams<-calculating_netWorkParams_all_Groups(dir[1,1],path_to_scripts,xlsxFile,argv,debbug_path_color,with_rgb)
  lengthParams<- as.data.frame(Listedparams[1])
  numberParams<- as.data.frame(Listedparams[2])
  current_index<- windowBar(current_index,pb,number_of_operation,path_to_scripts)

  for (i in 1:num_of_pop){
    #for each population i get the group name the number for movies and running 
    setwd(dir[i,1])
    averagesPerMovieByFile(dir[i,1],path_to_scripts)
   current_index<- windowBar(current_index,pb,number_of_operation,path_to_scripts)
    importClassifierFilesAndCalculatePerFrame(dir[i,1],path_to_scripts)
   current_index<- windowBar(current_index,pb,number_of_operation,path_to_scripts)
   #hadar
   # boutLengthAndFrequencyForClassifiers(dir[i,1],path_to_scripts)
    current_index<- windowBar(current_index,pb,number_of_operation,path_to_scripts)
    netWorkParamsCalcuPerGroup(dir[i,1],i,path_to_scripts,lengthParams,numberParams,xlsxFile,num_of_pop,FALSE)
    current_index<- windowBar(current_index,pb,number_of_operation,path_to_scripts)
  }

##############################################
  ###########STATS
  mainStat(dir,xlsxFile,path_to_scripts,groupsNames,lengthParams,numberParams,num_of_pop)
  current_index<- windowBar(current_index,pb,number_of_operation,path_to_scripts)
  

  ############SCALE

  #first stat than scalling
  #doing scaleing and for the other features that are not network it override the data in the csv file
  #to be the scaled data
  mainScale(dir,xlsxFile,path_to_scripts,groupsNames,lengthParams,numberParams,num_of_pop)
  current_index<- windowBar(current_index,pb,number_of_operation,path_to_scripts)
  

  
  for(i in 1:num_of_pop){
    #for each net there is different valus 
    setwd(dir[i,1])
    combineKineticAndClassifiersToSignature(dir[i,1],path_to_scripts)
   current_index<- windowBar(current_index,pb,number_of_operation,path_to_scripts)
    
  }
  
  vizual()
  current_index<- windowBar(current_index,pb,number_of_operation,path_to_scripts)
  #closeing progress bar
  close(pb)
  
  if(toDelete == 1){
    if(with_rgb==TRUE){
      
      # delete a file of color but not the values params 
      unlink(param_dir)
      
    }
    else{
      unlink(debbug_path_param)
    }
  }
 
}

if(vizual_or_run == 2){
  #only change vizual,we have averages per condition.csv after computation
  vizual()
  if(toDelete == 1){
    if(with_rgb==TRUE){
      
      # delete a file of color but not the values params 
      unlink(param_dir)
      
    }
    else{
      unlink(debbug_path_param)
    }
  }
  
  close(pb)
  
  
}


