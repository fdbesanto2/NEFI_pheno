% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/plotForecastOutput.R
\name{plotForecastOutput}
\alias{plotForecastOutput}
\title{Function to plot phenology forecast output}
\usage{
plotForecastOutput(siteName, forecastType, URL, forecastLength, out.mat, days)
}
\arguments{
\item{siteName}{The site name to be printed on the graph}

\item{forecastType}{The type of forecast (randomWalk or logistic)}

\item{URL}{The PhenoCam URL}

\item{forecastLength}{The number of days in the future you want to forecast}

\item{out.mat}{The predict variables of the MCMC output of the forecast in matrix form}
}
\description{
Function to plot phenology forecast output
}
