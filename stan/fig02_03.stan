data {
  int<lower=1> n;
  vector[n] y;
}
parameters {
  vector[n] mu;
  real<lower=0> sigma_level;
  real<lower=0> sigma_irreg;
}
model {
  vector[n-1] delta;
  // model the differences
  // modeling mu[t+1] ~ normal(mu[t], sigma) creates strong
  // correlations that make it hard to sample
  // see comments in
  // https://statmodeling.stat.columbia.edu/2019/04/15/state-space-models-in-stan/?unapproved=1206897&moderation-hash=154b8406a553c9a66d6bb831206b6f6c#comment-1206897
  for (t in 1:(n-1))
    delta[t] = mu[t+1] - mu[t];
  sigma_level ~ exponential(10);
  sigma_irreg ~ exponential(10);
  delta ~ normal(0, sigma_level);
  y ~ normal(mu, sigma_irreg);
}
