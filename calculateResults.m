close all
clear;
clc;
%This code calculates all results for the six given films and stores
%them in the 6x7 matrix results. The columns present these values:
%[avgTime,sumTime,avgDis,sumDis,avgSpeed,walking_duration,walking_speed]
%The rows represent the six films.
results = zeros(6,7);
for i=1:6
    data = gaitAnalysis(i);
    for j=1:7
        results(i,j) = data(j);
    end
end

