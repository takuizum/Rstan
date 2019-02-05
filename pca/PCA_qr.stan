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
  matrix[V, V] Z;
  vector<lower=0,upper = 2>[V] d_sqrt;
}
transformed parameters 
{
  cov_matrix[V] Sigma;
  matrix[V, V] Q;
  Q <- qr_Q(Z);
  Sigma <- crossprod(diag_post_multiply(Q, d_sqrt));
}
model
{
  mu ~ normal(0,5);
  //d_sqrt ~ cauchy(0, 2.5);
  to_vector(Z) ~ normal(0,10);
  Y ~ multi_normal(mu, Sigma);
}

generated quantities {
  vector[N] log_lik; 

  for(i in 1:N) {
    log_lik[i] <-  multi_normal_log(Y[i], mu, Sigma);
  }
}