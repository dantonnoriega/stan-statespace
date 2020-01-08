data {
  int<lower=1> n;
  int<lower=1> s;
  vector[n] y;
  vector[n] x;
  vector[n] w;
  real a1;
  real<lower=0> P1;

}
parameters {
  vector[s-1] seas;
  real beta;
  real lambda;
  real<lower=0> sigma_level;
  real<lower=0> sigma_seas;
  real<lower=0> sigma_irreg;
}
transformed parameters {
  vector[n+1] a; // essentially the level (mu)
  vector[n] xreg;
  vector[n] seasonal;
  vector<lower=0>[n+1] P; // sigma^2
  vector<lower=0,upper=1>[n] K;
  vector<lower=0>[n] F;
  // build seasonal component
  seasonal[1:(s-1)] = seas;
  for(t in s:n)
    seasonal[t] = -sum(seasonal[(t-s+1):(t-1)]);

  // build regressor component (non state space components)
  xreg = beta * x + lambda * w + seasonal;
  //assign inits t=1
  a[1] = a1;
  P[1] = P1;
  // print("a[1]:", a[1]);
  // print("P[1]:", P[1]);
  // print("F[1]:", F[1]);
  // print("K[1]:", K[1]);
  // print("a[2]:", a[2]);
  // print("P[2]:", P[2]);
  // print("----------")

  for (t in 1:n) {
    F[t] = P[t] + (sigma_irreg^2);
    K[t] = P[t] / F[t];
    a[t+1] = a[t] + K[t]*(y[t] - a[t] - xreg[t]);
    P[t+1] = P[t]*(1 - K[t]) + (sigma_level^2);
    // print("a[",t+1,"]:", a[t+1]);
    // print("P[",t+1,"]:", P[t+1]);
    // print("F[",t,"]:", F[t]);
    // print("K[",t,"]:", K[t]);
  }

}
model {
  vector[n] v;
  v = y - a[1:n];

  beta ~ normal(-.5,.5);
  lambda ~ normal(0,1);
  seas ~ normal(0,sigma_seas);
  sigma_level ~ exponential(5);
  sigma_seas ~ exponential(5);
  sigma_irreg ~ exponential(5);

  v ~ normal(0, sqrt(F));
}
generated quantities {
  vector[n] yhat;
  yhat = a[1:n] + beta * x + lambda * w;
}
