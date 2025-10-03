# Satellite Image Time Series (SITS) Analysis of the Amazon Rainforest

The sits package uses satellite image time series for land classification, using a time-first, space-later approach. In the data preparation part, collections of big Earth observation images are organized as data cubes. Each spatial location of a data cube is associated with a time series. Locations with known labels are used to train a machine learning algorithm, which classifies all time series of a data cube.
