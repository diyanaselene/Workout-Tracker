# Summary

This repository is the Final project for our Computer Vision class at Tarleton State University, Spring 2026. It incorporates two ways to track workouts without using 
Machine Learning. There is code for live utilization of the 2 algorithms and A GUI to select one of the algorithms that will take in recorded/saved inputs to count.

# Algorithm 1: Centroid Tracking
The core mechanics of the algorithm are using image subtraction to find what changed in the image, saving its centroid. After saving a centroid for the up position and down position, we set a threshold around these centroids. 
using image subtraction again, we compute a centroid of a live camera feed that will increment a value once it reaches both down and up thresholds.

**Algorithm summary**
1. 3 images are required for calibrating the centroid tracking target points. (Background Image, Up position, Down position)
2. Image subtraction between the background image and the images for each position. A centroid of each position is calculated, with it being set as its target centroid
4. Image subtraction between the background image and a live camera feed is applied. A centroid is then calculated for the live image subtraction, representing movement in the live feed
5. A threshold around the target positions is then set using the calibrated image target centroids.
6. Once the live feed centroid enters the threshold for down and then up, the counter will increment for the given workout.

**Concerns/ limitations**
* Moving background will interfere with live centroid tracking; use a static background
* Similarly, any changes in light will interfere, as this affects the background
* Adjust threshold for target centroids depending on need


# Algorithm 2: ##### Tracking

**Algorithm summary**

**Concerns/ limitations**

# GUI 
