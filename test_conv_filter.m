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

%Find half the number of frames:
if mod(no_frames,2) ~= 0
    half_no_frames = (no_frames+1) / 2;
else
    half_no_frames = (no_frames) / 2;
end


for i=1:no_frames-1
    
    frame = read(vid,i);
    
    f = double(rgb2gray(frame)) / 255.0;
    
    mask1= [-1, -1, -1; 2, 2, 2; -1, -1, -1];
    mask2= [-1, 2, -1; -1, 2, -1; -1, 2, -1];
    mask3= [2, -1, -1; -1, -1, 2; -1, -1, 2];
    mask4= [-1, -1, 2; -1, 2, -1; 2, -1, -1];
    f_1 = imfilter(f, mask1, 'conv', 'replicate','same');
    f_2 = imfilter(f, mask2, 'conv', 'replicate','same');
    f_3 = imfilter(f, mask3, 'conv', 'replicate','same');
    f_4 = imfilter(f, mask4, 'conv', 'replicate','same');
    
    treshold = 0.15;
    f_1 (abs(f_1) > treshold) = 1;
    f_1 (abs(f_1) < treshold) = 0;

    f_2 (abs(f_2) > treshold) = 1;
    f_2 (abs(f_2) < treshold) = 0;

    f_3 (abs(f_3) > treshold) = 1;
    f_3 (abs(f_3) < treshold) = 0;

    f_4 (abs(f_4) > treshold) = 1;
    f_4 (abs(f_4) < treshold) = 0;
    
    se_disk=strel('disk',5,0);
    se_rec=strel('rectangle',[5 5]);
    se_disk2=strel('disk',7,0);
    se_rec2=strel('rectangle',[7 7]);
    
    f_3 = medfilt2(f_3,'symmetric');
    
    f_3 = imclose(f_3,se_disk);
    
    imshow(f_3);
end