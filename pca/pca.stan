data {
  int<lower = 0> V;
  int<lower = 0> N;
  vector[V] Y[N];
  vector[V] mu_prior;
  matrix[V,V] mu_prior_prec;
  real covmat_prior_DF;
  cov_matrix[V] covmat_prior;  
}
parameters {
  vector[V] mu;
  cov_matrix[V] prec;
}
model
{
  // priors on the vector of multinormal means
  mu ~ multi_normal_prec(mu_prior, mu_prior_prec);
  // priors on the covariance matrix
  prec ~ wishart(covmat_prior_DF, covmat_prior);
  
 // likelihood
  for (i in 1:N) {
    Y[i] ~ multi_normal_prec(mu, prec);
  }
}

generated quantities {
  vector[N] log_lik; 
  cov_matrix[V] Sigma;
  
  Sigma = inverse(prec);
  for (i in 1:N) {
    log_lik[i] = multi_normal_prec_lpdf(Y[i] | mu, prec);
  }
}
