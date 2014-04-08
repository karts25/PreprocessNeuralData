% dat_filename = '20130320/officialDataset/Lincoln20130320handControl_psSorted_processed';
% sortproperties_filename = '20130320/officialDataset/sortParameters_ps';
dat_filename = '20130316/officialDataset/Lincoln20130316handControl_psSorted_processed';
sortproperties_filename = '20130316/officialDataset/sortParameters_ps';
load(dat_filename);
load(sortproperties_filename);
% Extract trials from movement onset to target reached. Each target goes
% into a separate file 

% Output file format: target_position (1 x 3) - [x,y,z] position of target
%                     % notes - string
%                     dat (1 x numTrials) structure, where each element has
%                                   the fields - 
%                                   trialId
%                                   spikes (num_neurons x T): 1/0 matrix of spikes
%                        
notes = 'From {movement onset - 300ms} to {movement end}. Only units with sortquality >= 3, and average firing rate >= 1 per second';
numTargets = 8;
fileContents = cell(1,numTargets);
for i = 1:numTargets
    fileContents{i}.dat = struct;
end
end_targets = zeros(numTargets,3);
%% Find 8 targets
target_i = 1;
for num_trial = 1:length(Data)
    if target_i > numTargets
        break;
    end
    trial = Data(num_trial);
    target_xyz = trial.Parameters.MarkerTargets(3).window(1:3);
    if ~ismember(target_xyz,end_targets,'rows')
        end_targets(target_i,:) = target_xyz;
        target_i = target_i+1;
    end
end


%% Use only neurons with sortquality >= 4 (see readme)
selected_neurons = [];
index = 1;
for i = 1:length(sortProperties)
    channel_sorts = sortProperties(i).sortProperties; 
    for j = 1:length(channel_sorts)
        sortQuality = channel_sorts(j).sortQuality;
        if sortQuality >= 4
            selected_neurons = [selected_neurons index];
        end
      index = index + 1;
    end
end


%% For channels that are shorted together, pick channel with highest average firing rate
% NOTE: Not doing this as Patrick has already picked channels
% ignored_channels = pick_channels(Data,{[20 24 73 77],[22 26], [27 29]}); % for 20130316
% %ignored_channels = pick_channels(Data,{[8 10], [14 18] [22 26], [59 63], [81 89]}); % for 20130320
% 
% TrialData = Data(1,1).TrialData;
% selected_neurons_2 = [];
% for i = 1:length(selected_neurons)
%     num_neuron = selected_neurons(i);
%     channel = TrialData.spikes(num_neuron).channel;
%     if ~ismember(channel,ignored_channels)
%         selected_neurons_2 = [selected_neurons_2 num_neuron];
%     end
% ends
% selected_neurons = selected_neurons_2;
%% Get 0/1 spike data
yAll = [];
for num_trial = 1:length(Data)
    fprintf('trial %d of %d\n',num_trial,length(Data));
    trial = Data(num_trial);
    trialId = trial.Overview.trialNumber;
    % find target index
    target_xyz = trial.Parameters.MarkerTargets(3).window(1:3);
    [~,target_index] = ismember(target_xyz,end_targets,'rows');
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
    spikes = zeros(length(selected_neurons),T);
    for i = 1:length(selected_neurons);
        if(i == 65)
            keyboard
        end
        % build 1/0 spikes matrix       
        num_neuron = selected_neurons(i);
   
        timestamps = TrialData.spikes(num_neuron).timestamps;
        timestamps_selected = timestamps((timestamps >= timeMoveOnset) & (timestamps <= timeMoveEnd));
        timestamps_selected = timestamps_selected - timeMoveOnset+1; % align to timeMoveOnset
        spikes(i,timestamps_selected) = 1;
    end
    
    fileContents{target_index}.dat(end+1).spikes = spikes;
    fileContents{target_index}.dat(end).trialId = trialId;
    yAll = [yAll spikes];
end


%% Throw out neurons that don't fire at atleast once per second on average
binwidth = 1000;
spikecounts_interval = [];
num_intervals = floor(size(yAll,2)/binwidth);
num_neurons = size(yAll,1);
spikecounts_interval = zeros(num_neurons,num_intervals);
if matlabpool('size') == 0
    matlabpool open
end
parfor t = 1:num_intervals
    %fprintf('%d of %03d\n',t,size(yAll,2)/binwidth);
    interval = (t-1)*binwidth+1:t*binwidth;
    spikecounts_interval(:,t) = sum(yAll(:,interval),2);
end
inactive_neurons = find(mean(spikecounts_interval,2) < 1);

%% Write out to files
for i = 1:numTargets
    target_position = end_targets(i,:);
    filename_tosave = strcat(dat_filename,'_target_',num2str(i));
    dat = fileContents{i}.dat(2:end);
    for j = 1:length(dat)
        selected_spikes = dat(j).spikes;
        selected_spikes(inactive_neurons,:) = [];
        dat(j).spikes = selected_spikes;
    end
    save(filename_tosave,'dat','notes','target_position');
end