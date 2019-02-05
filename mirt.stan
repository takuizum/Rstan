// MIRT in stan

data{
  
}

parameters{
  
}

model{
  for(i in ni){
    for(d in nd){
      for(j in nj){
        y[n,j] ~ bernoulli_logit(1.7*a[])
      }
    }
  }
}
