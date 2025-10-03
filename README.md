# Satellite Image Time Series (SITS) for Amazon Analysis

The sits package uses satellite image time series for land classification, using a time-first, space-later approach. In the data preparation part, collections of big Earth observation images are organized as data cubes. Each spatial location of a data cube is associated with a time series. Locations with known labels are used to train a machine learning algorithm, which classifies all time series of a data cube, as shown below

<img width="1093" height="904" alt="image" src="https://github.com/user-attachments/assets/9a1d0a26-0fd4-4df8-a76e-76535dbced7b" />

The sits API is a set of functions that can be chained to create a workflow for land classification. At its heart, the sits package has eight functions:

1) Extract data from an analysis-ready data (ARD) collection using sits_cube(), producing a non-regular data cube object.
From a non-regular data_cube create a regular one, using sits_regularize(). Regular data cubes are required to train machine learning algorithms.
2) Obtain new bands and indices with operations on regular data cubes with sits_apply().
3) Given a set of ground truth values in formats such as CSV or SHP and a regular data cube, use sits_get_data() to obtain training samples containing time series for selected locations in the training area.
4) Select a machine learning algorithm and use sits_train() to produce a classification model.
5) Given a classification model and a regular data cube, use sits_classify() to get a probability data cube, which contains the probabilities for class allocation for each pixel.
6) Remove outliers in a probability data cube using sits_smooth().
7) Use sits_label_classification() to produce a thematic map from a smoothed probability cube.

<img width="978" height="543" alt="image" src="https://github.com/user-attachments/assets/35cb5a74-8ed1-47f5-beca-1e38f5b235cf" />
