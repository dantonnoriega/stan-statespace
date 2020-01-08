data {
  int<lower=1> n;
  int<lower=1> s;
  vector[n] y;
}
parameters {
  vector[n] mu;
  vector[n] seasonal;
  real<lower=0> sigma_level;
  real<lower=0> sigma_seas;
  real<lower=0> sigma_irreg;
}
model {
  vector[n-1] d_mu;

  mu[1] ~ normal(0,3);
  // model the differences to improve sampling
  for(t in 1:(n-1))
    d_mu[t] = mu[t+1] - mu[t];
  d_mu ~ normal(0, sigma_level);

  // set initial priors for first s-1 seaonal components
  seasonal[1:(s-1)] ~ normal(0,1);
  for(t in s:n)
    seasonal[t] ~ normal(-sum(seasonal[(t-s+1):(t-1)]), sigma_seas);

  sigma_level ~ exponential(5);
  sigma_seas ~ exponential(5);
  sigma_irreg ~ exponential(5);

  y ~ normal(mu + seasonal, sigma_irreg);
}
generated quantities {
  vector[n] yhat;
  yhat = mu + seasonal;
}


