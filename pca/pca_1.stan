// Principal Component Analysis in Stan
data {
  int<lower=1> D; // the dimention of data
  int<lower=1> M; // the number of components
  int<lower=1> N;
  matrix[N,D] x; // data
  real sigma; // a hyper parameter
}

// The parameters accepted by the model. Our model
// accepts two parameters 'mu' and 'sigma'.
parameters {
  vector[M] mu;
  cov_matrix[M] sigma;
  real<lower=0> sigma;
  matrix[N, M] W; // latent variables weight matrix
  matrix[D, M] z; // latent variables matrix
}

transformed parameters {
  C = W%*%t(W) + sigma*sigma*
}

model {
  for(i in 1:N){
    for(j in 1:D)
  }
  y ~ normal(mu, sigma);
}

