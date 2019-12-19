source('R/common.R', encoding = 'utf-8')

## init_stan
y <- ukdrivers
standata <- within(list(), {
  y <- as.vector(y)
  n <- length(y)
})

## show_model
# this model fits better
# no longer assumes the drift changes over time
# however, still fails to capture autocorrelated model errors
# as a result, `sigma_irreg` will sample poorly
model_file <- 'models/fig03_04.stan'
cat(paste(readLines(model_file)), sep = '\n')
## fit_stan
lmresult <- lm(y ~ x, data = data.frame(x = 1:length(y), y = as.numeric(y)))
fit <- stan(file = model_file, data = standata,
            control = list(max_treedepth = 15),
            warmup = 2000, iter = 10000,
            chains = 2, seed = 12345)
stopifnot(is.converged(fit))

mu <- get_posterior_mean(fit, par = 'mu')[, 'mean-all chains']
v <- get_posterior_mean(fit, par = 'v')[, 'mean-all chains']
sigma_level <- get_posterior_mean(fit, par = 'sigma_level')[, 'mean-all chains']
sigma_drift <- get_posterior_mean(fit, par = 'sigma_drift')[, 'mean-all chains']
sigma_irreg <- get_posterior_mean(fit, par = 'sigma_irreg')[, 'mean-all chains']
sprintf("fitted %0.4f vs actual %0.4f", mu[[1]], 7.4157)

## output_figures
title <- 'Figure 3.4. Trend of stochastic level and deterministic slope model.'
yhat <- ts(mu, start = start(y), frequency = frequency(y))
autoplot(y) +
  autolayer(yhat, series = 'fit', lty = 2) +
  ggtitle(title)

