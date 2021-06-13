% octave script for Flappy bird example data plotting

clear all; clc;

data = csvread("perf_data.csv");

best = data(:, 2);

% calculate average
avgBest = zeros(size(best));
for i = 1:size(avgBest)
  for j = 1:i
    avgBest(i) += best(j);
  endfor
  avgBest(i) /= i;
endfor


x = data(:, 1);
% plot from timestamp
subplot(2, 1, 1);
ax = plotyy(x, best, x, avgBest);
title ("Score evolution of the best individual");
xlabel ("Time");
ylabel (ax(1), "Score");
ylabel (ax(2), "Average Score");

% plot from generation
x = 1:size(best);
subplot(2, 1, 2);
ax = plotyy(x, best, x, avgBest);
title ("Score evolution of the best individual");
xlabel ("Generation");
ylabel (ax(1), "Score");
ylabel (ax(2), "Average Score");
