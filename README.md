# Reproducing "An Introduction to State Space Time Series Analysis" using Stan

Original Author: github.com/sinhrks
Extended/Modified: github.com/dantonnoriega

Trying to reproduce the examples introduced in "An Introduction to State Space Time Series Analysis" using Stan.

## Data

SOURCE: http://www.ssfpack.com/CKbook.html

- `data/`
    - `logUKpetrolprice.txt`
    - `NorwayFinland.txt`
    - `UKdriversKSI.txt`
    - `UKinflation.txt`
    - `UKfrontrearseatKSI.txt`



## R scripts

All the R scripts are in `R/`.

All the files were edit to be more concise. In many cases, I switch from using ggplot2 to base R graphics.

Each file is tied to a headline figure. Most files will also carry forward and plot any complimentary plots between one headline figure and the next e.g. `fig04_02.R` creates figures `4.2` - `4.5`, up to the next headline file `fig04_06.R`.

1. Introduction
    - fig01_01.R: Linear regression
2. The local level model
    - fig02_01.R: Deterministic level
    - fig02_03.R: Stochastic level
    - fig02_05.R: The local level model and Norwegian fatalities
3. The local linear trend model
    - fig03_01.R: Stochastic level and slope
    - fig03_04.R: Stochastic level and deterministic slope
    - fig03_05.R: The local linear trend model and Finnish fatalities
4. The local level model with seasonal
    - fig04_02.R: Deterministic level and seasonal
    - fig04_06.R: Stochastic level and seasonal
    - fig04_10.R: The local level and seasonal model and UK inflation
5. The local level model with explanatory variable
    - fig05_01.R: Deterministic level and explanatory variable
    - fig05_04.R: Stochastic level and explanatory variable
6. The local level model with intervention variable
    - fig06_01.R: Deterministic level and intervention variable
    - fig06_04.R: Stochastic level and intervention variable
7. The UK seat belt and inflation models
    - fig07_01.R: Deterministic level and seasonal
    - fig07_02.R: Stochastic level and seasonal
    - fig07_07.R: The UK inflation model
8. General treatment of univariate state space models
    - fig08_02.R: Confidence Intervals *(NEW)*
    - fig08_05.R: Filtering and Prediction *(NEW)*
9. Multivariate time series analysis
10. State space and Box–Jenkins methods for time series analysis

**IMPORTANT** Some models output different results from textbook and R's `{dlm}` package.
