
// The input data is a vector 'y' of length 'N'.
data {
  int N;
  int M;
  int G;
  int<lower=0> len;
  int response[len];
  int group[len];
  int person[len];
  int item[len];
}

parameters {
  real theta[N];
  vector<lower=0>[M] a;
  vector[M] b;
  //vector[G-1] mu;
  //vector[G-1] sigma;
  real mu [G];
  real<lower=0> sigma [G] ;
}

model {
    // prior dist
  a ~ lognormal(0, 1);
  b ~ normal(0, 3);
  //theta ~ normal(mu[group],sigma[group]);
  for(n in 1:len){
    int g = group[n];
    int i = person[n];
    int j = item[n];
    real m = mu[g];
    real s = sigma[g];
    theta ~ normal(m,s);
    
    response[n] ~ bernoulli_logit(a[j]*(theta[i]-b[j]));

  }
}

