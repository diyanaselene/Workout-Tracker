%Dillon G
clear
clc
% need Addons both found in the IDE/HOME/Addons
%      1- Image Acquisition Toolbox 
%      2- MATLAB Support Package for USB Webcams 

% ---- Summary of algorithim ----
% 1. take 3 images background, up, and down positions of workout up
% 2. use image subtraction to get centroids of up and down pos
% 3. use image subtraction on live video to show movement & track centroid
% 4. once the moving centroid reaches threshold of down then Up centroids
%    increment counter by 1. 
% 
% **NOTE must go all the way down then up to count
%
% ------

cam = webcam(1); %built in webcam
preview(cam);
%---Calibration----
labels = {'Background', 'Up', 'Down'};
centroids = zeros(3, 2); % To store [x, y] for Up and Down
calibratedImages = cell(1,3);
% we need to take pictures of backgroun, up and down positions
for i = 1:3
    fprintf('Position yourself for: %s. Then press any key.\n', labels{i});
    
    % Wait for user to press a key
    waitforbuttonpress; 
    pause(5) %pause for 5 seconds to get into pos
    
    % Capture and store
    img = snapshot(cam);
    calibratedImages{i} = rgb2gray(img);
    
    % Confirmation on pose
    imshow(img);
    title(['Captured: ', labels{i}]);
    pause(1); % Brief pause to show the capture
end

disp("--- calibration complete---")
imgBack = calibratedImages{1}; %2 is up 3 is down
diffImages = cell(1,2);
%--- get centroids of Up and Down
for i = 2:3
    % image Subtraction
    %diff = abs(double(calibratedImages{i}) - double(imgBack));
    diff = abs(double(imgBack)-double(calibratedImages{i}) );
    bw = diff > 50; % Adjust threshold depending
    bw = bwareafilt(bw, 1); % Keep only the largest object (the person)
    
    stats = regionprops(bw, 'Centroid');
    if ~isempty(stats)
        centroids(i, :) = stats(1).Centroid;
    end
    diffImages{i} = bw;
end
centroidUpY = centroids(2, 2);  
centroidDownY = centroids(3, 2);
fprintf("target y : %2.f", centroidUpY)
fprintf("target X : %2.f", centroidDownY)
clear cam;

%% This shows our up target image (not req)
% imshow(diffImages{2})
% hold on;
% plot(centroids(2,1), centroids(2,2), 'r*', 'MarkerSize', 18,'LineWidth',3);
% yline(centroidUpY, 'b--', 'Up Target','LineWidth',3,'FontSize',14);
% hold off
%% This shows our Down target image (not req)
% %hold off
% imshow(diffImages{3})
% hold on;
% plot(centroids(3,1), centroids(3,2), 'r*', 'MarkerSize',  18,'LineWidth',3);
% yline(centroidDownY, 'b--', 'Down Target','LineWidth',3,'FontSize',14);
%% Live application 
%cam = webcam(1); %built in webcam
%preview(cam);
%%
workoutCount = 0;
atBottom = false; %need to ensure they go down then up to count
workoutThreshold = 20; %pixel threshold for how close you can be to count
while true
    currFrame = snapshot(cam);
    CFGray = rgb2gray(currFrame);

    %image sub 
    diff= abs(double(CFGray)- double(imgBack));
    bwF = diff > 50; % Adjust threshold depending
    bwF = bwareafilt(bwF, 1); 
    
    %Centroid tracking
    stats2 = regionprops(bwF,'Centroid','Area');
    if ~isempty(stats2)
        %find largest moving area (assumed to be the person)
        [~, id] = max([stats2.Area]);
        currCentroid = stats2(id).Centroid;
        currY = currCentroid(2); %vertical cord
        
        %handle logic for counting ensuring down then up to count
        if ~atBottom &&(currY >= (centroidDownY - workoutThreshold))
            atBottom = true; %set to true
            disp("reached bottom")
        end

        if atBottom && (currY <=(centroidUpY+workoutThreshold))
            workoutCount = workoutCount+1;
            atBottom = false; %reset
            fprintf("Workount Count: %d\n", workoutCount);
        end
        
        %--- display on screen the centroid and target positions
        imshow(currFrame);
        hold on;
        plot(currCentroid(1), currCentroid(2), 'r*', 'MarkerSize', 12);
        yline(centroidUpY, 'b--', 'Up Target');
        yline(centroidDownY, 'b--', 'Down Target');
        hold off;
    end
   drawnow();

end
clear cam;
%% run after program ends to clear camera
clear cam; %clear up cam 