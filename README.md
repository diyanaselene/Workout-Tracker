# Summary

This repository is the Final Project for our Computer Vision class at Tarleton State University, Spring 2026. It incorporates two ways to track workouts without using 
Machine Learning. There is code for live utilization of the 2 algorithms and A GUI to select one of the algorithms that will take in recorded/saved inputs to count.

# Algorithm 1: Centroid Tracking
The core mechanics of the algorithm are using image subtraction to find what changed in the image, saving its centroid. After saving a centroid for the up position and down position, we set a threshold around these centroids. 
Using image subtraction again, we compute a centroid of a live camera feed that will increment a value once it reaches both down and up thresholds.

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

# Algorithm 2: Point Feature Matching Tracking
The Point Feature Matching Algorithm was used to locate and track the athlete's head throughout a workout video. Using the ymin and height (used to determine median) of the athletes full body, an up and down threshold are determined based on adding an offset to the ymin and median. The features from every frame are used to determine if the athlete is in an UP or Down position. After completing a cycle of UP, Down, and UP, the rep counter is incremented.

**Algorithm summary**
1. The user draws a bounding box around the athlete's head in the first frame. The Point Feature Matching Algorithm detects and extracts features from the Head ROI.
2. The user draws a second bounding box around the athlete's full body. The getrect function returns the ymin and height of the region, which is used, along with an offset, to determine the up and down threadhold.
3. Each frame from the video undergoes Point Feature Matching with the Head ROI. Features determine if the athlete in the current scene is in UP or Down position.
4. State machine tracks the athlete's movement cycle and increments the rep counter after a completed cycle. Reps are determined after completing a cycle of up, down, and up.

**Concerns/ limitations**
* Tracking accuracy can go down if the athletes head moves out of frame.
* Camera movement or a dynamic background can introduce false feature matches
* Because the algorithm reiterates every frame, video playback is slow so long videos may be slow to ptocess.

# GUI 
Combines both algorithms in a MATLAB Application. Giving the option to choose between a live application or Recorded video. 
