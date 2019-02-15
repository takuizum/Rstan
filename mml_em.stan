<<<<<<< HEAD
// IRT in Rstan runnning test

data {
  int<lower = 1> N;  // # of subjects
  int<lower = 1> J;  // # of items
  int<lower = 1> M;  // # of node
  int y[N, J];  // response vector
  vector [M] node; // nodes of theta
  vector [M] weight;  // log of weight 
}

transformed data{
  int x[N, J];
  vector [M] lnW;
  for(n in 1:N){
    for(j in 1:J){
      if(y[n, j] == 0) x[n, j] = 1;
      if(y[n, j] == 1) x[n, j] = 2;
    }
  }
  lnW = log(weight);
}

parameters{
  vector<lower=0>[J] a;
  vector[J] b;
}

transformed parameters{
  vector [N] lnL; // calculate log likelihood in each subjects
  for(n in 1:N){
    lnL[n] = 0;
    for(j in 1:J){
      for(m in 1:M){
        real Z = a[j] * (node[m] - b[j]);
        lnL[n] = lnL[n] + bernoulli_logit_lpmf(y[n,j] | Z ) + lnW[m]; 
        // '+=' is not able to use in transformed parameters block
      }
    }
  }
}

model{
  // prior dist
  a ~ lognormal(0, 1);
  b ~ normal(0, 3);
  target += sum(lnL);
}
=======
// IRT in Rstan runnning test

data {
  int<lower = 1> N;  // # of subjects
  int<lower = 1> J;  // # of items
  int<lower = 1> M;  // # of node
  int y[N, J];  // response vector
  vector [M] node; // nodes of theta
  vector [M] lnW;  // log of weight 
}

transformed data{
  int x[N, J];
  for(n in 1:N){
    for(j in 1:J){
      if(y[n, j] == 0) x[n, j] = 1;
      if(y[n, j] == 1) x[n, j] = 2;
    }
  }
}

parameters{
  vector<lower=0, upper=5>[J] a;
  vector<lower=-5, upper=5>[J] b;
}

transformed parameters{
  vector [N] lnL; // calculate log likelihood in each subjects
  for(n in 1:N){
    for(j in 1:J){
      for(m in 1:M){
        lnL[n] += bernoulli_logit_lpmf(y[n,j] | 1.702 * a[j] * (node[m] - b[j])); // incorrect
        lnL[n] += lnW[m];
      }
    }
  }
}

model{
  // prior dist
  a ~ lognormal(0, 1);
  b ~ normal(0, 3);
  for(n in 1:N){
    for(j in 1:J){
      for(m in 1:M){
        target += (bernoulli_logit_lpmf(y[n,j] | 1.702 * a[j] * (node[m] - b[j])) + lnW[m] );
      }
    }
  }
}
>>>>>>> a11ad9b48f0a1b395be76eae06061d6ce7e8c933