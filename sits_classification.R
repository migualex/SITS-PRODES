```{r setup, include=FALSE}
knitr::opts_chunk$set(echo = TRUE)

# 1. Install libraries and packages:
library(sits)

library(sitsdata)
# https://github.com/e-sensing/sitsdata
# An auxiliary sits package that provides example datasets for testing, learning, and validating sits functions.
# Contains ready-to-use data cubes and time series examples.

library(sf)
# https://r-spatial.github.io/sf/
# Package for handling spatial vector data in R (a modern replacement for sp).
# Allows working with shapefiles, GeoJSON, and other vector formats, as well as performing spatial operations such as intersections, buffers, and projection transformations.

library(tibble)
# https://tibble.tidyverse.org/
# Package for manipulating tables in the tibble format, a modern and improved version of data.frame.
# Offers better visualization, clearer indexing, and seamless integration with tidyverse packages.

library(dplyr)
# https://dplyr.tidyverse.org/
# Package for efficient manipulation of tabular data.
# Provides functions such as filter, select, mutate, summarize, and group_by in a clear, fast, and readable manner.
# Essential for data analysis, especially in tidyverse workflows.

library(rstac)
# https://brazil-data-cube.github.io/rstac/
# Package that allows interaction with data catalogs following the STAC (SpatioTemporal Asset Catalog) standard.
# Facilitates search, filtering, and access to metadata and assets (images, mosaics, collections) hosted in STAC catalogs, such as BDC, AWS, etc.

# 2. Directories, folders, and paths:
# Main directory:
# Path to main directory:
main_dir_path <- "C:/main_dir_path"

# Path to image cubes:
images_path <- "C:/images_path"

# Path to training samples:
samp_path <-"C:/samp_path"

# Path to reduced samples:
reduces_path <- "C:/reduces_path"

# Path to classification outputs:
classification_path <- "C:/classification_path"

# 3. Cube:
## Sentinel-2 cube definition
cube <- sits_cube(
    source = "BDC",
    collection  =  "SENTINEL-2-16D",
    bands = c('B02', 'B03', 'B04', 'B08', 'B11', 'NDVI', 'EVI', 'CLOUD'),
    tiles = c('012014'),
    start_date = '2024-01-01',
    end_date = '2024-12-31'
    )

# Cube selection and filtering
cube_select <- sits_select(
           cube,
           bands = c('B02', 'B03', 'B04', 'B08', 'B11', 'NDVI', 'EVI','CLOUD'),
           tiles = c('012014'),
           start_date = '2024-01-01',
           end_date = '2024-12-31',
           data_dir = images_path
           ) 
# 3.1: Sentinel-1:
## Sentinel-1 (Radar) cube
cube_s1_rtc <- sits_cube(
    source = "MPC",
    collection = "SENTINEL-1-RTC",  
    bands = c("VV", "VH"),
    orbit = "descending",
    tiles = c("20MLS","20MMS","20LLR","20LMR"),
    start_date = "2024-01-01",
    end_date = "2024-12-31"
)

plot(cube_s1_rtc, band = "VH", palette = "Greys")

# Create a regular RTC cube from MPC collection
cube_s1_reg <- sits_regularize(
    cube = cube_s1_rtc,
    period = "P16D",
    res = 40,
    tiles = c("20MLS","20MMS","20LLR","20LMR"),
    memsize = 12,
    multicores = 6,
    output_dir = images_path
)

plot(cube_s1_reg, band = "VH", palette = "Greys", scale = 0.7)

# Merge Sentinel-1 and Sentinel-2 cubes
cube_s1_s2 <- sits_merge(cube, cube_s1_reg)

# Plot a composite image with both SAR and optical bands
plot(cube_s1_s2, red = "B11", green = "B8A", blue = "VH")

# 3.2: NDWI:
# Calculate the NDWI index
cube_select2 <- sits_apply(
    cube_select,
    NDWI = (B03 - B11) / (B03 + B11),
    output_dir = images_path,
    progress = TRUE
)

plot(cube_select2, band = "NDWI", palette = "Blues")

# Reduce the NDWI index cube
max_ndwi_cube <- sits_reduce(cube_select2,
    NDWIMAX = t_max(NDWI),
    output_dir = images_path,
    multicores = 20,
    progress = TRUE
)
plot(max_ndwi_cube, band = "NDWIMAX")
#################################################################################################v
# 3.3. Cube exploration:

# Select bands from the cube
bands_cube_select <- sits_bands(cube_select) 
cat("Selected bands:\n", bands_cube_select) 
cat("\n\n")

# Check dates of mosaics available in the cube
timeline <- sits_timeline(cube_select)
cat("Cube timeline:\n") 
print(timeline) 
cat("\n")

# Select the first image in the timeline
first_date <- timeline[1]
cat("First date of the cube:\n")
print(first_date)
cat("\n")

# Select the last image in the timeline
last_date <- timeline[length(timeline)] 
# Corresponds to the index of the last image in the series
cat("Last date of the cube:\n")
print(last_date)

# 4. Sample analysis:
# Import the training sample set with the classes of interest
sample_path <- samp_path

# Use the sf library to handle geospatial sample data
samples_sf <- st_read(sample_path) 


# View total number of samples
n_samples <- nrow(samples_sf)
cat("Total number of samples:", n_samples, "\n\n")

# Sample dimensions
dim_samples <- dim(samples_sf)
cat("Data dimensions (rows x columns):", dim_samples, "\n")

# Number of samples per class
table(samples_sf$label)

# Retrieve time series for each sample based on a data.frame
samples_lem_time_series <- sits_get_data(
    cube = cube,
    samples = samples_sf,
    progress = TRUE
)

# Reduce imbalance between the classes
samples_sf2 <- sits_reduce_imbalance(
    samples_lem_time_series,
    n_samples_over = 150,
    n_samples_under = 300
)

# Show summary of the balanced time series dataset
summary(samples_sf2)

#### 5.1. Sample analysis - Extracting time series from the data cube:
# Extract time series for collected samples
samples_rondonia_2024 <- sits_get_data(
                      cube = cube_select,
                      samples = samples_sf,
                      start_date = '2020-01-01',
                      end_date = '2024-12-31',
                      label = "label",
                      multicores = 20,
                      progress = TRUE
                      )
# 5.2. Sample visualization:
# Visualization of class temporal patterns - all time series
plot(samples_rondonia_2024)
# Visualization of smoothed temporal patterns (NDVI and EVI)
samples_rondonia_2024 |> 
  sits_select(bands = c("NDVI", "EVI"), start_date = '2020-01-01', end_date = '2024-12-31') |> 
  sits_patterns() |> 
  plot()
# 5.3. Sample quality assessment:
# SOM - Self-Organizing Maps (SOM)

# Cluster time series using SOM
som_cluster <- sits_som_map(
    samples_rondonia_2024,
    grid_xdim = 12,
    grid_ydim = 12,
    rlen = 100,
    distance = "dtw",
    som_radius = 2,
    mode = "online"
)

# Plot the SOM map
plot(som_cluster)
# Produce a tibble summarizing mixed labels
som_eval <- sits_som_evaluate_cluster(som_cluster)

som_eval
# Plot evaluation of SOM clusters
plot(som_eval)
# Clean noisy or inconsistent samples using SOM evaluation
all_samples <- sits_som_clean_samples(
    som_map = som_cluster, 
    prior_threshold = 0.6,
    posterior_threshold = 0.6,
    keep = c("clean", "analyze", "remove"))

# Print the sample distribution after evaluation
plot(all_samples)
# Generate a refined sample set with only "clean" and "analyze" classes
new_samples_v2 <- sits_som_clean_samples(
    som_map = som_cluster, 
    prior_threshold = 0.6,
    posterior_threshold = 0.6,
    keep = c("clean", "analyze"))

# Summary of the new sample distribution
summary(new_samples_v2)
# Cluster refined samples with SOM again
som_cluster_new <- sits_som_map(new_samples_v2,
            grid_xdim = 12,
            grid_ydim = 12,
            rlen = 100,
            distance = "dtw",
            som_radius = 2,
            mode = "online")
# Produce a tibble summarizing mixed labels of refined SOM clusters
som_eval_new <- sits_som_evaluate_cluster(som_cluster_new)

som_eval_new

# Plot evaluation results
plot(som_eval_new)
# 6. Classification models:
# Random Forest model training
# Random seed:
set.seed(03022024)

# Train a Random Forest classifier
rf_model <- sits_train(
         samples = new_samples_v2, 
         ml_method = sits_rfor()
)

# Plot the most important variables in the model
plot(rf_model)
# Classify the data cube to produce a probability map
class_prob <- sits_classify(
    data = cube_select, 
    ml_model = rf_model,
    multicores = 20,         
    memsize = 50,            
    output_dir = classification_path,
    version = "vp",
    progress = TRUE
)

plot(class_prob, label = "dms_solo_exposto", palette = "RdYlGn")
# Apply Bayesian smoothing to classification results
rondonia_smooth <- sits_smooth(
    cube = class_prob,
    multicores = 20,
    memsize = 50,
    version = 'vp',
    output_dir = classification_path,
    progress = TRUE
)

plot(rondonia_smooth, label = "dms_solo_exposto", palette = "RdYlGn")
# Final classification labeling
class_map <- sits_label_classification(
    cube = rondonia_smooth,
    memsize = 50,
    multicores = 20,
    version = "vp",
    output_dir = classification_path,
    progress = TRUE
) 

plot(class_map, label = "dms_solo_exposto", palette = "Greens")
# 6.3. Uncertainty cube:
# Compute the uncertainty cube from classification results
s2_cube_uncert <- sits_uncertainty(
    cube = rondonia_smooth,
    type = "margin",
    memsize = 50,
    multicores = 20,
    version = "vp",
    output_dir = classification_path,
    progress = TRUE
)

plot(s2_cube_uncert)
# Identify samples with high uncertainty
new_samples <- sits_uncertainty_sampling(
    uncert_cube = s2_cube_uncert,
    n = 100,
    min_uncert = 0.5,
    sampling_window = 10
)

sits_view(new_samples)
# Perform k-fold cross-validation for Random Forest model
rfor_validate_mt <- sits_kfold_validate(
    samples = samples_rondonia_2024,
    folds = 5,
    ml_method = sits_rfor(),
    multicores = 5
)

rfor_validate_mt
