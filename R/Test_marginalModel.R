
library(rstan)
library(tidyverse)
library(irtfun2)
library(shinystan)

# ML result
res1 <- estip(sim_data_2, fc = 3)
res1$ms
res1$para$a
res1$para$b

# stan

mod1 <- stan_model("src/mml_em.stan")
node <- seq(-4, 4, len = 21)
lnw <- log(dnorm(node)/sum(dnorm(node)))
stan_data <- list(y = sim_data_2[,-1], N = 3000, J = 30, M = 21)

vb1 <- vb(mod1, data = stan_data, init = 1)
