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

background = read(vid,10);
f = read(vid,235);

subplot(1,2,1)
imshow(background);

subplot(1,2,2)
imshow(f);

%figure
%imdivide does not provide solutions
%imshow(imdivide(rgb2gray(background),rgb2gray(f)));

%bw = activecontour(rgb2gray(background),rgb2gray(f));
%imshow(bw);

figure

background = im2double(background);
f = im2double(f);

for i=1:1:8
    subplot(2,4,i)
    [dif_i, f_i] = removeBackgroundRGB(background,f,0.05 * i);
    imshow(rgb2bin(f_i));
    %title('i=%f',i);
end

figure
%backgroundG = rgb2gray(background);
%fG = rgb2gray(f);



[dif,fb] = removeBackgroundRGB(background,f,0.15);
subplot(2,3,1)
imshow(fb(:,:,1));
subplot(2,3,2)
imshow(fb(:,:,2));
subplot(2,3,3)
imshow(fb(:,:,3));

subplot(2,3,4)
imshow(dif);
subplot(2,3,5)
imshow(fb);
subplot(2,3,6)
imshow(rgb2bin(fb));

figure

subplot(1,2,1)
imshow(rgb2bin(fb));
subplot(1,2,2)
imshow(fb(:,:,1)&fb(:,:,2)&fb(:,:,3));
figure

fG = rgb2bin(fb);
imshow(fG);
figure 

se_disk=strel('disk',5,0);
se_rec=strel('rectangle',[5 5]);
se_disk2=strel('disk',7,0);
se_rec2=strel('rectangle',[7 7]);
%Demonstrate different filtering steps
subplot(2,3,1);
imshow(fG);
fG2 = fG;
title('Original');


subplot(2,3,2);
fG = imopen(fG,se_rec);
imshow(fG);
title('First opening rect 5x5');

subplot(2,3,3);
fG = imclose(fG,se_disk);
imshow(fG);
title('First closing disk 5');

subplot(2,3,4);
fG = imopen(fG,se_rec2);
imshow(fG);
title('Second opening rect 7x7');

subplot(2,3,5);
fG = imclose(fG,se_disk2);
imshow(fG);
title('Second closing disk 7');

figure
subplot(1,4,1);
imshow(fG2);
title('Original');

subplot(1,4,2);
fG2 = imopen(fG2,se_rec2);
imshow(fG2);
title('First opening rect 7x7');

subplot(1,4,3);
fG2 = imclose(fG2,se_disk2);
imshow(fG2);
title('First closing disk 7');

subplot(1,4,4);
imshow(xor(fG2,fG));
title('XOR to show differences');
figure

imshow(fG);

[L, number] = bwlabel(fG,8);
stats = regionprops(L,'basic');
for r=1:1:number
    area = stats(r).Area;
    %[upperLeftX; upperLeftY; x_len; y_len] = stats(r).BoundingBox;
    test = stats(r).BoundingBox;
    upperLeftX = test(1);
    upperLeftY = test(2);
    x_len = test(3);
    y_len = test(4);
    centerX = stats(r).Centroid(1);
    centerY = stats(r).Centroid(2);
    %[centerX, centerY] = stats(r).Centroid;
    rectangle('Position',[upperLeftX,upperLeftY,x_len,y_len],'EdgeColor','b');
    rectangle('Position',[centerX-2, centerY-2,4,4],'Curvature',[1 1],'EdgeColor','g','FaceColor','g');
end

