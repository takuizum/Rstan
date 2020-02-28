data {
    int<lower = 0> N; // n ob subjects
    int<lower = 0> J; // n of items
    int<lower = 2> K[J];  // n of categories in each item
    int<lower = 0, upper = max(K)> Y[N, J];
}

parameters {
    vector[N] theta;
    real<lower = 0> alpha[J];
    ordered[max(K)-1] beta[J];
    // real mu_d;
    // real<lower = 0> sigma_d;
}

model {
    target += cauchy_lpdf(alpha | 0, 1);
    target += normal_lpdf(theta | 0, 1);
    for(j in 1:J){
        for(k in 1:(K[j]-1)){
            // d[j, k] ~ normal(mu_d, sigma_d);
            target += normal_lpdf(beta[j][k] | 0,2);
        }
    }
    // mu_d ~ normal(0, 5);
    // sigma_d ~ cauchy(0, 5);
    for(i in 1:N){
        for(j in 1:J){
            target += ordered_logistic_lpmf(Y[i,j] | alpha[j] * theta[i], alpha[j] * beta[j,1:(K[j]-1)]);  // logit(η - c)^-1
        }
    }
}

generated quantities{
    vector[J] log_lik[N]; 
    for(i in 1:N){
        for(j in 1:J){
            log_lik[i, j] = ordered_logistic_lpmf(Y[i,j] | alpha[j] * theta[i], alpha[j] * beta[j,1:(K[j]-1)]);
        }
    }
}
