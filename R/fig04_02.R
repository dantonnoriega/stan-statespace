source('R/common.R', encoding = 'utf-8')

## init_stan
y <- ukdrivers
standata <- within(list(), {
  y <- as.vector(y)
  n <- length(y)
  s <- 12
})

## show_model
model_file <- 'stan/fig04_02.stan'
cat(paste(readLines(model_file)), sep = '\n')
model <- rstan::stan_model(model_file)
fit <- rstan::sampling(model, data = standata,
            control = list(adapt_delta = .8, max_treedepth = 10),
            warmup = 1000, iter = 2000, chains = 2)
is.converged(fit)

mu <- get_posterior_mean(fit, par = 'mu')[, 'mean-all chains']
yhat <- get_posterior_mean(fit, par = 'yhat')[, 'mean-all chains']
if(grepl('v2', model_file)) {
  Theta <- get_posterior_mean(fit, par = 'Theta')[, 'mean-all chains']
  seasonal <- matrix(Theta, ncol = 11, byrow = TRUE)[,1]
} else {
  seasonal <- get_posterior_mean(fit, par = 'seasonal')[, 'mean-all chains']
}


## output_figures
title <- 'Figure 4.2. Combined deterministic level and seasonal.'
yhat <- ts(yhat, start = start(y), frequency = frequency(y))
autoplot(y) +
  autolayer(yhat, series = 'fit', lty = 2) +
  ggtitle(title)


title <- 'Figure 4.3. Deterministic level.'
autoplot(y) +
  geom_hline(yintercept = mu, col = 'blue') +
  ggtitle(title)


title <- 'Figure 4.4. Deterministic seasonal.'
seasonal <- ts(seasonal, start = start(y), frequency = frequency(y))
autoplot(seasonal, color = 'blue') +
  geom_hline(yintercept = 0, col = 'orange', lty = 2) +
  ggtitle(title)

title <- 'Figure 4.5. Irregular component for deterministic level and seasonal model.'
autoplot(y - yhat, linetype = 'dashed') + ggtitle(title)

