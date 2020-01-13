data {
  int<lower=1> n;
  int<lower=1> s;
  vector[n] y;
  vector[n] x;
  vector[n] w;
}
parameters {
  vector[n] mu;
  vector[s-1] seas;
  real beta;
  real lambda;
  real<lower=0> sigma_level;
  real<lower=0> sigma_irreg;
}
transformed parameters {
  vector[n] yhat;
  vector[n] xreg;
  vector[n] seasonal;
  //deterministic seasonal component
  seasonal[1:(s-1)] = seas;
  for(t in s:n)
    seasonal[t] = -sum(seasonal[(t-s+1):(t-1)]);
  xreg = beta * x + lambda * w;
  yhat = mu + xreg + seasonal;
}
model {
  vector[n-1] d_mu;

  for(t in 1:(n-1))
    d_mu[t] = mu[t+1] - mu[t];

  mu[1] ~ normal(7,1);
  beta ~ normal(0,.5);
  lambda ~ normal(0,.5);
  seas ~ normal(0,.1);

  sigma_level ~ exponential(10);
  sigma_irreg ~ exponential(10);

  d_mu ~ normal(0, sigma_level);
  y ~ normal(yhat, sigma_irreg);
}
