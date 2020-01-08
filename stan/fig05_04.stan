data {
  int<lower=1> n;
  vector[n] y;
  vector[n] x;
  vector[2] init_mu;
}
parameters {
  vector[n] mu;
  real<lower=0> pos_beta; // model a positive beta

  real<lower=0> sigma_mu;
  real<lower=0> sigma_irreg;
}
transformed parameters {
  real<upper=0> beta; // use to force a negative slope
  beta=-pos_beta;
}
model {
  mu[1] ~ normal(init_mu[1], init_mu[2]); // init prior with starting y[1]
  // narrow priors; expect little variation
  sigma_mu ~ exponential(10);
  sigma_irreg ~ exponential(10);
  pos_beta ~ exponential(2); // model positive beta
  mu[2:n] ~ normal(mu[1:(n-1)], sigma_mu); //vectorize
  y ~ normal(mu + beta * x, sigma_irreg);
}
generated quantities {
  vector[n] yhat;
  yhat = mu + beta * x;
}
