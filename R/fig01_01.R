source('R/common.R', encoding = 'utf-8')

## init_stan ----------
y <- ukdrivers
standata <- within(list(), {
  y <- as.vector(y)
  n <- length(y)
})

## show_model ----------
model_file <- 'stan/fig01_01.stan'
cat(paste(readLines(model_file)), sep = '\n')
model <- rstan::stan_model(model_file)
fit <- rstan::sampling(model, data = standata,
  iter = 2000, chains = 4)
stopifnot(is.converged(fit))

## output_figures ----------
slope <- get_posterior_mean(fit, par = 'slope')[, 'mean-all chains']
intercept <- get_posterior_mean(fit, par = 'intercept')[, 'mean-all chains']
jan <- c(time(y) %% 1 == 0) # when january
title <- paste('Figure 1.1. Scatter plot of the log of the number of UK drivers',
               'KSI against time (in months), including regression line.', sep = '\n')
plot(c(y), type = 'p', main = title, pch = 20, xaxt='n')
axis(1, at = seq_along(y)[jan], labels = time(y)[jan])
abline(b = slope, a = intercept, col = 4, lty = 3, lwd = 1.5)

title <- 'Figure 1.2. Log of the number of UK drivers KSI plotted as a time series.'
plot(y, main =title)

title <- paste('Figure 1.3. Residuals of classical linear regression of the ',
               'log of the number of UK drivers KSI on time.', sep = '\n')
plot(y - yhat, lty = 3, main = title)
abline(h=0)