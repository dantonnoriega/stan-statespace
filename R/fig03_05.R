source('R/common.R', encoding = 'utf-8')

## init_stan
y <- finnish_fatalities
standata <-
  within(list(), {
    y <- as.vector(y)
    n <- length(y)
  })

## show_model
model_file <- 'models/fig03_05.stan'
cat(paste(readLines(model_file)), sep = '\n')
## fit_stan
lmresult <- lm(y ~ x, data = data.frame(x = 1:length(y), y = as.numeric(y)))
fit <- stan(file = model_file, data = standata,
            control = list(adapt_delta = .95, max_treedepth = 15),
            warmup = 2000, iter = 10000,
            chains = 2, seed = 12345)
stopifnot(is.converged(fit))

mu <- get_posterior_mean(fit, par = 'mu')[, 'mean-all chains']
v <- get_posterior_mean(fit, par = 'v')[, 'mean-all chains']
sigma_drift <- get_posterior_mean(fit, par = 'sigma_drift')[, 'mean-all chains']
sigma_irreg <- get_posterior_mean(fit, par = 'sigma_irreg')[, 'mean-all chains']
is.almost.fitted(mu[[1]], 7.0122)
is.almost.fitted(v[[1]], 0.0068482)
is.almost.fitted(sigma_drift, 0.00153314)
is.almost.fitted(sigma_irreg, 0.00320083)

## output_figures
# stan
yhat <- ts(mu, start = start(y), frequency = frequency(y))
title <- 'Figure 3.5.1. Trend of deterministic level and stochastic slope model for Finnish fatalities'
autoplot(y) +
  autolayer(yhat, series = 'fit', lty = 2) +
  ggtitle(title)

title <- 'Figure 3.5.2 Stochastic slope component for Finnish fatalities.'
slope <- ts(v, start = start(y), frequency = frequency(y))
autoplot(slope, lty=3) +
  ggplot2::geom_hline(yintercept=0) +
  ggtitle(title)

title <- 'Figure 3.6. Irregular component for Finnish fatalities.'
autoplot(y - yhat, ts.linetype = 'dashed') + ggtitle(title)

forecast::ggtsdisplay(y - yhat)
Box.test(y - yhat, lag = 1, type = "Ljung")
