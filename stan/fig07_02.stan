data {
  int<lower=1> n;
  int<lower=1> s;
  vector[n] y;
  vector[n] x;
  vector[n] w;
}
parameters {
  vector[n] mu;
  vector[n] seasonal;
  real beta;
  real lambda;
  real<lower=0> sigma_level;
  real<lower=0> sigma_seas;
  real<lower=0> sigma_irreg;
}
transformed parameters {
  vector[n] yhat;
  yhat = mu + beta * x + lambda * w;
}
model {
  vector[n-1] d_mu;
  for(t in 1:(n-1))
    d_mu[t] = mu[t+1] - mu[t];

  mu[1] ~ normal(7,2);
  beta ~ normal(-.5,.5);
  lambda ~ normal(0,1);
  seasonal[1:(s-1)] ~ normal(0,sigma_seas);
  for(t in s:n)
    seasonal[t] ~ normal(-sum(seasonal[(t-s+1):(t-1)]), sigma_seas);

  sigma_level ~ exponential(5);
  sigma_seas ~ exponential(5);
  sigma_irreg ~ exponential(5);

  d_mu ~ normal(0, sigma_level);
  y ~ normal(yhat + seasonal, sigma_irreg);
}
