biggest_cc_subgraph<-function(net){
  
  components <- igraph::clusters(net)
  if(max(components[["csize"]])>=3){
    biggest_cluster_id <- which.max(components$csize)
    vert_ids <- V(net)[components$membership == biggest_cluster_id]
    current_graph<-(igraph::induced_subgraph(net, vert_ids))
    return(c(list(current_graph),TRUE))
  }else{
    return(c(list(net),FALSE))
  }

}