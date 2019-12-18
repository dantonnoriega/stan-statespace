data {
  int<lower=1> n;
  vector[n] y;
}
parameters {
  vector[n] mu;
  vector[n] v;
  real<lower=0> sigma_level;
  real<lower=0> sigma_drift;
  real<lower=0> sigma_model;
}
model {
  // eq 3.1 in differenced format
  vector[n-1] delta_mu;
  vector[n-1] delta_v;
  vector[n] err;

  for(t in 1:(n-1)) {
    delta_v[t] = v[t+1] - v[t];
    delta_mu[t] = mu[t+1] - mu[t] - v[t];
  }
  err = y - mu;

  sigma_level ~ exponential(2);
  sigma_drift ~ exponential(2);
  sigma_model ~ exponential(2);
  delta_v ~ normal(0, sigma_drift);
  delta_mu ~ normal(0, sigma_level);
  err ~ normal(0, sigma_model);
}
