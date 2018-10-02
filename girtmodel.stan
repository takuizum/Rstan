// IRT in Rstan runnning test

data {
  int<lower = 1> N;  //subject
  int<lower = 1> M;  //items
  int G; // n of groups
  int<lower = 1, upper = G> group[N];  //group 
  int y[N,M];  // observation
}

parameters{
  
  real theta[N];
  vector<lower=0, upper=5>[M] a;
  vector<lower=-5, upper=5>[M] b;
  vector<lower=0, upper=5>[N] phi;
  vector<lower=-5, upper=5>[G] gmean;
  vector<lower=0, upper=5>[G] gsd;
  
}

model{
  // 事前分布
  a ~ lognormal(-0.5, 0.3);
  phi ~ lognormal(-0.5, 0.3);
  
  for(g in 1:G){
    theta ~ normal(gmean[g],gsd[g]);
    b~normal(gmean[g],gsd[g]);
  }
  
  // model
  for(i in 1:N){
    for(k in 1:M){
      y[i,k] ~ bernoulli_logit(1.7*a[k]/sqrt(1+phi[i]^2*a[k]^2)*(theta[i]-b[k]));
      //y[i,k] ~ 1/(1+exp(-1.7*a[k]/sqrt(1+phi[i]^2*a[k]^2)*(theta[i]-b[k])));
    }
  }
}
