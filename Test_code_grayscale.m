close all
clear;
clc;

% create video  object
vid = VideoReader('Wandeling_1b.mp4');

%Get properties from video
framerate = vid.framerate;
duration = vid.duration;
no_frames = vid.NumberOfFrames;
vidHeight = vid.Height;
vidWidth = vid.Width;

background = read(vid,1);
f = read(vid,200);

subplot(1,2,1)
imshow(background);

subplot(1,2,2)
imshow(f);

figure

backgroundG = rgb2gray(im2double(background));
fG = rgb2gray(im2double(f));

subplot(1,2,1)
imshow(backgroundG);

subplot(1,2,2)
imshow(fG);

figure

mask1= [-1, -1, -1; 2, 2, 2; -1, -1, -1];
mask2= [-1, 2, -1; -1, 2, -1; -1, 2, -1];
mask3= [2, -1, -1; -1, -1, 2; -1, -1, 2];
mask4= [-1, -1, 2; -1, 2, -1; 2, -1, -1];
f_1 = imfilter(fG, mask1, 'conv', 'replicate','same');
f_2 = imfilter(fG, mask2, 'conv', 'replicate','same');
f_3 = imfilter(fG, mask3, 'conv', 'replicate','same');
f_4 = imfilter(fG, mask4, 'conv', 'replicate','same');

treshold = 0.15;
f_1 (abs(f_1) > treshold) = 1;
f_1 (abs(f_1) < treshold) = 0;

f_2 (abs(f_2) > treshold) = 1;
f_2 (abs(f_2) < treshold) = 0;

f_3 (abs(f_3) > treshold) = 1;
f_3 (abs(f_3) < treshold) = 0;

f_4 (abs(f_4) > treshold) = 1;
f_4 (abs(f_4) < treshold) = 0;

subplot(2,2,1)
imshow(f_1);
subplot(2,2,2)
imshow(f_2);
subplot(2,2,3)
imshow(f_3);
subplot(2,2,4)
imshow(f_4);

figure
subplot(2,2,1)
imshow(xor(f_1,xor(f_2,xor(f_3,f_4))));
subplot(2,2,2)
imshow(f_1&f_2&f_3&f_4);
subplot(2,2,3)
imshow(f_1|f_2|f_3|f_4);
subplot(2,2,4)

f_3 = imfill(f_3,'holes');
imshow(f_3);


figure
[dif,fbG] = removeBackgroundGrayscale(backgroundG,fG,0.15);
imshow(fbG);
figure 
se1=strel('disk',5);
se2=strel('disk',3);
f1 = imopen(fbG,se2);
f1 = imopen(f1,se2);
%f1 = imdilate(f1,se1);
f1 = imclose(f1,se1);
imshow(f1);