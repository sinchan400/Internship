RGB = '/MATLAB Drive/intern/RGB';
BINARY = '/MATLAB Drive/intern/BINARY';
GRAY = '/MATLAB Drive/intern/GRAY';
RESIZED = '/MATLAB Drive/intern/RESIZED';
CSV = '/MATLAB Drive/intern/CSV/allCounts.csv';
CSV_HORIZONTAL = '/MATLAB Drive/intern/CSV/horizontal_profile.csv';  
CSV_VERTICAL = '/MATLAB Drive/intern/CSV/vertical_profile.csv';  
CSV_COMBINED = '/MATLAB Drive/intern/CSV/combined.csv';
CSV_DCT = '/MATLAB Drive/intern/CSV/dct.csv';
CSV_FFT = '/MATLAB Drive/intern/CSV/fft.csv';

fileList = dir(fullfile(RGB, '*.jp*g'));
zoneSize = 8;
numZones = (256 / zoneSize) ^ 2;
% Number of images per class
imagesPerClass = 20;

% Initialize matrices for profiles and class labels
allCounts = zeros(length(fileList), numZones + 1);
allHorizontalProfiles = zeros(length(fileList), 256);
allVerticalProfiles = zeros(length(fileList), 256);
combinedCounts = zeros(length(fileList), 513);  
allFFTs = zeros(length(fileList), 256);
allDCTs = zeros(length(fileList), numZones);

% Initialize an array to store all zone counts for all images
allZoneCounts = zeros(length(fileList), numZones);

for i = 1:length(fileList)
    filePath = fullfile(RGB, fileList(i).name);
    originalImage = imread(filePath);

    % Resize the image
    resizedImage = imresize(originalImage, [256, 256]);
    resizedFilePath = fullfile(RESIZED, fileList(i).name);
    
    gray_img = rgb2gray(resizedImage);
    GrayFilePath = fullfile(GRAY, fileList(i).name);
    
    % Adaptive thresholding
    binary_img = imbinarize(gray_img);
    BlackFilePath = fullfile(BINARY, fileList(i).name);

    % Calculate DCT
    dct_img = dct2(double(gray_img));
    
    % Calculate zone counts
    zoneIndex = 1;
    for r = 1:zoneSize:256
        for c = 1:zoneSize:256
            zone = binary_img(r:r+zoneSize-1, c:c+zoneSize-1);
            onesCount = sum(zone(:));
            allZoneCounts(i, zoneIndex) = onesCount;

            dct_zone = dct_img(r:r+zoneSize-1, c:c+zoneSize-1);
            zoneStatistic = sum(dct_zone(:));
            allDCTs(i, zoneIndex) = zoneStatistic;

            zoneIndex = zoneIndex + 1;
        end
    end
    % Combine zone counts and add class label
    allCounts(i, 1:numZones) = allZoneCounts(i, :);

    % Calculate profiles
    horizontalProfiles = sum(binary_img, 1);
    verticalProfiles = sum(binary_img, 2);
    horizontalProfileFFT = abs(fft(horizontalProfiles));

    % Store profiles in matrices
    allHorizontalProfiles(i, :) = horizontalProfiles;
    allVerticalProfiles(i, :) = verticalProfiles;
    allFFTs(i, :) = horizontalProfileFFT;

    % Combine profiles and add class label
    combinedCounts(i, 1:512) = [horizontalProfiles, verticalProfiles'];
    
    % Assign class label based on the specified pattern
    if i <= imagesPerClass
        allCounts(i, numZones + 1) = 1;  % Class 1
        combinedCounts(i, 513) = 1;  % Class 1
    elseif i <= 2 * imagesPerClass
        allCounts(i, numZones + 1) = 2;  % Class 2
        combinedCounts(i, 513) = 2;  % Class 2
    elseif i <= 3 * imagesPerClass
        allCounts(i, numZones + 1) = 3;  % Class 3
        combinedCounts(i, 513) = 3;  % Class 3
    else
        allCounts(i, numZones + 1) = 4;  % Class 4
        combinedCounts(i, 513) = 4;  % Class 4
    end
end
csvwrite(CSV, allCounts);
csvwrite(CSV_HORIZONTAL, allHorizontalProfiles);
csvwrite(CSV_VERTICAL, allVerticalProfiles);
csvwrite(CSV_COMBINED, combinedCounts);
csvwrite(CSV_FFT, allFFTs);
csvwrite(CSV_DCT, allDCTs);