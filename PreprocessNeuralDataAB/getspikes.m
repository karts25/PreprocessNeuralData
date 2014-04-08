function spikes = getspikes(data,params,selected_sorts)

% Inputs: 
%
% Outputs: 
%   spikes : cell array of length #oftargets

if params.splitTargets
    num_targets = params.num_targets;
else
    num_targets = 1;
end
spikes = cell(1,num_targets);      
for i = 1:num_targets
    spikes{i}.dat = struct;
end

for num_trial = 1:length(data)
    fprintf('Processing trial %d of %d\n',num_trial,length(data));
    trial = data(num_trial);
    trialId = trial.Overview.trialNumber;
    if params.splitTargets
        % find target index
        target_xyz = trial.Parameters.MarkerTargets(3).window(1:3);
        [~,target_index] = ismember(target_xyz,params.targets,'rows');
    else
        target_index = 1;
    end
    TrialData = trial.TrialData;

    
    % Skip trials without a market movement onset or end
    if ~isfield(TrialData,params.startMarker) || ~isfield(TrialData,params.endMarker)
        continue
    end
    
    if isempty(TrialData.spikes)
        continue;
    end
    
    timeStart = getfield(TrialData,params.startMarker) + params.startOffset;
    timeEnd = getfield(TrialData,params.endMarker) + params.endOffset;
    
    T = round(timeEnd - timeStart);
    spiketimes = zeros(length(selected_sorts),T);
    
    for i = 1:length(selected_sorts);
        % build 1/0 spikes matrix       
        num_sort = selected_sorts(i);
        timestamps = TrialData.spikes(num_sort).timestamps;
        timestamps_selected = timestamps((timestamps >= timeStart) & (timestamps <= timeEnd));
        timestamps_selected = timestamps_selected - timeStart+1; % align to timeStart
        spiketimes(i,timestamps_selected) = 1;
    end
        
    spikes{target_index}.dat(end+1).spikes = spiketimes;
    spikes{target_index}.dat(end).trialId = trialId;
end

for i = 1:num_targets
    spikes{i}.dat(1) = [];
end