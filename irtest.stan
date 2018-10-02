// IRT in Rstan runnning test

data {
  int<lower = 1> N;  //subject
  int<lower = 1> M;  //items
  int y[N,M];  // observation
}

parameters{
  
  real theta[N];
  vector<lower=0, upper=5>[M] a;
  vector<lower=-5, upper=5>[M] b;
  
}

model{
  // 事前分布
  theta ~ normal(0, 1);
  a ~ lognormal(-0.5, 0.3);
  b ~ normal(0, 1);
  
  // model
  for(i in 1:N){
    for(k in 1:M){
      y[i,k] ~ bernoulli_logit(1.7*a[k]*(theta[i]-b[k]));
    }
  }
}
