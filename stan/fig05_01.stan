data {
  int<lower=1> n;
  vector[n] y;
  vector[n] x;
}
parameters {
  real mu;
  real beta;
  real<lower=0> sigma_irreg;
}
transformed parameters {
  vector[n] yhat;
  yhat = mu + beta * x;
}
model {
  //add init priors to mu, beta
  mu ~ normal(0,3);
  beta ~ normal(0,1);
  y ~ normal(yhat, sigma_irreg);
}
