data {
  int<lower = 1> N;  // # of subjects
  int<lower = 1> J;  // # of items
  int<lower = 1> M;  // # of node
  int y[N, J];  // response vector
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
  target += lnL;
}
