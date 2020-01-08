source('R/common.R', encoding = 'utf-8')

## init_stan
y <- ukdrivers
standata <- within(list(), {
  y <- as.vector(y)
  n <- length(y)
  s <- 12
})

## stan model
# convergence on seasonal component struggles given how little
# variation exists on seasonal component. fixed effects would be better.
model_file <- 'stan/fig04_06.stan'
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
is.almost.fitted(sigma_irreg^2, 0.00351385)
is.almost.fitted(sigma_level^2, 0.000945723)

## output_figures
title <- 'Stochastic level and seasonal.'
yhat <- ts(yhat, start = start(y), frequency = frequency(y))
autoplot(y) +
  autolayer(yhat, series = 'fit', lty = 2) +
  ggtitle(title)

title <- 'Figure 4.6. Stochastic level.'
mu <- ts(mu, start = start(y), frequency = frequency(y))
autoplot(y) +
  autolayer(mu, series = 'fit', lty = 2) +
  ggtitle(title)

title <- 'Figure 4.7. Stochastic seasonal.'
seasonal <- ts(seasonal, start = start(y), frequency = frequency(y))
autoplot(seasonal, color = 'blue') + ggtitle(title)

title <- 'Figure 4.8. Stochastic seasonal for the year 1969.'
forecast::ggseasonplot(seasonal) + ggtitle(title)

title <- 'Figure 4.9. Irregular component for stochastic level and seasonal model.'
autoplot(y - yhat, linetype = 'dashed') + ggtitle(title)

