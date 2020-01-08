data {
  int<lower=1> n;
  vector[n] y;
  vector[n] w;
}
parameters {
  vector[n] mu;
  real lambda;
  real<lower=0> sigma_level;
  real<lower=0> sigma_irreg;
}
transformed parameters {
  vector[n] yhat;
  yhat = mu + lambda * w;
}
model {
  vector[n-1] delta;
  delta[1:(n-1)] = mu[2:n] - mu[1:(n-1)];
  mu[1] ~ normal(7,1);
  lambda ~ normal(0,1);
  sigma_level ~ exponential(2);
  sigma_irreg ~ exponential(2);
  delta ~ normal(0, sigma_level);
  y ~ normal(yhat, sigma_irreg);
}
