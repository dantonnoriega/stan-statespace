data {
  //solve using matrixes
  //slower than recursion
  int<lower=1> n;
  int<lower=1> s;
  vector[n] y;
}
transformed data {
  //build seasonal transition matrix
  matrix[(s-1), (s-1)] G; // evolution matrix
  row_vector[(s-1)] Z; // transition matrix

  G[1] = rep_row_vector(-1,(s-1)); // top row all -1
  for(i in 2:(s-1)) { //diagonal from 2nd row onward
    G[i] = rep_row_vector(0,(s-1));
    G[i,i-1] = 1;
  }

  // keep first element of cycling seasons
  // [1,0,...,0]'
  Z[1:(s-1)] = rep_row_vector(0, (s-1));
  Z[1] = 1;

  // check matrix
  // for(i in 1:(s-1))
  //   print("G[", i, "] = ", G[i]);
}
parameters {
  vector[n] mu;
  vector[(s-1)] Theta0;
  real<lower=0> sigma_irreg;
  real<lower=0> sigma_level;
}
transformed parameters {
  vector[(s-1)] Theta[n];
  vector[n] yhat;
  Theta[1] = Theta0;
  yhat[1] = mu[1] + Z * Theta[1];
  for(t in 2:n) {
    Theta[t] = G * Theta[t-1];
    yhat[t] = mu[t] + Z * Theta[t];
  }
}
model {
  vector[n-1] d_mu;
  for(t in 1:(n-1))
    d_mu[t] = mu[t+1] - mu[t];

  mu[1] ~ normal(7,2);
  Theta0 ~ normal(0,1);
  d_mu ~ normal(0, sigma_level);
  sigma_level ~ exponential(5);
  sigma_irreg ~ exponential(5);
  y ~ normal(yhat, sigma_irreg);
}

generated quantities {
  vector[n] seasonal;
  for(t in 1:n)
    seasonal[t] = Z * Theta[t];
}