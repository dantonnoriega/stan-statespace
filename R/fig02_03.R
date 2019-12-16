source('R/common.R', encoding = 'utf-8')

## @knitr init_stan

y <- ukdrivers

standata <- within(list(), {
  y <- as.vector(y)
  n <- length(y)
})

## @knitr show_model

model_file <- 'models/fig02_03.stan'
cat(paste(readLines(model_file)), sep = '\n')
fit <- stan(file = model_file, data = standata,
            warmup = 4000, iter = 20000, chains = 2,
            control = list(adapt_delta = .99, max_treedepth = 15))
stopifnot(is.converged(fit))
#
mu <- get_posterior_mean(fit, par = 'mu')[, 'mean-all chains']
sigma_irreg <- get_posterior_mean(fit, par = 'sigma_irreg')[, 'mean-all chains']
sigma_level <- get_posterior_mean(fit, par = 'sigma_level')[, 'mean-all chains']
stopifnot(is.almost.fitted(mu[[1]], 7.4150))
stopifnot(is.almost.fitted(sigma_irreg^2, 0.00222157))
stopifnot(is.almost.fitted(sigma_level^2, 0.011866))

## @knitr output_figures
title <- 'Figure 2.3. Stochastic level.'
p <- autoplot(y)

# stan
yhat <- ts(mu, start = start(y), frequency = frequency(y))
p <- autoplot(yhat, p = p, ts.colour = 'blue')
p + ggtitle(title)

title <- 'Figure 2.4. Irregular component for local level model.'
autoplot(y - yhat, ts.linetype = 'dashed') + ggtitle(title)

