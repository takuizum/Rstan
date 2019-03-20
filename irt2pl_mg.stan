data {
  int<lower = 1> N;
  int<lower = 1> J;
  int<lower = 1> G; //group index
  int y[N, J] ;
  int group[N]; // group index vector
}

parameters {
  real<lower = 0> a[J];
  real b[J];
  real theta[N];
  real mu[G];
  real<lower = 0> sigma[G];
}

model {
  
  // prior
  a ~ cauchy(0, 1);
  b ~ normal(0, 3);
  
  for(i in 1:N){
    theta[i] ~ normal(mu[group[i]], sigma[group[i]]);
    for(j in 1:J){
      y[i, j] ~ bernoulli_logit(1.702 * a[j] * (theta[i] - b[j]));
    }
  }

}

