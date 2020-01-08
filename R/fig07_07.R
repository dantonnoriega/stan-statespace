source('R/common.R', encoding = 'utf-8')

## init_stan
y <- ukinflation
w <- ukpulse
standata <- within(list(), {
  s <- frequency(y)
  y <- as.vector(y)
  w <- as.vector(w)
  n <- length(y)
})

## stan model
model_file <- 'stan/fig07_07.stan'
cat(paste(readLines(model_file)), sep = '\n')
model <- rstan::stan_model(model_file)
fit <- rstan::sampling(model, data = standata,
            control = list(adapt_delta = .8, max_treedepth = 16),
            warmup = 1000, iter = 4000, chains = 4)
is.converged(fit)

yhat <- get_posterior_mean(fit, par = 'yhat')[, 'mean-all chains']
mu <- get_posterior_mean(fit, par = 'mu')[, 'mean-all chains']
seasonal <- get_posterior_mean(fit, par = 'seasonal')[, 'mean-all chains']
lambda <- get_posterior_mean(fit, par = 'lambda')[, 'mean-all chains']
sigma_irreg <- get_posterior_mean(fit, par = 'sigma_irreg')[, 'mean-all chains']
sigma_level <- get_posterior_mean(fit, par = 'sigma_level')[, 'mean-all chains']
sigma_seas <- get_posterior_mean(fit, par = 'sigma_seas')[, 'mean-all chains']
#
is.almost.fitted(sigma_irreg^2, 2.1990e-5)
is.almost.fitted(sigma_level^2, 1.8595e-5)
is.almost.fitted(sigma_seas^2, 0.0110e-5)

## output_figures
title <- 'Stochastic level and seasonal.'
yhat <- ts(yhat, start = start(y), frequency = frequency(y))
seasonal <- ts(seasonal, start = start(y), frequency = frequency(y))
layout(1)
plot(y)
lines(yhat + seasonal, col = 4, lwd = 2, lty = 3)
legend(x = par("usr")[1], y = par("usr")[4],
  col = c(1,4), lty=c(1,3), seg.len = 3, cex = .6,
  legend = c("quarterly price changes in UK", "stochastic level + seasonal"))

title <- 'Figure 7.7. Local level (including pulse interventions), local seasonal
          and irregular for UK inflation time series data.'
yhat <- ts(yhat, start = start(y), frequency = frequency(y))
layout(matrix(1:3,nrow=3))
plot(y, lwd = .8)
lines(yhat, col = 4, lwd = 2)
legend(x = par("usr")[1], y = par("usr")[4],
  col = c(1,4), lty=1, seg.len = 3, cex = .6,
  legend = c("quarterly price changes in UK", "stochastic level + pulse intervention variables"))
#
seasonal <- ts(seasonal, start = start(y), frequency = frequency(y))
plot(seasonal, col=2)
legend(x = par("usr")[1], y = par("usr")[4],
  col = c(2), lty=1, seg.len = 3, cex = .6,
  legend = c("stochastic seasonal"))
#
irreg <- ts(y - yhat, start = start(y), frequency = frequency(y))
plot(irreg, col = 6, lty = 3)
legend(x = par("usr")[1], y = par("usr")[4],
  col = 6, lty=1, seg.len = 3, cex = .6,
  legend = c("irregular"))
