source('R/common.R', encoding = 'utf-8')

## init_stan

y <- ukdrivers
standata <- within(list(), {
  y <- as.vector(y)
  n <- length(y)
})

## show_model
model_file <- 'stan/fig02_01.stan'
cat(paste(readLines(model_file)), sep = '\n')

## fit_stan
fit <- stan(file = model_file, data = standata,
            iter = 2000, chains = 4)
stopifnot(is.converged(fit))
mu <- get_posterior_mean(fit, par = 'mu')[, 'mean-all chains']

## output_figures
title <- 'Figure 2.1. Deterministic level.'
autoplot(y) +
  geom_hline(yintercept = mu, colour = 'blue') +
  geom_hline(yintercept = mean(y),
    colour = 'red', linetype = 'dashed') +
  ggtitle(title)

title <- 'Figure 2.2. Irregular component for deterministic level model.'
autoplot(y - mu, lty = 'dashed') + ggtitle(title)
