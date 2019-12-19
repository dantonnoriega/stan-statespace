data {
  int<lower=1> n;
  int<lower=1> s;
  vector[n] y;
}
parameters {
  real mu;
  vector[(s-1)] seas;
  real<lower=0> sigma_irreg;
}
transformed parameters {
  vector[n] seasonal;
  vector[n] yhat;
  seasonal[1:(s-1)] = seas;
  for(t in s:n)
    seasonal[t] = -sum(seasonal[t-(s-1):t-1]);
  yhat = mu + seasonal;
}
model {
  y ~ normal(yhat, sigma_irreg);
}
