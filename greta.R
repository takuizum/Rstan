# greta.R

# tensorflow
install.packages("tensorflow")
library(tensorflow)
tensorflow::install_tensorflow(extra_packages = "tensorflow-probability") 
tensorflow::use_python('/usr/local/anaconda3/bin/python')
reticulate::conda_install("r-tensorflow", "tensorflow-probability", pip = TRUE)

# install & library greta and marginal applocation
# git version
devtools::install_github("greta-dev/greta")
install.packages("greta")
install.packages("igraph")
install.packages("DiagrammeR")

# エラーが出た場合，https://qiita.com/Atsushi_/items/f10a6790972528682d25で解決できるかも。
# したのコードをコンソールに入力して，解決
#   .  ~/.virtualenvs/r-tensorflow/bin/activate 
# pip install -U tensorflow --user
# pip install -U tensorflow-probability  --user
install_tensorflow(method = "conda")
reticulate::conda_install("r-tensorflow", "tensorflow-probability", pip = TRUE)

library(greta)
install_tensorflow()
library(igraph)
library(DiagrammeR)

library(tidyverse)


# data set
dat <- read.csv("~/OneDrive/Documents/12_R/MML-EM/MML-EM/ngaku16.csv", header = F)
dat <- read.csv("C:/Users/sep10_z1vk0al/OneDrive/Documents/12_R/MML-EM/MML-EM/ngaku16.csv", header = F)
colnames(dat) <- c(0:25) %>% as.character()
n <- nrow(dat)
m <- ncol(dat)-1
dat$group <- c(rep(1,2000),rep(2,2549))


# prior
theta <- normal(0,1,dim=n)
b <- normal(0,3,dim=m)
a <- lognormal(0,1,dim=m)

# transformed input data
dat_greta <- dat %>% tidyr::gather(key=item,value=response,-"0",-group)
y <- as_data(dat_greta$response)
person <- dat_greta$"0" %>% factor() %>% as.integer()
item <- dat_greta$item %>% factor(levels = as.character(c(1:25))) %>% as.integer()

# transformed parametersm
P <- a[item]*(theta[person]-b[item]) # 実数をかけるのは無理そう。
l <- ilogit(P)
distribution(y) <- binomial(1,l)
# model
mod <- model(theta,a,b)

# plot Bayesian model
plot(mod)

# MCMC sampling(fit)
fit_greta <- mod %>% mcmc(n_samples = 1000, warmup = 200, chains=4, verbose = T)
summary(fit_greta)
bayesplot::mcmc_trace(fit_greta)


## stan
library(rstan)
model_stan <- stan_model("MG_IRT.stan")

dat_stan <- list(N=max(person), M=max(item), G=2, len=length(dat_greta$response),
                 response=dat_greta$response, person=person, item=item, group=dat_greta$group)
fit_stan <- sampling(model_stan, data = dat_stan, iter = 500, warmup = 100)

library(shinystan)
shinystan::launch_shinystan(fit_stan)
