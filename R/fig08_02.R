source('R/common.R', encoding = 'utf-8')

## init_stan
y <- ukdrivers
standata <- within(list(), {
  y <- as.vector(y)
  n <- length(y)
  s <- 12
})

## show_model
# reuse model 08_02
model_file <- 'stan/fig08_02.stan'
cat(paste(readLines(model_file)), sep = '\n')
model <- rstan::stan_model(model_file)
fit <- rstan::sampling(model, data = standata,
            control = list(adapt_delta = .8, max_treedepth = 10),
            warmup = 1000, iter = 2000, chains = 2)
is.converged(fit)

mu <- get_posterior_mean(fit, par = 'mu')[, 'mean-all chains']
yhat <- get_posterior_mean(fit, par = 'yhat')[, 'mean-all chains']
seasonal <- get_posterior_mean(fit, par = 'seasonal')[, 'mean-all chains']

## generate credibility (confidence) intervals
title <- 'Figure 8.2. Stochastic level and its 90% confidence interval for stochastic
  level and deterministic seasonal model applied to the log of UK drivers KSI.'
mu <- ts(mu, start = start(y), frequency = frequency(y))
mu_samples <-
  rstan::As.mcmc.list(fit, pars = 'mu') %>%
    do.call(rbind, .)
mu_CI <- mu_samples %>%
  apply(., 2, quantile, c(.1,.9))
xx <- c(time(mu), rev(time(mu)))
layout(1:3)
plot(y, lwd = 1.2, main = title)
lines(mu, col = 4, lwd = 1.2, lty = 2)
polygon(x = xx, y = c(mu_CI[1,], rev(mu_CI[2,])), border=NA, col=scales::alpha('gray80', .5))
legend(x = par("usr")[1], y = par("usr")[4],
  col = c(1,4), lty=1, seg.len = 3, cex = .6,
  legend = c("log UK drivers KSI",
    parse(text=sprintf('"stochastic level" %%+-%% "1.64"~sigma[mu]'))))

title <- 'Figure 8.3. Deterministic seasonal and its 90% confidence interval for stochastic
  level and deterministic seasonal model applied to the log of UK drivers KSI.'
seasonal_samples <-
  rstan::As.mcmc.list(fit, pars = 'seasonal') %>%
    do.call(rbind, .)
seasonal_CI <- seasonal_samples %>%
  apply(., 2, quantile, c(.1,.9))
seasonal_CI10 <- seasonal_CI[1,]
seasonal_CI90 <- seasonal_CI[2,]
seasonal <- ts(seasonal, start = start(y), frequency = frequency(y))
xx <- c(time(seasonal), rev(time(seasonal)))
plot(seasonal, col=2, lty=2, main=title)
polygon(x = xx, y = c(seasonal_CI10, rev(seasonal_CI90)),
  border=NA, col=scales::alpha('gray80', .5))
legend(x = par("usr")[1], y = par("usr")[4],
  col = c(2), lty=1.2, seg.len = 3, cex = .6,
  legend = parse(text=sprintf('"deterministic seasonal" %%+-%% "1.64"~sigma')))

title <- 'Figure 8.4. Stochastic level plus deterministic seasonal and its 90%
  confidence interval for stochastic level and deterministic seasonal model
  applied to the log of UK drivers KSI.'
yhat <- ts(yhat, start = start(y), frequency = frequency(y))
yhat_samples <-
  rstan::As.mcmc.list(fit, pars = 'yhat') %>%
    do.call(rbind, .)
yhat_CI <- yhat_samples %>%
  apply(., 2, quantile, c(.1,.9))
xx <- c(time(yhat), rev(time(yhat)))
plot(yhat, col = 6, lty = 1, lwd = 1.2, main = title)
polygon(x = xx, y = c(yhat_CI[1,], rev(yhat_CI[2,])),
  border=NA, col=scales::alpha('gray80', .5))
legend(x = par("usr")[1], y = par("usr")[4],
  col = 6, lty=1, seg.len = 3, cex = .6,
  legend = parse(text=sprintf('"signal" %%+-%% "1.64"~sigma')))


