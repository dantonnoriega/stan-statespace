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
  a1 <- y[1] # initialize with starting y[1]
  P1 <- 1
})

## kalman filter version of model in section 7.3
model_file <- 'stan/fig08_08.stan'
cat(paste(readLines(model_file)), sep = '\n')
model <- rstan::stan_model(model_file)
kf_fit <- rstan::sampling(model, data = standata,
            control = list(adapt_delta = .9, max_treedepth = 16),
            warmup = 1000, iter = 3000, chains = 4)
is.converged(kf_fit)

yhat <- get_posterior_mean(kf_fit, par = 'yhat')[, 'mean-all chains']
a <- get_posterior_mean(kf_fit, par = 'a')[, 'mean-all chains']
K <- get_posterior_mean(kf_fit, par = 'K')[, 'mean-all chains']
FF <- get_posterior_mean(kf_fit, par = 'F')[, 'mean-all chains']

# plot kalman filter vs data
title <- 'Kalman Filter model of Section 7.3'
plot_y_yhat(y, yhat, title)

# plot standardized residuals of kalman filter on model in section 7.3
title <- 'Figure 8.8. Standardised one-step prediction errors of model in Section 7.3.'
yhat <- ts(yhat, start = start(y), frequency = frequency(y)) # drop first obs
v <- ts(y - yhat, start = start(y), frequency = frequency(y)) # drop first obs
FF <- ts(FF, start = start(y), frequency = frequency(y))
e <- v/sqrt(FF)
e <- tail(e, -14) # drop first 14 lags; see page 90
plot(e, type = 'l', lwd = 1, lty = 3, main = title)
abline(h=0)
legend(x = par("usr")[1], y = par("usr")[4],
  col = c(1), lty=c(3), seg.len = 3, cex = .6, box.lwd = 1.3,
  legend = c("prediction errors"))

title <- paste('Figure 8.9. Correlogram of',
  'standardised one-step prediction errors in Figure 8.8, first 10 lags.')
forecast::ggAcf(e, 10) + ggtitle(title)

# this is hard to make! no obvious break points
title <- paste('Figure 8.10. Histogram of standardised one-step',
  'prediction errors in Figure 8.8.')
hist(e, main = title, breaks = seq(-3.4,3.4,.4), prob = TRUE, ylim = c(0,.4))
curve(dnorm(x, mean(e), sd(e)), add= TRUE, lty = 3)