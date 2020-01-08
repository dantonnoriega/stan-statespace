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
  vector[n] yhat;
  seasonal[1:(s-1)] = seas;
  for(t in s:n)
    seasonal[t] = -sum(seasonal[t-(s-1):t-1]);
  yhat = mu + beta * x + lambda * w + seasonal;
}
model {
  mu ~ normal(7,2);
  beta ~ normal(-.5,.5);
  lambda ~ normal(0,1);
  seas ~ normal(0,1);
  sigma_irreg ~ exponential(5);
  y ~ normal(yhat + seasonal, sigma_irreg);
}
