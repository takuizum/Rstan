// IRT in Rstan runnning test

data {
    int<lower = 1> N;  //subject
    int<lower = 1> M;  //items
    int G; // group
    int y[N,M];  // observation
    int group[N];
}

parameters{
  
    real theta[N];
    vector<lower=0, upper=5>[M] a;
    vector<lower=-5, upper=5>[M] b;
    real mu_1 [G-1];
    real<lower=0> sigma_1 [G-1] ;
  
}

transformed parameters{
    real mu[G];
    real sigma[G] ;
    mu[1] = 0; // fixed parameter
    sigma[1] = 1;
    for(g in 2:G){
        mu[g] = mu_1[g-1];
        sigma[g] = sigma_1[g-1];
    }
}

model{
    // prior dist
    a ~ lognormal(0, 1);
    b ~ normal(0, 3);
    
    // model
    for(i in 1:N){
        int g = group[i];
        theta ~ normal(mu[g],sigma[g]);
        for(k in 1:M){
            y[i,k] ~ bernoulli_logit(a[k]*(theta[i]-b[k]));
        }
    }
}

