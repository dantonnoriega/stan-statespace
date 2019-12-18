data {
  int<lower=1> n;
  vector[n] y;
}
parameters {
  vector[n] v;
  real mu0;
  real<lower=0> sigma_drift;
  real<lower=0> sigma_irreg;
}
transformed parameters {
  vector[n] mu;
  mu[1] = mu0;
  for(t in 2:n) {
    mu[t] = mu[t-1] + v[t-1];
  }
}
model {
  vector[n-1] delta;
  for(t in 1:(n-1))
    delta[t] = v[t+1] - v[t];
  mu0 ~ normal(0, 5);
  delta ~ normal(0, sigma_drift);
  y ~ normal(mu, sigma_irreg);
}
