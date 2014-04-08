function selected_sorts = selectsorts(data,params)

selected_sorts = [];
index = 1;
if params.checkSortquality % For Patrick's Lincoln Data
    
    for i = 1:length(sortProperties)
        channel_sorts = sortProperties(i).sortProperties;
        for j = 1:length(channel_sorts)
            sortQuality = channel_sorts(j).sortQuality;
            if sortQuality >= params.lowestSortquality
                selected_sorts = [selected_sorts index];
            end
            index = index + 1;
        end
    end
else    
    % Use the first trial to select for Kristin's Ike Data
    trial = data(1).TrialData;
    for i = 1:length(trial.spikes)
        if ~isempty(trial.spikes(i).timestamps)                    
            selected_sorts = [selected_sorts index];
        end
        index = index + 1;
    end
end
