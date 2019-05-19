# IRTにおける多母集団モデルのパラメタ推定を，階層モデルによって代替できるかどうかの実験

library(rstan)
library(tidyverse)
library(irtfun2)
library(shinystan)

# ML result
res1 <- estip(sim_data_4, fc = 3, ng = 3)
res1$ms
res1$para$a
res1$para$b


mod1 <- stan_model('irt2pl_mg.stan') # stan model input
stan_data <- list(y = sim_data_4[,c(-1, -2)], group = sim_data_4$group, N = 9000, J = 30, G = 3)

# variational Bayes
fit1 <- vb(mod1, data = stan_data)

rstan::extract(fit1) %$% mu %>% apply(2, mean)
rstan::extract(fit1) %$% sigma %>% apply(2, mean)
rstan::extract(fit1) %$% a %>% apply(2, mean)
rstan::extract(fit1) %$% b %>% apply(2, mean)

# full sampling
fit2 <- sampling(mod1, data = stan_data, warmup = 300, iter = 1000, cores = 4)
fit2_para <- rstan::summary(fit2, pars = c("a", "b", "mu", "sigma")) %$% summary


launch_shinystan(fit2)

# classical diagnose
all(summary(fit2)$summary[,"Rhat"]<1.10)


tibble::tibble(x = c(0:4)) %>% ggplot(aes(x = x)) + 
  stat_function(fun = dlnorm, args = list(meanlog = 0, sdlog = 1))

tibble::tibble(x = c(0:4)) %>% ggplot(aes(x = x)) + 
  stat_function(fun = dcauchy, args = list(location = 0, scale = 2.5))
