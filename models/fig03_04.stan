data {
  int<lower=1> n;
  vector[n] y;
}
parameters {
  // 確率的レベル
  vector[n] mu;
  // 確定的傾き
  real v;
  // レベル撹乱項
  real<lower=0> sigma_level;
  // 観測撹乱項
  real<lower=0> sigma_irreg;
}
transformed parameters {
  vector[n] yhat;
  yhat = mu;
}
model {
  // 式 3.3
  mu[1] ~ normal(y[1], sigma_level);
  for(t in 2:n)
    mu[t] ~ normal(mu[t-1] + v, sigma_level);

  y ~ normal(yhat, sigma_irreg);

  sigma_level ~ student_t(4, 0, 1);
  sigma_irreg ~ student_t(4, 0, 1);
  v ~ normal(0, 5);
}
