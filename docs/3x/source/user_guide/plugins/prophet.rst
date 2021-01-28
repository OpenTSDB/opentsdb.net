Facebook Prophet
================
.. index:: prophet
Prophet is a time series forecasting tool open sourced by Facebook that aims to account for various seasonality of behavior as well as auto detecting change points and anticipating different behavior during holidays. Details can be found on the `Prophet <https://facebook.github.io/prophet/>`_ page.

.. WARNING::

	This is still a work in progress. Currently the plugin shells out to a Python script that runs the Prophet python module. It's less than efficient but it's enough to get started building a UI.

Fields specific to the prophet config include:

.. csv-table::
   :header: "Name", "Data Type", "Required", "Description", "Default", "Example"
   :widths: 10, 5, 5, 45, 10, 25
   
   "numberofChangePoints", "Numeric", "Optional", "The number of anticpated change points spread evenly across the historical data. Must be smaller than the number of points fed into the training algo.", "25", "1440"
   "growth", "String", "Optional", "One of ``LINEAR``, ``LOGISTIC``, ``FLAT``. The anticipated change in values over time, e.g. growing linearly or logarithmically.", "LINEAR", "LOGISTIC"
   "changePointRange", "Numeric", "Optional", "Proportion of history in which trend changepoints will be estimated. Defaults to 0.8 for the first 80%. Not used if ``changepoints`` (not implemented yet) is specified.", "0.80", "0.50"
   "yearlySeasonality", "Boolean", "Optional", "Whether or not to look for yearly seasonality. If null, defaults to auto detection.", "null", "true"
   "weeklySeasonality", "Boolean", "Optional", "Whether or not to look for weekly seasonality. If null, defaults to auto detection.", "null", "true"
   "dailySeasonality", "Boolean", "Optional", "Whether or not to look for daily seasonality. If null, defaults to auto detection.", "null", "true"
   "seasonalityMode", "String", "Optional", "One of ``ADDITIVE`` or ``MULTIPLICATIVE``. TODO not sure what it is.", "ADDITIVE", "MULTIPLICATIVE"
	"seasonalityPriorScale", "Numeric", "Optional", "Parameter modulating the strength of the seasonality model. Larger values allow the model to fit larger seasonal fluctuations, smaller values dampen the seasonality. Can be specified for individual seasonalities using add_seasonality.", "10", "25"
	"holidayPriorScale", "Numeric", "Optional", "Parameter modulating the strength of the holiday components model, unless overridden in the holidays input.", "10", "25"
	"changepointPriorScale", "Numeric", "Optional", "Parameter modulating the flexibility of the automatic changepoint selection. Large values will allow many changepoints, small values will allow few changepoints.", "0.05", "0.10"
	"mcmcSamples", "Numeric", "Optional", "If greater than 0, will do full Bayesian inference with the specified number of MCMC samples. If 0, will do MAP estimation", "0", "5"
	"uncertaintyIntervalWidth", "Numeric", "Optional", "Width of the uncertainty intervals provided for the forecast. If ``mcmcSamples`` = 0, this will be only the uncertainty in the trend using the MAP estimate of the extrapolated generative model. If ``mcmcSamples`` > 0, this will be integrated over all model parameters, which will include uncertainty in seasonality.", "0.8", "0.5"
	"uncertaintySamples", "Numeric", "Optional", "Number of simulated draws used to estimate uncertainty intervals. Settings this value to 0 or False will disable uncertainty estimation and speed up the calculation.", "1000", "0"

