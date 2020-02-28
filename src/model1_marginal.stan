data {
    int<lower = 0> N; // n ob subjects
    int<lower = 0> J; // n of items
    int<lower = 2> K[J];  // n of categories in each item
    int<lower = 0, upper = max(K)> Y[N, J];
    int<lower = 1> M;
    vector[M] node;
    real prior[M];
}

// transformed data{
//     matrix[N, M] eap;
//     for(i in 1:N){
//         for(m in 1:M){
//             eap[i, m] = ln_prior[m];
//         }
//     }
// }

parameters {
    real<lower = 0> alpha[J];
    ordered[max(K)-1] beta[J];
}

transformed parameters{
    vector[N] lnp;
    for(i in 1:N){
        lnp[i] = 0.0;
        for(m in 1:M){
            for(j in 1:J){
                lnp[i] = lnp[i] + ordered_logistic_lpmf(Y[i,j] | alpha[j] * node[m], alpha[j] * beta[j,1:(K[j]-1)]) + log(prior[m]);
            }
        }
    }
}

model {
    target += lognormal_lpdf(alpha | 0, 4);
    for(j in 1:J){
        for(k in 1:(K[j]-1)){
            target += normal_lpdf(beta[j][k] | 0,3);
        }
    }
    for(i in 1:N){
        target += lnp[i];
    }
}

// generated quantities{
//     vector[J] log_lik[N]; 
//     for(i in 1:N){
//         for(m in 1:M){
//             for(j in 1:J){
//                 log_lik[i, m] = ln_prior[m] + ordered_logistic_lpmf(Y[i,j] | alpha[j] * node[m], alpha[j] * beta[j,1:(K[j]-1)]);
//             }
//         }
//     }
// }

