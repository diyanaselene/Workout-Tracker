clear all;
clc;

%read the reference video
video = VideoReader("workout.mov");

%read first frame and convert to grayscale
firstFrame = read(video,1);
ffGray = rgb2gray(firstFrame);

%get roi from first frame
imshow(ffGray)
title("Drag Rectangle Around Athlete's Head")
roi = getrect;
athlete = imcrop(ffGray, roi);

%detect point features of roi/athlete
athletePoints = detectSIFTFeatures(athlete);
figure;
imshow(athlete);
title("100 Strongest Point Features from Athlete Head");
hold on;
plot(selectStrongest(athletePoints, 100));

%extract feature descriptors
[athleteFeatures, athletePoints] = extractFeatures(athlete, athletePoints);

figure
imshow(ffGray);
title("Drag Rectangle Around Athlete's Entire Body")
fullBody = getrect;

yMax = fullBody(2);
yMin = fullBody(2) + fullBody(4);
med = (yMax + yMin) / 2;

%rep counting
scale = 0.5; 
yOffset = 80;
repCount = 0;
repState = 0;
minFeatures = 3;


%% main loop

while hasFrame(video)
    %convert current frame to grayscale
    currFrame = readFrame(video);
    cfg = imresize(rgb2gray(currFrame), scale);
    
    cfgPoints = detectSIFTFeatures(cfg);
    cfgPoints = selectStrongest(cfgPoints, 50);
    [cfgFeatures, cfgPoints] = extractFeatures(cfg, cfgPoints);

    %putative point matches
    pairs = matchFeatures(athleteFeatures, cfgFeatures, MatchThreshold=40,...
        MaxRatio=0.7, Unique=true);
    matchedAthletePoints = athletePoints(pairs(:, 1), :);
    matchedcfgPoints = cfgPoints(pairs(:, 2), :);
    
    %locate object using utative matches
    [tform, inlierIdx] = estgeotform2d(matchedAthletePoints, matchedcfgPoints, "affine");
    inliercfgPoints = matchedcfgPoints(inlierIdx, :);
    
    %scale locations back to original coordinate space
    locs = inliercfgPoints.Location / scale;

    %count features past threshold
    numUp = sum(locs(:, 2) < yMax + yOffset);
    numDown = sum(locs(:, 2) > med - yOffset);
    atUp = numUp >= minFeatures;
    atDown = numDown >= minFeatures;

    %rep state machine (up, down, up)
    if repState == 0 && atUp
        repState = 1;
        fprintf("\nState: Up, go down\n");
    elseif repState == 1 && atDown
        repState = 2;
        fprintf("State: Down, go up\n");
    elseif repState == 2 && atUp
        repState = 0;
        fprintf("State: Up, go down\n");
        repCount = repCount + 1;
        disp("Reps counted: " + repCount);
    end

    %display
    imshow(currFrame);
    hold on;

    %scale back for correct overlay on original frame
    plot(inliercfgPoints.Location(:,1)/scale, ...
         inliercfgPoints.Location(:,2)/scale, ...
        'ro', 'MarkerSize', 5, 'LineWidth', 1);

    yline(yMax + yOffset, 'b--', 'Up Target');
    yline(med - yOffset, 'b--', 'Median Target');
    hold off;

    pause(0.0000000000001/5000)
end

fprintf("Final rep count: %d\n", repCount);
