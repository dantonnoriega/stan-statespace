data {
  int<lower=1> n;
  vector[n] y;
}
parameters {
  // 確率的レベル
  vector[n] mu;
  // 確率的季節項
  vector[n] seasonal;
  // レベル撹乱項
  real<lower=0> sigma_level;
  // 季節性撹乱項
  real<lower=0> sigma_seas;
  // 観測撹乱項
  real<lower=0> sigma_irreg;
}
transformed parameters {
  vector[n] yhat;
  yhat = mu + seasonal;
}
model {
  // 式 4.1

  // frequency = 12
  for(t in 12:n)
    seasonal[t] ~ normal(- sum(seasonal[t-11:t-1]), sigma_seas);

  for(t in 2:n)
    mu[t] ~ normal(mu[t-1], sigma_level);

  y ~ normal(yhat, sigma_irreg);
}
