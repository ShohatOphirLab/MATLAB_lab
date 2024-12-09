creat_network <- function(all,i,numbers) {
  library(dplyr)
  temp_between_values<-c()
  #find those that are bigger than the onset and small from the terminus
  #removed the = becuase it mixed intearction, i need to check it again
  temp_between_values<-all %>% filter(numbers[i+1]>onset & numbers[i] <=terminus)
  #if there is any rows at all
  if( nrow(temp_between_values)!=0){
    #changing the format to get "matrix" with who is in interaction with who
    #the massge so annoying,everytime it creat the matrix it notify
    
    values<-suppressMessages(acast(temp_between_values, tail~head,fun.aggregate=sum))
    #creat matrix in the size of 10 on 10 with 0 
    zero_matrix <- matrix(0, ncol = number_of_flys, nrow = number_of_flys)
    #all_values conation who is in intartcion with who in the spcific frame
    all_values<-acast(rbind(melt(values), melt(zero_matrix)), Var1~Var2, sum)
    net <- graph_from_adjacency_matrix(all_values,mode = "undirected")
    return(net)
  }
  else{
    warning("no interaction here FYI,returning empty matrix")
    zero_matrix <- matrix(0, ncol = number_of_flys, nrow = number_of_flys)
    #all_values conation who is in intartcion with who in the spcific frame
    net <- graph_from_adjacency_matrix(zero_matrix,mode = "undirected")
    return(net)
  }
}