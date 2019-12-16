data {
  int<lower=1> n;
  vector[n] y;
}
parameters {
  vector[n] mu;
  real mu0;
  real<lower=0> sigma_level;
  real<lower=0> sigma_irreg;
}
transformed parameters {
  // reparameterize the full model
  vector[n] delta;
  delta[1] = mu[1] - mu0;
  for (t in 2:n)
    delta[t] = mu[t] - mu[t-1];
}
model {
  mu0 ~ normal(0, 2); // weakly information prior
  sigma_level ~ exponential(10);
  sigma_irreg ~ exponential(10);
  delta ~ normal(0, sigma_level);
  y ~ normal(mu, sigma_irreg);
}
