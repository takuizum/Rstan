// IRT in Rstan runnning test

data {
  int<lower = 1> N;  //subject
  int<lower = 1> M;  //items
  int y[N,M];  // observation
}

parameters{
  
  vector<lower = -5, upper = 5> [N] theta;
  vector<lower=0, upper=5>[M] a;
  vector<lower=-5, upper=5>[M] b;
  
}


model{
  // prior dist
  a ~ lognormal(0, 1);
  b ~ normal(0, 3);
  theta ~ normal(0,1);
  // model
  for(i in 1:N){
    for(k in 1:M){
      // if(y[i,k] == -1) continue;
      y[i,k] ~ bernoulli_logit(1.702*a[k]*(theta[i]-b[k]));
    }
  }
}

