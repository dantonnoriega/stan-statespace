data {
  int<lower=1> n;
  vector[n] y;
}
parameters {
  vector[n] mu;
  real v;
  real<lower=0> sigma_level;
  real<lower=0> sigma_drift;
  real<lower=0> sigma_irreg;
}
model {
  // eq 3.1 in differenced format
  // this time we assume a constant slope across time
  //  so we have nothing modeling v[t+1] = v[t] + e
  vector[n-1] delta_mu;
  vector[n] err;
  delta_mu[1:(n-1)] = mu[2:n] - mu[1:(n-1)] - v;

  sigma_level ~ exponential(2);
  sigma_drift ~ exponential(2);
  sigma_irreg ~ exponential(2);
  v ~ normal(0, sigma_drift);
  delta_mu ~ normal(0, sigma_level);
  y ~ normal(mu, sigma_irreg);
}
