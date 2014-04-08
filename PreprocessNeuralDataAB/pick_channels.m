function ignored_channels = pick_channels(Data,coincident_channels)
% For channels that are shorted together, pick channel with highest average firing rate
% input: Data
%        coincident_channels: cell array where each element is an array of
%                             channels that are shorted together

channels = [Data(1).TrialData.spikes.channel];
neuron_indices = cell(1,length(coincident_channels));
channel_indices = cell(1,length(coincident_channels));
for i = 1:length(channels)
    channel = channels(i);
    for j = 1:length(coincident_channels)
        [member,index] = ismember(channel,coincident_channels{j});
        if member
            neuron_indices{j} = [neuron_indices{j} i];
            channel_indices{j} = [channel_indices{j} index];
        end
    end
end

for i = 1:length(coincident_channels)
    for j = channel_indices{i}
        spikes_all{i}{j} = [];
    end
end


for num_trial = 1:length(Data)
    trial = Data(num_trial);
    TrialData = trial.TrialData;
    timeMoveOnset = TrialData.timeMoveOnset;
    timeMoveEnd = TrialData.timeMoveEnd;
    
    if (isnan(timeMoveOnset)||isnan(timeMoveEnd)) % Skip trials without a market movement onset or end
        continue
    end
    
    if isempty(TrialData.spikes)
        continue;
    end
    timeMoveOnset = timeMoveOnset - 300; % Get data starting 300ms before onset
    T = round(timeMoveEnd - timeMoveOnset);
    for j = 1:length(coincident_channels)
        for channel_index = channel_indices{j}
            alltimestamps_selected{channel_index} = [];
        end
        for i = 1:length(neuron_indices{j})
            neuron_index = neuron_indices{j}(i);
            channel_index = channel_indices{j}(i);
            % if channel is one of the coincident channels, extract its
            % spike info
            timestamps = TrialData.spikes(neuron_index).timestamps;
            timestamps_selected = timestamps((timestamps >= timeMoveOnset) & (timestamps <= timeMoveEnd));
            timestamps_selected = timestamps_selected - timeMoveOnset+1; % align to timeMoveOnset
            alltimestamps_selected{channel_index} = [alltimestamps_selected{channel_index} timestamps_selected];
        end
        for channel_index = channel_indices{j}
            temp_timestamps = sort(alltimestamps_selected{channel_index},'ascend');
            extracted_spikes = zeros(1,T);
            extracted_spikes(1,temp_timestamps) = 1;
            spikes_all{j}{channel_index} = [spikes_all{j}{channel_index} extracted_spikes];
        end
    end
end

binwidth = 1000;
for i = 1:length(coincident_channels)
    % find channel with highest rate
    means = zeros(1,length(unique(channel_indices{i})));
    for j = channel_indices{i}
        yAll = spikes_all{i}{j};
        num_intervals = floor(size(yAll,2)/binwidth);
        spikecounts = [];
        for t = 1:num_intervals
            interval = (t-1)*binwidth+1:t*binwidth;
            spikecounts(:,t) = sum(yAll(:,interval),2);
        end
        means(j) = mean(spikecounts);
    end
    maxrate_channel(i) = find(means == max(means));
end

% return these channels
ignored_channels = [];
for i = 1:length(coincident_channels)
    channels = coincident_channels{i};
    channels(maxrate_channel(i)) = [];
    ignored_channels = [ignored_channels channels];
end

