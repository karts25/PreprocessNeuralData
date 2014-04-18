function plot_tuning_curve(params)

fname = sprintf('%s/%s',params.dat_folder,params.input_file);
tstart = 0 + 100;

load(fname);
[targets,numTargets] = findTargets(dat,params);


num_neurons = size(dat(1).spikes,1);
tuningcurve = zeros(num_neurons,numTargets);

for num_trial = 1:length(dat)
    % find target index
    [~,target_index] = ismember(dat(num_trial).target,targets,'rows');
    tuningcurve(:,target_index) = tuningcurve(:,target_index) + sum(dat(num_trial).spikes(:,tstart:end),2);
end

numgroups = num_neurons/10;
for i = 1:numgroups
    figure; hold on;
    for j = 1:10
        subplot(5,2,j); 
        plot(1:numTargets,tuningcurve((i-1)*10+j,:));
    end
end
keyboard