data {
  int<lower=1> n;
  vector[n] y;
  real a1;
  real<lower=0> P1;
}
parameters {
  real<lower=0> sigma_level;
  real<lower=0> sigma_irreg;
}
transformed parameters {
  vector[n+1] a;
  vector<lower=0>[n+1] P; // sigma^2
  vector<lower=0,upper=1>[n] K;
  vector<lower=0>[n] F;
  //assign inits t=1
  a[1] = a1;
  P[1] = P1;

  for (t in 1:n) {
    F[t] = P[t] + (sigma_irreg^2);
    K[t] = P[t] / F[t];
    a[t+1] = a[t] + K[t]*(y[t] - a[t]);
    P[t+1] = P[t]*(1 - K[t]) + (sigma_level^2);
  }
}
model {
  vector[n] v;
  v = y - a[1:n];
  for (t in 1:n) {
    v[t] ~ normal(0, sqrt(F[t]));
  }
  sigma_level ~ exponential(2);
  sigma_irreg ~ exponential(2);
}
