source('R/common.R', encoding = 'utf-8')

## init_stan
y <- ukdrivers
x <- ukpetrol
standata <- within(list(), {
  y <- as.vector(y)
  x <- as.vector(x)
  n <- length(y)
})

# stan model
model_file <- 'stan/fig05_01.stan'
cat(paste(readLines(model_file)), sep = '\n')
model <- rstan::stan_model(model_file)
fit <- rstan::sampling(model, data = standata,
            warmup = 1000, iter = 2000, chains = 4)
is.converged(fit)

yhat <- get_posterior_mean(fit, par = 'yhat')[, 'mean-all chains']
mu <- get_posterior_mean(fit, par = 'mu')[, 'mean-all chains']
beta <- get_posterior_mean(fit, par = 'beta')[, 'mean-all chains']
sigma_irreg <- get_posterior_mean(fit, par = 'sigma_irreg')[, 'mean-all chains']

is.almost.fitted(mu, 5.8787)
is.almost.fitted(beta, -0.67166)
is.almost.fitted(sigma_irreg^2, 0.0230137)

## output_figures

title <- 'Figure 5.1. Deterministic level and explanatory variable ‘log petrol price’.'
yhat <- ts(yhat, start = start(y), frequency = frequency(y))
autoplot(y) +
  autolayer(yhat, color = 'blue') +
  ggtitle(title)

title <- paste('Figure 5.2. Conventional classical regression representation of ',
               'deterministic level and explanatory variable log petrol price.', sep = '\n')
df <- data.frame(drivers = as.vector(ukdrivers),
                petrol = as.vector(ukpetrol),
                stan = as.vector(ukpetrol) * beta + mu)

ggplot(df, aes(x = petrol)) +
  geom_point(aes(y = drivers)) +
  geom_line(aes(y = stan), colour = 'blue') +
  stat_smooth(aes(y = drivers), method = 'lm', colour = 'red',
              linetype = 'dashed', se = FALSE) +
  ggtitle(title)

title <- 'Figure 5.3. Irregular component for deterministic level model with explanatory variable ‘log petrol price’.'
autoplot(y - yhat, linetype = 'dashed') + ggtitle(title)
