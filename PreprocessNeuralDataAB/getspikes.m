function dat = getspikes(data,params,selected_sorts)

% Inputs: 
%
% Outputs: 
%   dat

dat(length(data))= struct;
index = 1;
for num_trial = 1:length(data)
    fprintf('Processing trial %d of %d\n',num_trial,length(data));
    trial = data(num_trial);
    trialId = trial.Overview.trialNumber;
    target_xyz = trial.Parameters.MarkerTargets(3).window(1:3);
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
    
    dat(index).trialId = trialId;
    dat(index).spikes = spiketimes;
    dat(index).target = target_xyz;
    index = index+1;        
end

% Remove blank trials
for i = 1:length(dat)
    if isempty(dat(i).spikes)
        dat(i) = [];
    end
end
