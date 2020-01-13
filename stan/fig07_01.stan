data {
  int<lower=1> n;
  int<lower=1> s;
  vector[n] y;
  vector[n] x;
  vector[n] w;
}
parameters {
  real mu;
  real beta;
  real lambda;
  vector[s-1] seas;
  real<lower=0> sigma_irreg;
}
transformed parameters {
  vector[n] seasonal;
  vector[n] xreg;
  seasonal[1:(s-1)] = seas;
  for(t in s:n)
    seasonal[t] = -sum(seasonal[t-(s-1):t-1]);
  xreg = beta * x + lambda * w;
}
model {
  mu ~ normal(7,3);
  beta ~ normal(0,2);
  lambda ~ normal(0,1);
  seas ~ normal(0,1);
  sigma_irreg ~ exponential(5);
  y ~ normal(mu + xreg + seasonal, sigma_irreg);
}
generated quantities {
  vector[n] yhat;
  yhat = mu + xreg + seasonal;
}
