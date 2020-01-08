source('R/common.R', encoding = 'utf-8')

## init_stan
y <- ukdrivers
w <- ukseats
standata <- within(list(), {
  y <- as.vector(y)
  w <- as.vector(w)
  n <- length(y)
})

## show_model
model_file <- 'stan/fig06_04.stan'
cat(paste(readLines(model_file)), sep = '\n')
model <- rstan::stan_model(model_file)
fit <- rstan::sampling(model, data = standata,
            control = list(adapt_delta = .9, max_treedepth = 12),
            warmup = 1000, iter = 4000, chains = 4)
is.converged(fit)

yhat <- get_posterior_mean(fit, par = 'yhat')[, 'mean-all chains']
mu <- get_posterior_mean(fit, par = 'mu')[, 'mean-all chains']
lambda <- get_posterior_mean(fit, par = 'lambda')[, 'mean-all chains']
sigma_irreg <- get_posterior_mean(fit, par = 'sigma_irreg')[, 'mean-all chains']

is.almost.fitted(mu[[1]], 7.4107)
is.almost.fitted(lambda, -0.3785)
is.almost.fitted(sigma_irreg^2, 0.0104111)

## output_figures
title <- 'Figure 6.4. Stochastic level and intervention variable.'
yhat <- ts(yhat, start = start(y), frequency = frequency(y))
autoplot(y) +
  autolayer(yhat, color = 'blue') +
  ggtitle(title)

title <- paste('Figure 6.5. Irregular component for',
               'stochastic level model with intervention variable.', sep = '\n')
autoplot(y - yhat, lty = 'dashed') + ggtitle(title)



