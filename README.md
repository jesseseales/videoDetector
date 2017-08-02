# videoDetector
### Description: 
videoDetector is a modified version of the Matlab example program 'videotrafficgmm'. This program uses Gaussian mixture models to detect the foreground of a video frame, then applies blob detection to detect automobiles. A specific region of interest on the video frame should be specified. Also a counting mechanism uses two seperate regions of interest (corresponding to two lanes on the road) to count the number of cars in each lane.

---

### Usage:
1. The program expects a parameter for the name of the video you would like to process. The video is expected to be in the same directory as the program, or otherwise you should specify the path.
2. A window will appear with a video frame loaded, expecting a region of interest selection. Upon completion, double-click or right click and press create mask to continue the process.
3. Two .mat files named 'lane1.mat' and 'lane2.mat' are expected to be in the working directory. Otherwise, this code can be commented out and code to select and save two lane regions can be enabled.
4. There is a short training phase, then detection will start.
5. A text file named 'detectedCars.txt' will be opened or created to write the lanes and corresponding frames in which cars are detected.

---

### Code Generation:
A modified version of this program can be created to support code generation. Here are the steps necessary:
1. Replace `mask = roipoly(frame)` with `maskfile = coder.load('maskfile.mat');` and then  `mask = maskfile.mask;`
because roipoly is not supported by code generation. This means a mask must be saved ahead of time as 'maskfile.mat' in the working directory so that it can be loaded in later.
2. Disable all code related to displaying the frames and videos (e.g. `imshow`, `videoPlayer.position`, `insertShape`, `insertText`, `step(videoPlayer, result)`)
3. Hard-code the name of the video file rather than using a variable in the function parameter.
4. Use `coder.varsize('frame');` after declaring `frame` in order to explicitly define variable data
5. replace `frame .* mask` with `frame(1:w, 1:h) .* mask` where w and h are the width and height of the frame respectively, in order to explicitly make the operation of the same matrix dimensions
6. Remove `k = bwconvhull(filteredForeground, 'objects')` because that method is not supported for code generation. Replace `k` in call to `bbox = step(blobAnalysis, k)` to be `bbox = step(blobAnalysis, filteredForeground)` Note: this means that blobs will not be reshaped in the code generation program, potentially affecting accuracy.
