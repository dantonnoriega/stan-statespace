source('R/common.R', encoding = 'utf-8')

## init_stan
y <- ukinflation
standata <- within(list(), {
  y <- as.vector(y)
  n <- length(y)
  s <- 4
})

## stan model
# convergence on seasonal component struggles given how little
# variation exists on seasonal component. fixed effects would be better.
# reuse the same code, fig04_06.stan
model_file <- 'stan/fig04_10.stan'
cat(paste(readLines(model_file)), sep = '\n')
model <- rstan::stan_model(model_file)
fit <- rstan::sampling(model, data = standata,
            control = list(adapt_delta = .9, max_treedepth = 16),
            warmup = 1000, iter = 2000, chains = 4)
is.converged(fit)

mu <- get_posterior_mean(fit, par = 'mu')[, 'mean-all chains']
yhat <- get_posterior_mean(fit, par = 'yhat')[, 'mean-all chains']
seasonal <- get_posterior_mean(fit, par = 'seasonal')[, 'mean-all chains']

sigma_irreg <- get_posterior_mean(fit, par = 'sigma_irreg')[, 'mean-all chains']
sigma_level <- get_posterior_mean(fit, par = 'sigma_level')[, 'mean-all chains']
sigma_seas <- get_posterior_mean(fit, par = 'sigma_seas')[, 'mean-all chains']
is.almost.fitted(mu[[208]], 0.0020426)
is.almost.fitted(sigma_irreg^2, 3.3717e-5)
is.almost.fitted(sigma_level^2, 2.1197e-5)
is.almost.fitted(sigma_seas^2, 0.0109e-5)

## output_figures
title <- 'Stochastic level and seasonal.'
yhat <- ts(yhat, start = start(y), frequency = frequency(y))
layout(1)
plot(y)
lines(yhat, col = 4, lwd = 2)
legend(x = par("usr")[1], y = par("usr")[4],
  col = c(1,4), lty=1, seg.len = 3, cex = .6,
  legend = c("actuals", "stochastic level + seasonal"))

title <- 'Figure 4.10. Stochastic level, seasonal and irregular in UK inflation series.'
mu <- ts(mu, start = start(y), frequency = frequency(y))
layout(matrix(1:3,nrow=3))
plot(y, lwd = .8)
lines(mu, col = 4, lwd = 2)
legend(x = par("usr")[1], y = par("usr")[4],
  col = c(1,4), lty=1, seg.len = 3, cex = .6,
  legend = c("quarterly price changes in UK", "stochastic level"))
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


