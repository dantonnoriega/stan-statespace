source('R/common.R', encoding = 'utf-8')

## init_stan
y <- ukdrivers
x <- ukpetrol
w <- ukseats
standata <- within(list(), {
  s <- frequency(y) # order matters; get s before removing ts attrib
  y <- as.vector(y)
  x <- as.vector(x)
  w <- as.vector(w)
  n <- length(y)
})

## show_model
# no evidence of a stochastic seasonal component
# leads to slow sampling
model_file <- 'stan/fig07_02.stan'
cat(paste(readLines(model_file)), sep = '\n')
model <- rstan::stan_model(model_file)
fit <- rstan::sampling(model, data = standata,
            control = list(adapt_delta = .9, max_treedepth = 15),
            warmup = 1000, iter = 4000, chains = 2)
is.converged(fit)

xreg <- get_posterior_mean(fit, par = 'xreg')[, 'mean-all chains']
mu <- get_posterior_mean(fit, par = 'mu')[, 'mean-all chains']
seasonal <- get_posterior_mean(fit, par = 'seasonal')[, 'mean-all chains']
beta <- get_posterior_mean(fit, par = 'beta')[, 'mean-all chains']
lambda <- get_posterior_mean(fit, par = 'lambda')[, 'mean-all chains']
sigma_seas <- get_posterior_mean(fit, par = 'sigma_seas')[, 'mean-all chains']
sigma_level <- get_posterior_mean(fit, par = 'sigma_level')[, 'mean-all chains']
sigma_irreg <- get_posterior_mean(fit, par = 'sigma_irreg')[, 'mean-all chains']

# not the best fit. poor sampling driven by poor sampling.
is.almost.fitted(sigma_irreg^2, 0.00378629)
is.almost.fitted(sigma_level^2, 0.000267632)
is.almost.fitted(sigma_seas^2, 0.0000011622)

## output_figures
title <- paste('Figure 7.2. Stochastic level plus variables',
               'log petrol price and seat belt law.', sep = '\n')
xreg <- ts(xreg, start = start(y), frequency = frequency(y))
plot_y_yhat(y, mu + xreg, title)

title <- 'Figure 7.3. Stochastic seasonal.'
seasonal <- ts(seasonal, start = start(y), frequency = frequency(y))
autoplot(seasonal, color = 'blue') + ggtitle(title)

title <- 'Figure 7.4. Irregular component for stochastic level and seasonal model.'
autoplot(y - mu - xreg - seasonal, lty = 'dashed') + ggtitle(title)

forecast::ggseasonplot(seasonal)
forecast::ggtsdisplay(y - mu - xreg - seasonal)