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
  cholesky_factor_corr[V] L_Omega;
  vector<lower=0>[V] L_sigma;
}
transformed parameters 
{
  matrix[V,V] L_Sigma;
  L_Sigma <- diag_pre_multiply(L_sigma, L_Omega);
}
model
{
  # priors on the vector of multinormal means
  mu ~ normal(0,5);
  L_Omega ~ lkj_corr_cholesky(2);
  L_sigma ~ cauchy(0, 2.5);
  Y ~ multi_normal_cholesky(mu, L_Sigma);
}

generated quantities {
  vector[N] log_lik; 
  cov_matrix[V] Sigma;
  
  Sigma <- multiply_lower_tri_self_transpose(L_Sigma);
  for(i in 1:N) {
    log_lik[i] <-  multi_normal_log(Y[i], mu, Sigma);
  }
}