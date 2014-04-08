function plot_tuning_curve(filename)
close all
if nargin < 1
    filename = './20130316/officialDataset/Lincoln20130316handControl_psSorted_processed';
end
tstart = 300-150;
tend = 300+150;
numtargets = 8;
load(strcat(filename,'_target_1'));
num_neurons = size(dat(1).spikes,1);
tuningcurve = zeros(num_neurons,numtargets);

for i = 1:numtargets
    load(strcat(filename,'_target_',num2str(i)));
    for n = 1:length(dat)
        tuningcurve(:,i) = tuningcurve(:,i) + sum(dat(n).spikes(:,tstart:tend),2);
    end
    tuningcurve(:,i) = tuningcurve(:,i)/n;
end

numgroups = num_neurons/10;
for i = 1:numgroups
    figure; hold on;
    for j = 1:10
        subplot(5,2,j); 
        plot(1:numtargets,tuningcurve((i-1)*10+j,:));
    end
end