source('R/common.R', encoding = 'utf-8')

## init_stan
y <- ukdrivers
standata <- within(list(), {
  y <- as.vector(y)
  n <- length(y)
})

## show_model
# add more iterations because the model error will be poorly sampled
# this is because the model incorrectly (but on purpose) assumes
# the model error is iid when it is clearly not
model_file <- 'models/fig02_03.stan'
cat(paste(readLines(model_file)), sep = '\n')
fit <- stan(file = model_file, data = standata,
            warmup = 4000, iter = 20000, chains = 2,
            control = list(adapt_delta = .8, max_treedepth = 15))
stopifnot(is.converged(fit))
#
mu <- get_posterior_mean(fit, par = 'mu')[, 'mean-all chains']
sigma_irreg <- get_posterior_mean(fit, par = 'sigma_irreg')[, 'mean-all chains']
sigma_level <- get_posterior_mean(fit, par = 'sigma_level')[, 'mean-all chains']
stopifnot(is.almost.fitted(mu[[1]], 7.4150))
stopifnot(is.almost.fitted(sigma_irreg^2, 0.00222157))
stopifnot(is.almost.fitted(sigma_level^2, 0.011866))

## output_figures
# stan
title <- 'Figure 2.3. Stochastic level.'
yhat <- ts(mu, start = start(y), frequency = frequency(y))
autoplot(y) +
  autolayer(yhat, series = 'fit', lty = 2) +
  ggtitle(title)

# plot the residuals
title <- 'Figure 2.4. Irregular component for local level model.'
autoplot(y - yhat, ts.linetype = 'dashed') + ggtitle(title)

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
    lty = 1, col = c('tomato', 'black'))
}
plot_sims(fit, 'mu', y, 50)
