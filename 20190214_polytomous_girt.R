# polytomous stan
library(tidyverse)
library(rstan)
Y <- ltm::Science %>% purrr::map_df(as.integer)

stan_data <- list(N = nrow(Y), J = ncol(Y), Y = Y, K = 4)

mod1 <- stan_model("poly_girt.stan")

res1 <- sampling(mod1, data = stan_data, cores = 6, warmup = 200, iter = 1000, control = list(adapt_delta = 0.99))

# vb
res2 <- vb(mod1, data = stan_data)

# result
library(shinystan)
launch_shinystan(res1)

# map function
map <- function(z){ 
  density(z)$x[which.max(density(z)$y)] 
}

# other of d
res1_ex <- res1 %>% rstan::extract()
res1_ex %>% purrr::map(as.matrix) %>% purrr::map(~apply(., 2, mean))

# a
a <- res1 %>% rstan::extract() %$% a %>% apply(2, mean)
# d
print(res1, pars = c("d"))
beta <- res1 %>% rstan::extract() %$% d %>% apply(c(2,3), mean)

theta <- res1 %>% rstan::extract() %$% theta %>% apply(2, mean)
phi <- res1 %>% rstan::extract() %$% phi %>% apply(2, mean)

cor(theta, phi)
plot(theta, phi)
