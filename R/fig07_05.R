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

## 7.5. model with deterministic level, deterministic seasonal --------
model_file <- 'stan/fig07_01.stan'
cat(paste(readLines(model_file)), sep = '\n')
model <- rstan::stan_model(model_file)
fit_07_01 <- rstan::sampling(model, data = standata,
            control = list(adapt_delta = .8, max_treedepth = 10),
            warmup = 1000, iter = 2000, chains = 2)
is.converged(fit_07_01)
yhat_07_01 <- get_posterior_mean(fit_07_01, par = 'yhat')[, 'mean-all chains']

title <- paste('Figure 7.5. Correlogram of irregular component of',
  'completely deterministic level and seasonal model.')
forecast::ggAcf(y - yhat_07_01, 14) + ggtitle(title)


## 7.6. model with stochastic level, deterministic seasonal --------
## lots of multicollinearity here.
## in this model, i dont think the regressors are necessary.
## but thats what the book is doing so...
model_file <- 'stan/fig07_06.stan'
cat(paste(readLines(model_file)), sep = '\n')
model <- rstan::stan_model(model_file)
fit_07_06 <- rstan::sampling(model, data = standata,
            control = list(adapt_delta = .95, max_treedepth = 15),
            warmup = 2000, iter = 10000, chains = 2)
is.converged(fit_07_06)
yhat_07_06 <- get_posterior_mean(fit_07_06, par = 'yhat')[, 'mean-all chains']

# this isn't plotted in book
title <- paste('Stochastic level, deterministic seasonal plus variables',
  '(log petrol price and seat belt law).')
yhat_07_06 <- ts(yhat_07_06, start = start(y), frequency = frequency(y))
plot_y_yhat(y, yhat_07_06, title)

title <- paste('Figure 7.6. Correlogram of irregular component of',
  'stochastic level and deterministic seasonal model.')
forecast::ggAcf(y - yhat_07_06, 14) + ggtitle(title)

forecast::ggtsdisplay(y - yhat_07_06)