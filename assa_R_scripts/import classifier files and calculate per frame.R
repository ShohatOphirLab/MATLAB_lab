require(R.matlab)
library(base)
setwd('G:/Elia/Males_females_N6/Females/Females_Singles') #where is the data folders

dir<-list.dirs(recursive = F)
print(dir)
allscore.df<-data.frame()
score.df<-data.frame()
totalscore.df<-data.frame()
finalavepermovie.df<-data.frame()

first<-T
for(k in 1:length(dir)){
  curr.dir<-(paste0(dir[k],'/')) 
  print(k)
  print(curr.dir)
  #find all that contains the word scores
  files<-list.files(path=paste0(curr.dir), pattern = 'scores')
  #print(files)
  avepermovie.df<-data.frame()
  first<-T
  #the number of scores there  is 11
   for(j in 1:length(files)){
      file<-readMat(paste0(curr.dir,'/',files[j])) #read each mat file
      score.df<-data.frame()
      #for each of the number of flies there is (10)
      for (i in 1:length(file$allScores[[4]])){
        #everytime overide the last temp.df
        tmp.df <- data.frame(dir=dir[k], files=files[j], fly=i, value=as.numeric(file$allScores[[4]][[i]][[1]])) # convert format of data for each fly
       # add to dataframe of one movie
        # calculate average per frame
         if (mean(tmp.df$value)!=0){
          scores.table<-(table(tmp.df$value))/(length(tmp.df$value)) #calculate frequency of behavior
          tmpflyscore.df<-data.frame(dir=dir[k], files=files[j], fly=i, values=(scores.table[2])) 
          score.df<-rbind(score.df, tmpflyscore.df)
          }
        else{
          tmpflyscore.df<-data.frame(dir=dir[k], files=files[j], fly=i, values=(scores.table[2])) 
          score.df<-rbind(score.df, tmpflyscore.df)
          }
      }
      if (first){
        avepermovie.df<-data.frame(dir=dir[k], file=files[j], value=mean(score.df$values))
      }
      else{
        tmp_avepermovie.df<-data.frame(dir=dir[k], file=files[j], value=mean(score.df$values)) #calculate average per movie
        avepermovie.df<-cbind(avepermovie.df, tmp_avepermovie.df) #add averages to one list
      }
     
      if (first){
        allscore.df<-score.df
        first<-F
      }
      else
        allscore.df<-cbind(allscore.df,score.df) # merge all files in each movie
     
      }
  totalscore.df<-rbind(totalscore.df, allscore.df) #merge all into one table according to file name
  finalavepermovie.df<-rbind(finalavepermovie.df, avepermovie.df)
      }

write.csv(totalscore.df, 'all_classifier_scores.csv', row.names = F)
write.csv(finalavepermovie.df, 'all_classifier_averages.csv', row.names = F)
