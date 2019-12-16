data {
  int<lower=1> n;
  vector[n] y;
  vector[n] w;
}
parameters {
  // 確定的レベル
  real mu;
  // 確定的係数
  real lambda;
  // 観測撹乱項
  real<lower=0> sigma_irreg;
}
transformed parameters {
  vector[n] yhat;
  yhat = mu + lambda * w;
}
model {
  // 式 6.2
  y ~ normal(yhat, sigma_irreg);
}
