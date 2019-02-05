// データ生成用のstanコード

data{
  int M;
  vector[M] a;
  vector[M] b;
}

parameters{
  real temp;
}

model{
  temp ~ uniform(0,1);
}

generated quantities{
  int y[M];
  real theta;
  theta = normal_rng(0,1);
  for(k in 1:M){
    y[k] = bernoulli_logit_rng(1.7*a[k]*(theta-b[k]));
  }
}
