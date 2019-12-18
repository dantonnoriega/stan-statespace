source('R/common.R', encoding = 'utf-8')

## init_stan
y <- ukdrivers
standata <- within(list(), {
  y <- as.vector(y)
  n <- length(y)
})

## show_model
# this model still does not fix the autocorrelation in the error
# therefore, the samples for sigma_model will be low
model_file <- 'models/fig03_01.stan'
cat(paste(readLines(model_file)), sep = '\n')
## fit_stan
lmresult <- lm(y ~ x, data = data.frame(x = 1:length(y), y = as.numeric(y)))
fit <- stan(file = model_file, data = standata,
            control = list(max_treedepth = 15),
            warmup = 2000,iter = 10000,
            chains = 2, seed = 12345)
stopifnot(is.converged(fit))

mu <- get_posterior_mean(fit, par = 'mu')[, 'mean-all chains']
v <- get_posterior_mean(fit, par = 'v')[, 'mean-all chains']
sigma_level <- get_posterior_mean(fit, par = 'sigma_level')[, 'mean-all chains']
sigma_drift <- get_posterior_mean(fit, par = 'sigma_drift')[, 'mean-all chains']
sigma_model <- get_posterior_mean(fit, par = 'sigma_model')[, 'mean-all chains']

## output_figures
title <- 'Figure 3.1. Trend of stochastic linear trend model.'
yhat <- ts(mu, start = start(y), frequency = frequency(y))
# stan
autoplot(y) +
  autolayer(yhat, series = 'fit', lty = 2) +
  ggtitle(title)

fmt <- function(){
  function(x) format(x, nsmall = 5, scientific = FALSE)
}

title <- 'Figure 3.2. Slope of stochastic linear trend model.'
slope <- ts(v, start = start(y), frequency = frequency(y))
autoplot(slope) +
  coord_cartesian(y = c(-.01, .01)) +
  scale_y_continuous(labels = fmt()) +
  ggtitle(title)

title <- 'Figure 3.3. Irregular component of stochastic linear trend model.'
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
    lty = c(2,1), col = c('tomato', 'black'))
}
plot_sims(fit, 'mu', y, 50)
