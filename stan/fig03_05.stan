data {
  int<lower=1> n;
  vector[n] y;
}
parameters {
  vector[n] v;
  real mu0;
  real<lower=0> sigma_drift;
  //real<lower=0> sigma_level; // dont need; deterministic
  real<lower=0> sigma_irreg;
}
transformed parameters {
  // no evidence of a level shift
  // so we make mu deterministic
  vector[n] mu;
  mu[1] = mu0;
  // need for loop since it updates as posterior updates
  for(t in 2:n)
    mu[t] = mu[t-1] + v[t-1];
}
model {
  vector[n-1] delta;

  delta[1:(n-1)] = v[2:n] - v[1:(n-1)];
  mu0 ~ normal(0, 5); // init the first slope shift
  sigma_drift ~ exponential(2);
  sigma_irreg ~ exponential(2);

  delta ~ normal(0, sigma_drift);
  y ~ normal(mu, sigma_irreg);
}
