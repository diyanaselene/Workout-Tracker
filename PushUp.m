%Dillon G
clear
clc
% need Addons both found in the IDE/HOME/Addons
%      1- Image Acquisition Toolbox 
%      2-MATLAB Support Package for USB Webcams 

% ---- Summary of algorithim ----
% 1. take 3 images background, up, and down positions of push up
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
imgBack = calibratedImages{1};
%imgUP = calibImages{2}; %unused but for clarity
%imgDown = calibImages{3}; %unused but for clarity
%--- get centroids of Up and Down
for i = 2:3
    % image Subtraction
    diff = abs(double(calibratedImages{i}) - double(imgBack));
    bw = diff > 50; % Adjust threshold depending
    bw = bwareafilt(bw, 1); % Keep only the largest object (the person)
    
    stats = regionprops(bw, 'Centroid');
    if ~isempty(stats)
        centroids(i, :) = stats(1).Centroid;
    end
end
centroidUpY = centroids(2, 2);  
centroidDownY = centroids(3, 2);
fprintf("target y : %2.f", centroidUpY)
fprintf("target X : %2.f", centroidDownY)
%% Live application 

pushUpCount = 0;
atBottom = false; %need to ensure they go down then up to count
pushUpThreshold = 20; %pixel threshold for how close you can be to count
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
        %find largest moving area (person)
        [~, id] = max([stats2.Area]);
        currCentroid = stats2(id).Centroid;
        currY = currCentroid(2); %vertical cord
        
        %handle logic for counting pushups ensuring down then up to count
        if ~atBottom &&(currY >= (centroidDownY - pushUpThreshold))
            atBottom = true; %set to true
            disp("reached bottom")
        end

        if atBottom && (currY <=(centroidUpY+pushUpThreshold))
            pushUpCount = pushUpCount+1;
            atBottom = false; %reset
            fprintf("Push ups: %d\n", pushUpCount);
        end
        
        %--- display on screen the centroid and target positions
        imshow(currFrame);
        hold on;
        plot(currCentroid(1), currCentroid(2), 'r*', 'MarkerSize', 12);
        yline(centroidUpY, 'g--', 'Up Target');
        yline(centroidDownY, 'b--', 'Down Target');
        hold off;
    end
   drawnow();

end
%% run after program ends to clear camera
clear cam; %clear up cam 