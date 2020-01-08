data {
  int<lower=1> n;
  real y[n];
}
parameters {
  real slope;
  real intercept;
  real<lower=0> sigma;
}
model {
  for (t in 1:n){
    y[t] ~ normal(intercept + slope * t, sigma);
  }
}
