
data {
  int N1;
  int N2;
  real Y1[N1];
  real Y2[N2];
}

// If sigma parameters is same, this code conducts student t test.
parameters {
  real mu1;
  real mu2;
  real<lower=0> sigma1;
  real<lower=0> sigma2;
}

model {
  for(n1 in 1:N1){
    Y1[n1] ~ normal(mu1, sigma1);
  }
  for(n2 in 1:N2){
    Y2[n2] ~ normal(mu2, sigma2);
  }
}

