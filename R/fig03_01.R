source('R/common.R', encoding = 'utf-8')

## init_stan
y <- ukdrivers
standata <- within(list(), {
  y <- as.vector(y)
  n <- length(y)
})

## show_model
# this model still fails to capture autocorrelation in the model error
# it also attempts to model a slope when there isn't one
# this leads to poor convergences / sampling
model_file <- 'stan/fig03_01.stan'
cat(paste(readLines(model_file)), sep = '\n')
model <- rstan::stan_model(model_file)
fit <- rstan::sampling(model, data = standata,
            control = list(adapt_delta = .9, max_treedepth = 15),
            warmup = 2000,iter = 10000,
            chains = 2, seed = 12345)
is.converged(fit)

# model doesnt fit well because there is not evidence of a drift
# the strong autocorrelation and overlap makes sampling the variances tough
mu <- get_posterior_mean(fit, par = 'mu')[, 'mean-all chains']
v <- get_posterior_mean(fit, par = 'v')[, 'mean-all chains']
sigma_level <- get_posterior_mean(fit, par = 'sigma_level')[, 'mean-all chains']
sigma_drift <- get_posterior_mean(fit, par = 'sigma_drift')[, 'mean-all chains']
sigma_irreg <- get_posterior_mean(fit, par = 'sigma_irreg')[, 'mean-all chains']

## output_figures
title <- 'Figure 3.1. Trend of stochastic linear trend model.'
yhat <- ts(mu, start = start(y), frequency = frequency(y))
autoplot(y) +
  autolayer(yhat, series = 'fit', lty = 2) +
  ggtitle(title)

title <- 'Figure 3.2. Slope of stochastic linear trend model.'
slope <- ts(v, start = start(y), frequency = frequency(y))
autoplot(slope) +
  coord_cartesian(y = c(-.01, .01)) +
  ggtitle(title)

title <- 'Figure 3.3. Irregular component of stochastic linear trend model.'
autoplot(y - yhat, linetype = 'dashed') + ggtitle(title)

# can see in acf plots the strong autocorrelation
forecast::ggtsdisplay(y - yhat)
Box.test(y - yhat, lag = 12, type = "Ljung-Box") # clear violation

# sims plot of yhat (mu)
plot_sims <- function(fit, par, y, n = 50) {
  yhat <- get_posterior_mean(fit, par = par)[, 'mean-all chains']
  yhat_draws <- extract(fit, pars = par)[[par]]
  sims <- yhat_draws[sample(1:nrow(yhat_draws), n), ]
  matplot(t(sims), type = 'l', col = scales::alpha('lightpink',.5), lty = 1)
  lines(c(y), lwd = 1.5)
  lines(yhat, lty=2, col='tomato', lwd = 1.5)
  legend(y = min(yhat)*1.01, x = 10, c('yhat', 'actuals'),
    lty = c(2,1), col = c('tomato', 'black'))
}
plot_sims(fit, 'mu', y, 50)
