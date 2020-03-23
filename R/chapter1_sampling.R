library(rstan)
library(shinystan)
library(tidyverse)
set.seed(123)
N1 <- 30
N2 <- 20
Y1 <- rnorm(N1, 0, 5)
Y2 <- rnorm(N2, 1, 4)

data_1 <- list(Y1=Y1, Y2=Y2, N1=N1, N2=N2)

# compile
model_1 <- stan_model("src/chapter1.stan")

mc_1 <- model_1 %>% sampling(data=data_1)

# shiny stan
mc_1 %>% launch_shinystan()

mc_1_extract <- mc_1 %>% rstan::extract()

mu_diff <- (mc_1_extract$mu1 - mc_1_extract$mu2) < 0
sum(mu_diff) / length(mu_diff)

# output result
summary(mc_1)$summary %>% write.csv(file="mc-result.csv", quote=F)
