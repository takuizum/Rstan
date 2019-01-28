install.packages(c('rstan', 'shinystan'))
#　これのほかに，Rtoolsのインストールが必須。
#　きちんとインストールができているかは，以下のコマンドを実行すれば確認できる。
system('g++ -v')



library(rstan)

# example stan code

#　stanの文法はdata, parameters, modelの3層が基本，
#　松浦健太郎（2016）「StanとRで統計モデリング」によればmodel -> data -> parametersの順で書くと良いらしい。
#　しかし肝心なのは，stanコードのブロックの順番は固定されている点である。いくら書きやすいからといって，好き勝手な順番にしてはならない。

#　stanコードは基本的にRのコードとは別のファイルに保存しておくのが良いらしい。


# generate sample data
model_data <- stan_model('data.stan')
datarandom <- list(M=30, a=a, b=b)

simdata <- sampling(model_data, data=datarandom, iter = 400, warmup=0, chains=1)

data <- as.data.frame(rstan::extract(simdata)$y)
theta_true <- as.data.frame(rstan::extract(simdata)$theta)


# dichotomous response pattern 
model_resp <- stan_model('data.stan')



# stan model
# compile
model_2PL <- stan_model("irtest.stan")  # multi group irt
model_2PL_em <- stan_model("mml_em.stan")  # marginal ML
model_2PL_jm <- stan_model("jml.stan")  # joint ML


# simulation data
dat <- read.csv("~/OneDrive/Documents/12_R/MML-EM/MML-EM/ngaku16.csv", header = F)

datastan <- list(N=400, M=30, y=data)
group <- c(rep(1,2000),rep(2,2549))

# joint ml
datastan <- list(N = 4549, M = 25, y=dat[,-1])

# mml_em
node <- seq(-4, 4, length.out = 21)
weight <- log(dnorm(seq(-4, 4, length.out = 21)) / sum(dnorm(seq(-4, 4, length.out = 21))))
datastan <- list(N = 4549, J = 25, M = 21, y=dat[,-1], node = node, lnW = weight)

system.time(
  res_vb <- vb(model_2PL_em, data = datastan)
)


system.time(
  res_2PL <- sampling(model_2PL, data = datastan, iter = 1000, warmup = 200, init = 0)
)
shinystan::launch_shinystan(res_2PL)

# どうもこの位サンプリング数では，収束し切れていない模様?。繰り返しをもっと増やしてみよう。

system.time(
  res <- sampling(model_2PL, data = datastan, iter = 2000, warmup = 500, init = 0,　cores=4)
)

# 豊田（2008）ではバーンイン(burn-in, warm-up)を1000回，サンプリングを10000回と設定していた。これにしたがって設定を変えてみよう。

system.time(
  res <- sampling(model_2PL, data = datastan, iter = 11000, warmup = 1000, init = 0,　cores=4)
)


# MMLEMとパラメタが食い違う原因は，事前分布かもしれない。事前分布を無情報にして推定してみよう。

system.time(
  res <- sampling(model_2PL, data = datastan, iter = 800, warmup = 200, init = 0, cores = 4)
)


library(tidyverse)
print(res, pars = c('a', 'b'))

mc_a <- rstan::extract(res)$a %>% apply(2,mean)
mc_b <- rstan::extract(res)$b %>% apply(2,mean)


library(shinystan)
launch_shinystan(res)



# IRT用のラッパーがあるらしいので，そちらも使ってみよう。

library(edstan)
rstan_options(auto_write = TRUE)


# generate simulation response patterns
theta <- rnorm(1000, 0,1)
a <- rlnorm(30, -0.5, 0.5)
b <- rnorm(30,0,1)
resp <- theta %>% 
  matrix(ncol = 1) %>% 
  apply(1,ptheta, a = a, b = b) %>% 
  apply(2,resfunc) %>% 
  t() %>% 
  as.data.frame() 


datastan <- list(N=1000, M=30, y=resp)

X <- resp


# 一般項目反応モデルの構築
hist(sqrt(rchisq(100000,3,1))^(-1), breaks = 1000,xlim = c(0,5))
# 複雑だし，イメージしにくいので，対数正規分布でなんとか置き換えたい。
hist(rlnorm(100000,-0.5,0.3), breaks = 1000,xlim = c(0,5))
# いい感じの分布が仕上がった。


