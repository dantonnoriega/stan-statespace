source('R/common.R', encoding = 'utf-8')

## local level model setup from top of pg. 75
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

## kalman filter
model_file <- 'stan/kalman.stan'
cat(paste(readLines(model_file)), sep = '\n')
model <- rstan::stan_model(model_file)
fit <- rstan::sampling(model, data = standata,
            control = list(adapt_delta = .8, max_treedepth = 15),
            warmup = 1000, iter = 2000,
            chains = 6, seed = 12345)
stopifnot(is.converged(fit))

Z <- standata$Z
R <- standata$R
T <- standata$T
yhat <- get_posterior_mean(fit, par = 'yhat')[, 'mean-all chains']
H <- get_posterior_mean(fit, par = 'H')[, 'mean-all chains']
Q <- get_posterior_mean(fit, par = 'Q')[, 'mean-all chains'] %>%
  matrix(2,2)
a <- get_posterior_mean(fit, par = 'a')[, 'mean-all chains'] %>%
  matrix(standata$n + 1, standata$m, byrow=TRUE)
P <- get_posterior_mean(fit, par = 'P')[, 'mean-all chains'] %>%
  array(c(standata$m, standata$m, standata$n + 1))
F <- get_posterior_mean(fit, par = 'F')[, 'mean-all chains']
v <- y - c(Z %*% t(a[seq_along(y),]))
# forecast values
yhat_fc <- get_posterior_mean(fit, par = 'yhat_fc')[, 'mean-all chains']
a_fc <- get_posterior_mean(fit, par = 'a_fc')[, 'mean-all chains'] %>%
    matrix(standata$h, standata$m, byrow=TRUE)
P_fc <- get_posterior_mean(fit, par = 'P_fc')[, 'mean-all chains'] %>%
  array(c(standata$m, standata$m, standata$h))

# parameter 90% confidence intervals -----------------
## naive approach assumes no correlation. close, but lets be precise!
# a_CI_LB_naive = sapply(1:nrow(a), function(x) a[x,] - qnorm(.95)*sqrt(diag(P[,,x])))
# a_CI_UB_naive = sapply(1:nrow(a), function(x) a[x,] + qnorm(.95)*sqrt(diag(P[,,x])))

## here we do a bivariate normal draws such that alpha_hat[t] ~ N(a[t], P[t])
##   where a is 2x1, P is 2x2 covariace matrix
# a_CI <- function(n, p, a, P) {
#   sapply(1:nrow(a), function(x) apply(mvtnorm::rmvnorm(n, a[x,], P[,,x]), 2, quantile, p))
# }
# a_LB = a_CI(1000, 0.05, a, P)
# a_UB = a_CI(1000, 0.95, a, P)

# model 90% credibility intervals -----------------
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
plot(y, ylim = c(5,8), xlim = c(min(xx), max(xx)), main = title)
polygon(x = c(time(y), rev(time(y))),
  y = c(yhat_LB, rev(yhat_UB)),
  border = NA, col = scales::alpha('gray50', .3))
polygon(x = c(time(yhat_fc), rev(time(yhat_fc))),
  y = c(yhat_fc_LB, rev(yhat_fc_UB)),
  border = NA, col = scales::alpha('steelblue', .3))
lines(yhat, lty = 3, lwd = 1.2)
lines(yhat_fc, lty = 3, lwd = 1.2, col = 4)

