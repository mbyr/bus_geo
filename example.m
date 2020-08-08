% A simply example illustrating the extraction of morphological features
% based on regions of interest (ROIs)
% author: Michal Byra, Polish Academy of Sciences
% email: byra.micha@gmail.com, mbyra@ippt.pan.pl

clc; clear; close all;

load('OASBUD.mat'); % https://zenodo.org/record/545928#.Xy8QwygzaUk

%% reconstruct an ultrasound image based on RF data (for visualization)

rf_data = data(1).rf1; % beamformed RF data matrix
roi = data(1).roi1; % region of interest 

dz = 0.0192; % axial dimension, pixel size [mm]
dy = 38/size(rf_data, 2); % lateral dimension, pixel size [mm]

n = size(roi, 2)*dy/size(roi, 1)/dz;
n = round(512*n);
size_img = [512, n];

img = simple_recon(rf_data, 45, size_img); % reconstruct image at 45 dB and resize

roi = imresize(roi, size_img, 'nearest');
outline = edge(roi, 'sobel');

[x_grid, y_grid] = meshgrid(1:n, 1:512);
ox = x_grid(outline);
oy = y_grid(outline);

figure;

subplot(1, 3, 1)
imshow(img);
title('ultrasound image')

subplot(1, 3, 2)
imshow(roi)
title('region of interest'); 

subplot(1, 3, 3)
imshow(img);
hold on
plot(ox, oy, '.r', 'markersize', 7)
title('image + contour'); 

%% extract morphological features, first imaging plane

features = zeros(length(data), 15); 
c = zeros(length(data), 1); 
names = {'area', 'nrv', 'rs', 'convexity', 'dwr', 'circularity', 'roundness', 'elli_skel', 'long_short', 'elli_circumference', 'orient', 'nrl_mean', 'nrl_std', 'nrl_ra', 'nrl_rough'};

for i=1:length(data)
    
    roi = data(i).roi1;
    roi = imresize(roi, size_img, 'nearest');
    
    features(i, :) = morph_features(roi); 
    c(i) = data(i).class; 
    
end

%% use the area under receiver operating characteristic curve to assess the usefulness of each feature

scores = zeros(length(data), 1); 

for j=1:size(features, 2)
    
    mdl = fitglm(features(:, j), c,'Distribution','binomial','Link','logit');
    scores = predict(mdl, features(:, j));
    
    [~, ~, ~, AUC] = perfcurve(c, scores, 1);
    disp(['Feature ', names{j}, ': ', num2str(AUC, 3)])

end

