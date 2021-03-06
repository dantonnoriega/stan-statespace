source('R/common.R', encoding = 'utf-8')

## init_stan

y <- norwegian_fatalities

standata <- within(list(), {
  y <- as.vector(y)
  n <- length(y)
})

## show_model

# can use the same model as fig02_03
model_file <- 'stan/fig02_03.stan'
cat(paste(readLines(model_file)), sep = '\n')
model <- rstan::stan_model(model_file)
fit <- rstan::sampling(model, data = standata,
  chains = 2, seed = 12345)
is.converged(fit)

mu <- get_posterior_mean(fit, par = 'mu')[, 'mean-all chains']
sigma_irreg <- get_posterior_mean(fit, par = 'sigma_irreg')[, 'mean-all chains']
sigma_level <- get_posterior_mean(fit, par = 'sigma_level')[, 'mean-all chains']
is.almost.fitted(mu[[1]], 6.3048)
is.almost.fitted(sigma_irreg^2, 0.00326838)
is.almost.fitted(sigma_level^2, 0.0047026)

## output_figures
title <- 'Figure 2.5. Stochastic level for Norwegian fatalities.'
yhat <- ts(mu, start = start(y), frequency = frequency(y))
autoplot(y) +
  autolayer(yhat, color = 'blue') +
  ggtitle(title)

title <- 'Figure 2.6. Irregular component for Norwegian fatalities.'
autoplot(y - yhat, linetype = 'dashed') +
  ggtitle(title)

