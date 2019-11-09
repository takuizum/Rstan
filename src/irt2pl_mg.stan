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
  real mu_free[G - 1];
  real<lower = 0> sigma_free[G - 1];
}

transformed parameters{
  real mu[G];
  real sigma[G];
  mu[1] = 0;
  mu[2:G] = mu_free;
  sigma[1] = 1;
  sigma[2:G] = sigma_free;
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

