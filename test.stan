library(rstan)

data{
  int N;
  real Y[N];
}

parameters {
  real mu;
}

model {
  for (n in 1:N){
    Y[n] ~ normal(mu, 1);
  }
  mu ~ nomal(0, 100);
}


