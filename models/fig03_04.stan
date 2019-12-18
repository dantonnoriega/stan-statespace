data {
  int<lower=1> n;
  vector[n] y;
}
parameters {
  vector[n] mu;
  real v;
  real<lower=0> sigma_level;
  real<lower=0> sigma_drift;
  real<lower=0> sigma_model;
}
model {
  // eq 3.1 in differenced format
  vector[n-1] delta_mu;
  vector[n] err;

  for(t in 1:(n-1)) {
    delta_mu[t] = mu[t+1] - mu[t] - v;
  }
  err = y - mu;

  sigma_level ~ exponential(2);
  sigma_drift ~ exponential(2);
  sigma_model ~ exponential(2);
  v ~ normal(0, sigma_drift);
  delta_mu ~ normal(0, sigma_level);
  err ~ normal(0, sigma_model);
}
