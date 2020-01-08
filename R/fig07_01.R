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
model_file <- 'stan/fig07_01.stan'
cat(paste(readLines(model_file)), sep = '\n')
model <- rstan::stan_model(model_file)
fit <- rstan::sampling(model, data = standata,
            control = list(adapt_delta = .9, max_treedepth = 12),
            warmup = 1000, iter = 2000, chains = 4)
is.converged(fit)

yhat <- get_posterior_mean(fit, par = 'yhat')[, 'mean-all chains']
mu <- get_posterior_mean(fit, par = 'mu')[, 'mean-all chains']
beta <- get_posterior_mean(fit, par = 'beta')[, 'mean-all chains']
lambda <- get_posterior_mean(fit, par = 'lambda')[, 'mean-all chains']
seasonal <- get_posterior_mean(fit, par = 'seasonal')[, 'mean-all chains']
sigma_irreg <- get_posterior_mean(fit, par = 'sigma_irreg')[, 'mean-all chains']

is.almost.fitted(mu, 6.4016)
is.almost.fitted(beta, -0.45213)
is.almost.fitted(lambda, -0.19714)
is.almost.fitted(sigma_irreg^2, 0.00740223)

## output_figures

title <- paste('Figure 7.1. Deterministic level plus variables',
               'log petrol price and seat belt law.', sep = '\n')
plot_y_yhat(y, yhat, title) # got tired of rewriting this; in common.R
