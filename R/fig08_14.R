source('R/common.R', encoding = 'utf-8')

# local level model setup from top of pg. 75 -------------
y <- finnish_fatalities
standata <-
  within(list(), {
    y <- as.matrix(y) # must be column vectors
    n <- length(y)
    h <- 5 # forecast horizon
    p <- 1 # number of predictors
    m <- 2
    r <- 2
    a_1 <- c(y[1], .1)
    P_1 <- as.matrix(Matrix::bdiag(.25,.01))
    Z <- matrix(c(1,0),p,m)
    T <- matrix(c(1,0,1,1),m,m)
    R <- diag(rep(1,r))
  })
# standata

# kalman filter ----------------
model_file <- 'stan/kalman.stan'
cat(paste(readLines(model_file)), sep = '\n')
model <- rstan::stan_model(model_file)
fit <- rstan::sampling(model, data = standata,
            control = list(adapt_delta = .8, max_treedepth = 15),
            warmup = 1000, iter = 2000,
            chains = 6, seed = 12345)
stopifnot(is.converged(fit))

# extract samples ---------------
## kalman filter within sample
Z <- standata$Z
yhat <- get_posterior_mean(fit, par = 'yhat')[, 'mean-all chains']
a <- get_posterior_mean(fit, par = 'a')[, 'mean-all chains'] %>%
  matrix(standata$n + 1, standata$m, byrow=TRUE)
P <- get_posterior_mean(fit, par = 'P')[, 'mean-all chains'] %>%
  array(c(standata$m, standata$m, standata$n + 1))

## forecasted values
yhat_fc <- get_posterior_mean(fit, par = 'yhat_fc')[, 'mean-all chains']
a_fc <- get_posterior_mean(fit, par = 'a_fc')[, 'mean-all chains'] %>%
    matrix(standata$h, standata$m, byrow=TRUE)
P_fc <- get_posterior_mean(fit, par = 'P_fc')[, 'mean-all chains'] %>%
  array(c(standata$m, standata$m, standata$h))

# model credibility intervals -----------------
yhat_CI <- function(n, p, a, P, Z) {
  sapply(1:nrow(a), function(x) {
    quantile(Z %*% t(mvtnorm::rmvnorm(n, a[x,], P[,,x])), p)
  })
}
yhat_LB = head(yhat_CI(1000, .05, a, P, Z), -1) # keep first n (exclude last, n+1)
yhat_UB = head(yhat_CI(1000, .95, a, P, Z), -1)
# first value excluded; will be way off
yhat_LB[1] = NA
yhat_UB[1] = NA
yhat[1] = NA

# get the forecasted CI -------------
yhat_fc_LB <- yhat_CI(1000, .05, a_fc, P_fc, Z)
yhat_fc_UB <- yhat_CI(1000, .95, a_fc, P_fc, Z)

# append last values to the start of the fc values (prettier plots)
yhat_fc    <- c(tail(yhat,1), yhat_fc)
yhat_fc_LB <- c(tail(yhat_LB,1), yhat_fc_LB)
yhat_fc_UB <- c(tail(yhat_UB,1), yhat_fc_UB)

# output plots -----------
title <- paste('Figure 8.14. Filtered trend, and five-year forecasts',
  'for Finnish fatalities, including their 90% confidence limits.', sep = '\n')
yhat <- ts(yhat, start = start(y), frequency = frequency(y))
yhat_fc <- ts(yhat_fc, start = tsp(y)[2])
xx <- seq(tsp(y)[1], tsp(yhat_fc)[2], by = 1/tsp(y)[3])
plot(y, ylim = c(5.25, 7.25), xlim = c(min(xx), max(xx)),
  main = title, cex.main = .8)
polygon(x = c(time(y), rev(time(y))),
  y = c(yhat_LB, rev(yhat_UB)),
  border = NA, col = scales::alpha('gray50', .3))
polygon(x = c(time(yhat_fc), rev(time(yhat_fc))),
  y = c(yhat_fc_LB, rev(yhat_fc_UB)),
  border = NA, col = scales::alpha('steelblue', .3))
lines(yhat, lty = 3, lwd = 1.2)
lines(yhat_fc, lty = 3, lwd = 1.2, col = 4)

