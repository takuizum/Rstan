// IRT in Rstan runnning test

data {
  int<lower = 1> N;  //subject
  int<lower = 1> M;  //items
  int y[N,M];  // observation

}

parameters{

  real<lower = -5, upper = 5> theta [N];
  real<lower = 0> a [M];
  real<lower = -5, upper = 5> b [M];
  real<lower = 0, upper = 1> c [M];

}

model{
  // prior dist
  a ~ cauchy(0, 1);
  b ~ normal(0, 3);
  c ~ beta(1, 3);
  theta ~ normal(0, 1);

  for(j in 1:M){
    for(i in 1:N){
      // if(y[i,j] == -1) continue;
      y[i,j] ~ bernoulli(c[j] + (1 - c[j]) * inv_logit(1.7 * a[j] * (theta[i] - b[j])));
    }
  }
}
