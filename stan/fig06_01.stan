data {
  int<lower=1> n;
  vector[n] y;
  vector[n] w;
}
parameters {
  real mu;
  real lambda;
  real<lower=0> sigma_irreg;
}
transformed parameters {
  vector[n] yhat;
  yhat = mu + lambda * w;
}
model {
  // add weakly informative priors
  mu ~ normal(0,3);
  lambda ~ normal(0,3);
  sigma_irreg ~ exponential(2);
  y ~ normal(yhat, sigma_irreg);
}
