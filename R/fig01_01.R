source('R/common.R', encoding = 'utf-8')

## init_stan ----------

y <- ukdrivers

standata <- within(list(), {
  y <- as.vector(y)
  n <- length(y)
})

## show_model ----------

model_file <- 'models/fig01_01.stan'
cat(paste(readLines(model_file)), sep = '\n')

## fit_stan ----------

fit <- stan(model_file, data = standata,
            iter = 2000, chains = 4)
stopifnot(is.converged(fit))

## output_figures ----------
slope <- get_posterior_mean(fit, par = 'slope')[, 'mean-all chains']
intercept <- get_posterior_mean(fit, par = 'intercept')[, 'mean-all chains']
title <- paste('Figure 1.1. Scatter plot of the log of the number of UK drivers',
               'KSI against time (in months), including regression line.', sep = '\n')
p <- autoplot(y, ts.geom = 'point')

# stan
yhat <- ts(1:length(y) * slope + intercept,
           start = start(y), frequency = frequency(y))
p <- autoplot(yhat, p = p, ts.colour = 'blue')

# lm
df <- data.frame(y = y, x = 1:length(y))
fit.lm <- lm(y ~ x, data = df)
intercept.lm <- coefficients(fit.lm)[[1]]
slope.lm <- coefficients(fit.lm)[[2]]
lm.yhat <- ts(df$x * slope.lm + intercept.lm,
              start = start(y), frequency = frequency(y))
p <- autoplot(lm.yhat, p = p, ts.colour = 'red', ts.linetype = 'dashed')
p + ggtitle(title)

title <- 'Figure 1.2. Log of the number of UK drivers KSI plotted as a time series.'
autoplot(y) + ggtitle(title)

title <- paste('Figure 1.3. Residuals of classical linear regression of the ',
               'log of the number of UK drivers KSI on time.', sep = '\n')
autoplot(y - yhat, ts.linetype = 'dashed') + ggtitle(title)
