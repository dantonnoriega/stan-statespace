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
  vector[n] xreg;
  vector[n] seasonal;
  //deterministic seasonal component
  seasonal[1:(s-1)] = seas;
  for(t in s:n)
    seasonal[t] = -sum(seasonal[(t-s+1):(t-1)]);
  xreg = beta * x + lambda * w;
}
model {
  vector[n-1] d_mu;

  for(t in 1:(n-1))
    d_mu[t] = mu[t+1] - mu[t];

  mu[1] ~ normal(7,2);
  beta ~ normal(-.5,.5);
  lambda ~ normal(0,1);
  seas ~ normal(0,1);

  sigma_level ~ exponential(5);
  sigma_irreg ~ exponential(5);

  d_mu ~ normal(0, sigma_level);
  y ~ normal(mu + xreg + seasonal, sigma_irreg);
}
generated quantities {
  vector[n] yhat;
  yhat = mu + xreg + seasonal;
}