# 2PLM
model_2PL <- stan_model("irtest.stan")
res_2PL <- sampling(model_2PL, data = datastan, iter = 1000, warmup = 200, init = 0)
res_2PL
# Rhat = 収束確認用の値，1.10以下であればよい
all(summary(res_2PL)$summary[,"Rhat"]<1.10)
#stan_hist(res_2PL)
#install.packages("shinystan")
library(shinystan)
launch_shinystan(res_2PL)
# 単に推定したパラメタを持ってきたいだけなら，MCMCサンプルの平均をとればよい
res_2PL_a <- rstan::extract(res_2PL)$a %>% apply(2,mean)
res_2PL_b <- rstan::extract(res_2PL)$b %>% apply(2,mean)

a - res_2PL_a
b - res_2PL_b
# ずれは結構大きい。


library(Rcpp)
sourceCpp("C:/Users/sep10_z1vk0al/OneDrive/Documents/12_R/MML-EM/MML-EM/MML-EM_Rcpp.cpp")
res_2PLEM <- MML_EM_cpp(resp, fc=1, gc=0)
res_2PLEM$para

a - res_2PLEM$para$a
b - res_2PLEM$para$b
# 事前分布の指定によって，結構値は変わるが，適切な事前分布が指定できれば，かなりいい感じで推定できていそう。


# generalized item response model
datastan <- list(N=1000, M=30, y=resp)
model_G2PL <- stan_model("girtmodel.stan")
res_G2PL <- sampling(model_G2PL, data = datastan, iter = 1000, warmup = 200, init = 0)
res_G2PL@model_pars
all(summary(res_G2PL)$summary[,"Rhat"]<1.10)

library(tidyverse)
rstan::extract(res_G2PL)$theta %>% apply(2,mean)
rstan::extract(res_G2PL)$phi %>% apply(2,mean)
res_G2PL_a <- rstan::extract(res_G2PL)$a %>% apply(2,mean)
res_G2PL_b <- rstan::extract(res_G2PL)$b %>% apply(2,mean)


#  visualization
library(ggplot2)

# scatter plot
para_a <- data.frame(ID = 1:30, true = a, stan_2pl = res_2PL_a, stan_g2pl = res_G2PL_a, mml_2pl = res_2PLEM$para$a)
para_b <- data.frame(ID = 1:30, true = b, stan_2pl = res_2PL_b, stan_g2pl = res_G2PL_b, mml_2pl = res_2PLEM$para$b)

para_a %>% tidyr::gather(key=method, value=parameter, -ID) %>% cbind(true=para_a$true) %>% 
ggplot(aes(x=true, y=parameter, colour = method)) +
  facet_grid(.~method) +
  geom_point() + xlim(0,1.5) + ylim(0,1.5) +
  geom_smooth(method = "lm")
  

para_b %>% tidyr::gather(key=method, value=parameter, -ID) %>% cbind(true=para_b$true) %>% 
  ggplot(aes(x=true, y=parameter, colour = method)) +
  facet_grid(.~method) +
  geom_point() + xlim(-2,3) + ylim(-2,3) +
  geom_smooth(method = "lm")

# differential plot

para_a_diff <- data.frame(ID = 1:30, stan_2pl = res_2PL_a-a, stan_g2pl = res_G2PL_a-a, mml_2pl = res_2PLEM$para$a-a)
para_b_diff <- data.frame(ID = 1:30, stan_2pl = res_2PL_b-b, stan_g2pl = res_G2PL_b-b, mml_2pl = res_2PLEM$para$b-b)

para_a_diff %>% tidyr::gather(key = method, value=diff, -ID) %>% 
  ggplot(aes(x=ID, y=diff, colour=method)) +
  facet_grid(.~method) +
  geom_point() + 
  geom_hline(yintercept = 0, linetype="dashed")

para_b_diff %>% tidyr::gather(key = method, value=diff, -ID) %>% 
  ggplot(aes(x=ID, y=diff, colour=method)) +
  facet_grid(.~method) +
  geom_point() + 
  geom_hline(yintercept = 0, linetype="dashed")



#######
# 周辺ベイズのと比較

system.time(
  res_2PL_mcmcb <- sampling(model_2PL, data = datastan, iter = 1000, warmup = 200, init = 0)
)
mc_a <- rstan::extract(res_2PL_mcmcb)$a %>% apply(2,mean)
mc_b <- rstan::extract(res_2PL_mcmcb)$b %>% apply(2,mean)

library(irtfun2)
res_2PL_mrgb <- datastan$y %>% estip(model="2PL", fc=1, Bayes = 1)
res_2PL_mrgb

res_2PL_mrgb$para$a-mc_a
res_2PL_mrgb$para$b-mc_b
# 時々0．01以上の差が出ているところもあるが，大きくは変わらなそう。


