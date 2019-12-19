## load_packages
pkgs <- c(
  "rstan",
  "ggplot2",
  "ggfortify",
  "forecast")
missing_vec <- !sapply(pkgs, require, character.only = T)
invisible(sapply(pkgs[missing_vec], install.packages))

# do in parallel
rstan_options(auto_write = TRUE)
options(mc.cores = parallel::detectCores())

## ukdrivers

ukdrivers <- read.table('data/UKdriversKSI.txt', skip = 1)
ukdrivers <- ts(ukdrivers[[1]], start = c(1969, 1), frequency = 12)
ukdrivers <- log(ukdrivers)

## ukdriversm

ukdriversm <- read.table('data/UKfrontrearseatKSI.txt', skip = 1)
colnames(ukdriversm) <- c('UK drivers KSI', 'front seat KSI', 'rear Seat KSI',
                          'Kilometers driven', 'petrol price')
ukdriversm <- ts(ukdriversm, start = c(1969, 1), frequency = 12)

## ukpetrol

ukpetrol <- read.table('data/logUKpetrolprice.txt', skip = 1)
ukpetrol <- ts(ukpetrol, start = start(ukdrivers), frequency = frequency(ukdrivers))

## ukseats

ukseats <- c(rep(0, (1982 - 1968) * 12 + 1), rep(1, (1984 - 1982) * 12 - 1))
ukseats <- ts(ukseats, start = start(ukdrivers), frequency = frequency(ukdrivers))

## ukinflation

ukinflation <- read.table('data/UKinflation.txt', skip = 1)
ukinflation <- ts(ukinflation[[1]], start = c(1950, 1), frequency = 4)

## ukpulse

ukpulse <- rep(0, length.out = length(ukinflation))
ukpulse[4*(1975-1950)+2] <- 1
ukpulse[4*(1979-1950)+3] <- 1
ukpulse <- ts(ukpulse, start = start(ukinflation), frequency = frequency(ukinflation))

## fatalities

fatalities <- read.table('data/NorwayFinland.txt', skip = 1)
colnames(fatalities) <- c('year', 'Norwegian_fatalities',
                          'Finnish_fatalities')
norwegian_fatalities <- fatalities[['Norwegian_fatalities']]
norwegian_fatalities <- log(ts(norwegian_fatalities, start = 1970, frequency = 1))
finnish_fatalities <- fatalities[['Finnish_fatalities']]
finnish_fatalities <- log(ts(finnish_fatalities, start = 1970, frequency = 1))

## func_defs

is.converged <- function(stanfit) {
  summarized <- summary(stanfit)$summary
  all(summarized[!(rownames(summarized) %in% 'lp__'), 'Rhat'] < 1.1)
}

is.almost.fitted <- function(result, expected, tolerance = 0.05) {
  print(sprintf("%0.4f vs %0.4f (%0.3f%%)", result, expected,
    (abs(expected - result)/expected)*100))
  if ((abs(expected - result)/expected) > tolerance) {
    return(FALSE)
  } else {
    return(TRUE)
  }
}