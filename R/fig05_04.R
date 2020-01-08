source('R/common.R', encoding = 'utf-8')

## init_stan
y <- ukdrivers
x <- ukpetrol
standata <- within(list(), {
  y <- as.vector(y)
  x <- as.vector(x)
  n <- length(y)
  init_mu = c(y[1],sd(y[1:5])) # add mu init prior; sd() uses first 5 obs
})

## show_model
# this model samples poorly because of it fails to handle the
# seaonality; see page 54 of book:
#    "For the moment, we do not draw any practical conclusions from the analyses of the
#     UK drivers KSI series presented in this chapter as an essential component
#     is missing in model (5.2), which is the seasonal.
model_file <- 'stan/fig05_04.stan'
cat(paste(readLines(model_file)), sep = '\n')
model <- rstan::stan_model(model_file)
fit <- rstan::sampling(model, data = standata,
            # up the iterations and shrink adapt_delta
            # compensates for imposing a poor model
            control = list(adapt_delta = .99, max_treedepth = 16),
            warmup = 2000,
            iter = 10000, chains = 2)
is.converged(fit)

yhat <- get_posterior_mean(fit, par = 'yhat')[, 'mean-all chains']
mu <- get_posterior_mean(fit, par = 'mu')[, 'mean-all chains']
beta <- get_posterior_mean(fit, par = 'beta')[, 'mean-all chains']
sigma_mu <- get_posterior_mean(fit, par = 'sigma_mu')[, 'mean-all chains']
sigma_irreg <- get_posterior_mean(fit, par = 'sigma_irreg')[, 'mean-all chains']
is.almost.fitted(mu[[1]], 6.824) # i think this number is wrong in book
is.almost.fitted(beta, -0.26105)
is.almost.fitted(sigma_irreg^2, 0.0116673)

## output_figures
title <- 'Figure 5.4. Stochastic level and deterministic explanatory variable ‘log petrol price’.'
yhat <- ts(yhat, start = start(y), frequency = frequency(y))
layout(matrix(1:2, nrow=2))
plot(y, main = title)
lines(yhat, col = 4, lty = 3, lwd = 2)
legend(x = par("usr")[1], y = par("usr")[4],
  col = c(1,4), lty=c(1,3), seg.len = 3, cex = .6,
  legend = c("log UK drivers KSI", "stochastic level + beta*log(PETROL PRICE)"))
#
title <- 'Figure 5.5. Irregular for stochastic level model with deterministic explanatory variable ‘log petrol price’.'
plot(y - yhat, lty = 3, main = title)

forecast::ggtsdisplay(y - yhat) # LOADS of seasonality/autocorrelation in the model
