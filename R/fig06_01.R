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
model_file <- 'stan/fig06_01.stan'
cat(paste(readLines(model_file)), sep = '\n')
model <- rstan::stan_model(model_file)
fit <- rstan::sampling(model, data = standata,
            warmup = 1000, iter = 4000, chains = 2)
is.converged(fit)

yhat <- get_posterior_mean(fit, par = 'yhat')[, 'mean-all chains']
mu <- get_posterior_mean(fit, par = 'mu')[, 'mean-all chains']
lambda <- get_posterior_mean(fit, par = 'lambda')[, 'mean-all chains']
sigma_irreg <- get_posterior_mean(fit, par = 'sigma_irreg')[, 'mean-all chains']
is.almost.fitted(mu, 7.4374)
is.almost.fitted(lambda, -0.26111)
is.almost.fitted(sigma_irreg^2, 0.0222426)

## output_figures

title <- 'Figure 6.1. Deterministic level and intervention variable.'
yhat <- ts(yhat, start = start(y), frequency = frequency(y))
autoplot(y) +
  autolayer(yhat, color = 'blue') +
  ggtitle(title)

title <- paste('Figure 6.2. Conventional classical regression representation of',
               'deterministic level and intervention variable.', sep = '\n')
df = data.frame(drivers = as.numeric(ukdrivers),
                seats = as.numeric(ukseats))
ggplot(df, aes(x = seats, y = drivers)) +
  geom_point() +
  stat_smooth(method = 'lm', se = FALSE) +
  ggtitle(title)

title <- paste('Figure 6.3. Irregular component for deterministic level model',
               'with intervention variable.', sep = '\n')
autoplot(y - yhat, lty = 'dashed') + ggtitle(title)
