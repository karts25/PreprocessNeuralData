function dat = prunebyfiringrate(dat,params)

yAll = dat.spikes;
binwidth = 1000;


num_intervals = floor(size(yAll,2)/binwidth);
num_neurons = size(yAll,1);
spikecounts_interval = zeros(num_neurons,num_intervals);

% if matlabpool('size') == 0
%     matlabpool open
% end

for t = 1:num_intervals
    %fprintf('%d of %03d\n',t,size(yAll,2)/binwidth);
    interval = (t-1)*binwidth+1:t*binwidth;
    spikecounts_interval(:,t) = sum(yAll(:,interval),2);
end
inactive_neurons = mean(spikecounts_interval,2) < params.minFiringRate;

for j = 1:length(dat)
    dat(j).spikes(inactive_neurons,:) = [];
end
