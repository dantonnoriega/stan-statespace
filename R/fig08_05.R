source('R/common.R', encoding = 'utf-8')

## init_stan
y <- norwegian_fatalities
standata <- within(list(), {
  s <- frequency(y)
  y <- as.vector(y)
  n <- length(y)
  a1 <- 6 # inits
  P1 <- .1 # inits
 })

## show_model
# reuse model 08_05
model_file <- 'stan/fig08_05.stan'
cat(paste(readLines(model_file)), sep = '\n')
model <- rstan::stan_model(model_file)
kf_fit <- rstan::sampling(model, data = standata,
            control = list(adapt_delta = .8, max_treedepth = 10),
            warmup = 1000, iter = 6000, chains = 2)
is.converged(kf_fit)

a <- get_posterior_mean(kf_fit, par = 'a')[, 'mean-all chains']
K <- get_posterior_mean(kf_fit, par = 'K')[, 'mean-all chains']
FF <- get_posterior_mean(kf_fit, par = 'F')[, 'mean-all chains']

# use model from fig 02_03
model_file <- 'stan/fig02_03.stan'
cat(paste(readLines(model_file)), sep = '\n')
model <- rstan::stan_model(model_file)
fit <- rstan::sampling(model, data = standata,
            control = list(adapt_delta = .8, max_treedepth = 10),
            warmup = 1000, iter = 6000, chains = 2)
is.converged(fit)

mu <- get_posterior_mean(fit, par = 'mu')[, 'mean-all chains']

## generate credibility (confidence) intervals
title <- 'Figure 8.5. Smoothed and filtered state of the local
  level model applied to Norwegian road traffic fatalities.'
mu <- ts(mu, start = start(y), frequency = frequency(y))
a <- ts(a, start = start(y), frequency = frequency(y)) # drop first obs
a[1] <- NA # drop initial guess
layout(1)
plot(mu, lwd = 1.2, main = title)
lines(a, col = 4, lty = 3)
legend(x = par("usr")[1], y = par("usr")[3]*1.01,
  col = c(1,4), lty=c(1,3), seg.len = 3, cex = .6,
  legend = c("smoothed level","filtered level"))

## generate credibility (confidence) intervals
title <- 'Figure 8.7. One-step ahead prediction errors (top) and
their variances (bottom) for the local level model applied to Norwegian
road traffic fatalities.'
FF <- ts(FF, start = start(y), frequency = frequency(y))
v <- ts(y - a, start = start(y), frequency = frequency(y)) # drop first obs
a[1] <- NA # drop initial guess
layout(1:2)
plot(v, type = 'l', lwd = 1, lty = 3, main = title)
abline(h=0)
legend(x = par("usr")[1], y = par("usr")[4],
  col = c(1), lty=c(3), seg.len = 3, cex = .6, box.lwd = 1.3,
  legend = c("prediction errors"))
plot(FF, type = 'l', col = 1, lty = 3)
legend(x = par("usr")[1]+2, y = par("usr")[4],
  col = c(1), lty=c(3), seg.len = 3, cex = .6, box.lwd = 1.3,
  legend = c("prediction errors"))


## generate credibility (confidence) intervals
# i chose to standarize the errors from section 8.4
title <- 'Figure 8.8.* Standardised one-step prediction errors of model in Section 8.4.'
sub <- '*Book standardizes the errors from Section 7.3.'
e <- v/sqrt(FF)
layout(1)
plot(e, type = 'l', lwd = 1, lty = 3, main = title, sub = sub)
abline(h=0)
legend(x = par("usr")[1], y = par("usr")[4],
  col = c(1), lty=c(3), seg.len = 3, cex = .6, box.lwd = 1.3,
  legend = c("prediction errors"))
