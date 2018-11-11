close all
clear;
clc;
results = zeros(6,7);

%fileName =  'Wandeling_1a.mp4';
for i=1:6
    data = gaitAnalysis(i);
    for j=1:7
        results(i,j) = data(j);
    end
end

