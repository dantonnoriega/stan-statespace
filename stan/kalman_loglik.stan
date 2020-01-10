/*
  SOURCE: https://gist.github.com/jrnold/4700387#file-kalman-stan

  Multivariate Dynamic linear model

  estimated with

  - Covariance filter (no square root, or sequential processing)
  - time invariant parameters
  - no missing observations
  - known initial value

  Only parameters are the measurement error and system error, both
  of which are assumed to be diagonal.

  .. math::

     y_t &= Z_t \alpha_t + \epsilon_t \\
     \epsilon_t &\sim N(0, H_t) \\
     \alpha_{t+1} = T_t \alpha_t + R_t \eta_t \\
     \eta_t &\sim N(0, Q_t) \\
     \alpha_1 &\sim N(a_1, P_1) \\
     t &= 1, \dots, n

  Dimensions

  ------------------ --------
  variable           dim
  ================== ========
  :math:`y_t`        p, 1
  :math:`\alpha_t`   m, 1
  :math:`epsilon_t`  p, 1
  :math:`eta_t`      r, 1
  :math:`a_1`        m, 1
  :math:`Z_t`        p, m
  :math:`T_t`        m, m
  :math:`H_t`        p, p
  :math:`R_t`        m, r
  :math:`Q_t`        r, r
  :math:`P_1`        m, m

  - :math:`p` dimension of data
  - :math:`n` number of observation
  - :math:`m` number of states
  - :math:`r` number of states with non-zero variance.

  See Durbin & Koopman, Ch 4.2, pp 65-67.

  .. math::

     v_t &= y_t - Z_t a_t \\
     F_t &= Z_t P_t Z_t' + H_t \\
     K_t &= T_t P_t Z_t' F_t^{-1} \\
     L_T &= T_t - K_t Z_t \\
     a_{t+1} &= T_t a_t + K_t v_t \\
     P_{t+1} &= T_t P_t L_t' + R_t Q_t R_t'

  For loglikelihood, Ch. 7.2, pp. 138-139.

  .. math::

     \log L(y) = \sum_{t=1}^n p(y_t | Y_{t-1})

  where :math:`p(y_1 | Y_0) = p(y_1)`.
  Supposing normal distributions,

  .. math::

     \log L(y) &= \sum_{t=1}^n \phi(Z_t a_t, F_t) \\
     &= -\frac{n p}{2} - \frac{1}{2} \sum_{t=1}^n (\log | F_t | + v_t' F_t^{-1} v_t)

*/
data {
  // number of observations
  int n;
  // number of variable == 1
  int p;
  // number of states
  int m;
  // size of system error
  int r;
  // observed data
  vector[p] y[n];
  // observation eq
  matrix[p, m] Z;
  // system eq
  matrix[m, m] T;
  matrix[m, r] R;
  // initial values
  vector[m] a_1;
  cov_matrix[m] P_1;
}
parameters {
  // measurement error
  vector<lower=0.0>[p] h;
  vector<lower=0.0>[r] q;
}
transformed parameters {
  matrix[p, p] H;
  matrix[r, r] Q;
  matrix[p, p] F[n];
  matrix[p, p] Finv[n];
  matrix[m, p] K;
  matrix[m, m] L;
  vector[m] a[n + 1];
  matrix[m, m] P[n + 1];
  H = diag_matrix(h);
  Q = diag_matrix(q);
  // 1st observation
  a[1] = a_1;
  P[1] = P_1;
  for(i in 1:n) {
    F[i] = Z * P[i] * Z' + H;
    Finv[i] = inverse(F[i]);
    K = T * P[i] * Z' * Finv[i];
    L = T - K * Z;
    a[i + 1] = T * a[i] + K * (y[i] - Z * a[i]);
    P[i + 1] = T * P[i] * L' + R * Q * R';
  }
}
model {
  real llik_obs[n];
  real llik;
  for (i in 1:n) {
    vector[p] v;
    v = y[i] - Z * a[i];
    // // manual update of multivariate normal
    llik_obs[i] = -0.5 * (p * log(2 * pi()) + log(determinant(F[i])) + v' * Finv[i] * v);
    //llik_obs[i] = multi_normal_log(y[i], Z * a[i], F);
  }
  llik = sum(llik_obs);
  target += llik;
}
generated quantities {
  vector[p] yhat[n];
  for (i in 1:n)
    yhat[i] = Z * a[i];
}

