data {
  int<lower=1> n;
  vector[n] y;
  vector[n] w;
}
parameters {
  // 確率的レベル
  vector[n] mu;
  // 確定的係数
  real lambda;
  // レベル撹乱項
  real<lower=0> sigma_level;
  // 観測撹乱項
  real<lower=0> sigma_irreg;
}
transformed parameters {
  vector[n] yhat;
  yhat = mu + lambda * w;
}
model {
  // 式 6.1
  for(t in 2:n)
    mu[t] ~ normal(mu[t-1], sigma_level);

  y ~ normal(yhat, sigma_irreg);
}
