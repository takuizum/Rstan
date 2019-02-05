library(rstan)
library(loo)
library(mnormt)
library(stats)
require(MASS)
require(Matrix)

# Diagonal: Matrix, ginv: MASS

data <- iris[,1:4]
N = nrow(data)
V = ncol(data)

covmat.prior = as.matrix(Diagonal(V, 1))
covmat.prior.DF = V
mu.prior = rep(0, V)
mu.prior.cov = as.matrix(Diagonal(V, 1))
n.chains = 3

  
mu.prior.prec = ginv(mu.prior.cov)

model_file <- '/Users/takuizum/Downloads/PCA.stan'
model_file <- 'PCA_cholesky.stan'
#model_file <- 'PCA_qr.stan'


smod  <-   stan_model(file=model_file)
 
pca_data <- list(Y = as.matrix(data), N = N, V = V, covmat_prior = covmat.prior, 
                  mu_prior = mu.prior, covmat_prior_DF = covmat.prior.DF, 
                  mu_prior_prec = mu.prior.prec)
time.stan <- system.time(
sa <- sampling(smod, data= pca_data, iter=1000, chains=3,init="random")  
) 
print(time.stan)
p <- extract(sa, inc_warmup=FALSE,permuted=FALSE)
log.lik <- extract_log_lik(sa)
loo(log.lik)

Nsamples <- 5000
Nchains <- 3
# stopifnot(sum(abs(as.vector(
#   diag(p$L_sigma[1,])%*% (p$L_Omega[1,,]%*%t(p$L_Omega[1,,]))%*%diag(p$L_sigma[1,]) -
#     p$Sigma[1,,]
#   )))<1e-10)
#   
log_lik<-extract(sa,"log_lik",permuted=FALSE)
dim(log_lik) <- c(Nsamples*Nchains,N)
stopifnot(sum(abs(as.vector(
  extract_log_lik(sa)-log_lik
)))<1e-10)

mu<-extract(sa,"mu",permuted=FALSE)
cov.mat <- extract(sa,"Sigma",permuted=FALSE)
dim(mu) <- c(Nsamples*Nchains,V)
dim(cov.mat)  <- c(Nsamples*Nchains,V*V)
ll.stan<-matrix(0,Nsamples*Nchains,N)
for(i in 1:(Nsamples*Nchains)) {
  cv<-matrix(cov.mat[i,],V,V)
  cv <- 0.5*(cv+t(cv))
  ll.stan[i,] <- dmnorm(data,mu[i,],cv,log=T)
}

stopifnot(any(apply(abs(log_lik - ll.stan),1,sum)<1e-10))

loo(log_lik)
