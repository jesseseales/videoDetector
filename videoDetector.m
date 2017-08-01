function videoDetector(video)
    % Detecting Cars Using Gaussian Mixture Models
    % This example shows how to detect and count cars in a video sequence using
    % foreground detector based on Gaussian mixture models (GMMs).

    %   Copyright 2004-2010 The MathWorks, Inc.

    foregroundDetector = vision.ForegroundDetector('NumGaussians', 3, ...
        'NumTrainingFrames', 50);

    videoReader = vision.VideoFileReader(video);

    % specify region of interest with interactive ROI tool
    frame = step(videoReader);
    mask = roipoly(frame);
    save('maskfile.mat', 'mask'); % save the ROI for use in videoDetectorPi
    
    %lane1 = roipoly(frame);
    %save('lane1.mat', 'lane1');
    %lane2 = roipoly(frame);
    %save('lane2.mat', 'lane2');
    
    
    lane1file = coder.load('lane1.mat');
    lane1 = lane1file.lane1;
    lane2file = coder.load('lane2.mat');
    lane2 = lane2file.lane2;
    
    fileID = fopen('detectedCars.txt','a'); % append to existing text file
   

    for i = 1:149
        frame = step(videoReader); % read the next video frame
        frame_ROI = frame .* mask;
        foreground = step(foregroundDetector, frame_ROI);
    end

    figure; imshow(frame); title('Video Frame');

    figure; imshow(foreground); title('Foreground');

    % Detect cars in an initial video frame
    se = strel('square', 3);
    filteredForeground = imopen(foreground, se);
    figure; imshow(filteredForeground); title('Clean Foreground');

    % find bounding boxes of each connected component corresponding to
    % a moving car by using vision.BlobAnalysis object
    blobAnalysis = vision.BlobAnalysis('BoundingBoxOutputPort', true, ...
        'AreaOutputPort', false, 'CentroidOutputPort', false, ...
        'MinimumBlobArea', 300);
    bbox = step(blobAnalysis, filteredForeground);

    % To highlight the detected cars, we draw green boxes around them.
    result = insertShape(frame, 'Rectangle', bbox, 'Color', 'green');

    numCars = size(bbox, 1);
    result = insertText(result, [10 10], numCars, 'BoxOpacity', 1, ...
        'FontSize', 14);
    figure; imshow(result); title('Detected Cars');


    videoPlayer = vision.VideoPlayer('Name', 'Detected Cars');
    videoPlayer.Position(3:4) = [650,400];  % window size: [width, height]
    se = strel('square', 3); % morphological filter for noise removal
    
    lane1PrevDetect = 0;
    lane2PrevDetect = 0;
    frameCount = 1;

    while ~isDone(videoReader)
        
        step(videoReader); % skip a frame
        frame = step(videoReader); % read every other frame
        frameCount = frameCount + 2;
        frame_ROI = frame .* mask;
        
        % Detect the foreground in the current video frame
        foreground = step(foregroundDetector, frame_ROI);
        
        % Use morphological opening to remove noise in the foreground
        filteredForeground = imopen(foreground, se);
        k = bwconvhull(filteredForeground, 'objects');
        
        % Detect the connected components with the specified minimum area, and
        % compute their bounding boxes
        bbox = step(blobAnalysis, k);

        % Draw bounding boxes around the detected cars
        result = insertShape(frame, 'Rectangle', bbox, 'Color', 'green');
        
        if (lane1PrevDetect == 0) && bwarea(k .* lane1) > 0
            disp('Car found in lane 1');
            outstr = strcat('Car in lane 1 in frame ', num2str(frameCount), '\n');
            fprintf(fileID, outstr);
        end
        lane1PrevDetect = bwarea(k .* lane1);
        
        if (lane2PrevDetect == 0) && bwarea(k .* lane2) > 0
            disp('Car found in lane 2');
            outstr = strcat('Car in lane 2 in frame ', num2str(frameCount), '\n');
            fprintf(fileID, outstr);
        end
        lane2PrevDetect = bwarea(k .* lane2);
       

        % Display the number of cars found in the video frame
        numCars = size(bbox, 1);
        result = insertText(result, [10 10], numCars, 'BoxOpacity', 1, ...
            'FontSize', 14);

        step(videoPlayer, result);  % display the results
    end

    release(videoReader); % close the video file

    % The output video displays the bounding boxes around the cars. It also
    % displays the number of cars in the upper left corner of the video.
    displayEndOfDemoMessage(mfilename)

end

