# polytomous stan
library(tidyverse)
library(rstan)
library(ltm)
Y <- ltm::Science %>% purrr::map_df(as.integer)
grm(ltm::Science)

stan_data <- list(N = nrow(Y), J = ncol(Y), Y = Y, K = 4)

# polytomous GIRT model
mod1 <- stan_model("poly_girt.stan")

res1 <- sampling(mod1, data = stan_data, cores = 6, warmup = 200, iter = 1000, control = list(adapt_delta = 0.99))
res1 <- vb(mod1, data = stan_data, init = 1)
summary(res1)$summary %>% View

res1 <- estgrm_stan(y = Y, infer = "VB")
res1 %>% rstan::extract() %$% d %>% apply(2, mean) %>% hist
# vb
res2 <- vb(mod1, data = stan_data)

# result
library(shinystan)
launch_shinystan(res1)

# map function
map <- function(z){ 
  density(z)$x[which.max(density(z)$y)] 
}

# a
a <- res1 %>% rstan::extract() %$% a %>% apply(2, mean)
# d
print(res1, pars = c("d"))
beta <- res1 %>% rstan::extract() %$% b %>% apply(c(2,3), mean)

theta <- res1 %>% rstan::extract() %$% theta %>% apply(2, mean)
phi <- res1 %>% rstan::extract() %$% phi %>% apply(2, mean)

cor(theta, phi)
plot(theta, phi)


grm_sub <- function(theta, a, b, D, k){
  pk <- dplyr::if_else(condition = (k>1),
                       true = (1+exp(-D*a * (theta - b[k])))^(-1),
                       false = 1)
  pk1 <- dplyr::if_else(condition = (k < length(b)), 
                        true = (1+exp(-D*a * (theta - b[k+1])))^(-1),
                        false = 0)
  pk - pk1
}

grm <- function(theta, a, b, D = 1.702, k){
  apply(as.matrix(theta), 1, grm_sub, a = a, b = b, D = D, k = k)
}

grm(-1, a[1], beta[1,], k = 1)

j <- 6
data.frame(theta = c(-4:4)) %>% ggplot(aes(x = theta))+
  stat_function(fun = grm, args = list(a = a[j], b = beta[j,], k = 1))+
  stat_function(fun = grm, args = list(a = a[j], b = beta[j,], k = 2))+
  stat_function(fun = grm, args = list(a = a[j], b = beta[j,], k = 3))
  
