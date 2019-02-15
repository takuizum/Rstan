# polytomous stan
library(tidyverse)

Y <- ltm::Science %>% purrr::map_df(as.integer)

stan_data <- list(N = nrow(Y), J = ncol(Y), Y = Y, K = 4)

mod1 <- stan_model("poly_girt.stan")

res1 <- sampling(mod1, data = stan_data, cores = 6, warmup = 2000, iter = 10000, control = list(adapt_delta = 0.99))

# vb
res2 <- vb(mod1, data = stan_data)

# result
library(shinystan)
launch_shinystan(res1)

res1 %>% rstan::extract() %>% purrr::map(as.matrix) %>% purrr::map(~apply(., 2, mean)) %>% head()
