# Remote Sensing Workflow with sits in R

⚙️ 1. Setup and Libraries

We load all the necessary R packages:
sits: main package for satellite image time series analysis.
sitsdata 📦: example datasets for practice and testing.
sf 🗺️: handle geospatial vector data (shapefiles, GeoJSON, etc.).
tibble: modern data frames with cleaner output.
dplyr 🔎: easy and fast data manipulation.
rstac: connect to STAC catalogs (e.g., BDC, AWS).

🛰️ 3. Building Cubes

We create satellite data cubes (structured collections of images):
Sentinel-2 Cube (optical data: RGB, NIR, SWIR, NDVI, EVI, CLOUD).
Sentinel-1 Cube (radar data: VV, VH).
🌀 Regularization: harmonize radar data (same resolution, time steps).
🔗 Merge Sentinel-1 + Sentinel-2 cubes for richer analysis.
🌊 NDWI index: calculate water index and reduce it (max NDWI per pixel).
We also explore the cube:
List selected bands

🎯 4. Sample Analysis

We load training samples (ground truth data):
Count total samples
See dimensions & distribution per class
Extract time series from the cube
Balance classes (oversampling/undersampling) to avoid bias

📊 5. Sample Quality & Exploration

Extract time series for training samples (multi-year).
Visualize temporal patterns (NDVI/EVI trends).
Use Self-Organizing Maps (SOM) 🧠 to:
Cluster time series
Evaluate and clean noisy/inconsistent samples
Generate a refined, high-quality training dataset

🤖 6. Classification Models

Train a Random Forest classifier 🌲 with clean samples.
Apply the model to classify the cube → probability maps.
Apply Bayesian smoothing to clean classification.
Generate final labeled maps.
Compute uncertainty cubes to see where the model struggles.
Use uncertainty sampling to identify areas for new samples.
Perform k-fold cross-validation to validate model performance.
