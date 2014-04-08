function trim_trials(T,filename)
% Trims trials such that they all have the length T. By default T is the
% shortest trial length
close all
if nargin < 2
    filename = './20130316/officialDataset/Lincoln20130316handControl_psSorted_processed_target_1';
end
load(filename);
if nargin < 1
    Tmin = inf;
    for i = 1:length(dat)
        if size(dat(i).spikes,2) < Tmin
            Tmin = size(dat(i).spikes,2);
        end
    end
    T = Tmin;
end

% Plot all trial lengths
Tall = zeros(1,length(dat));
for i = 1:length(dat)
    Tall(i) = size(dat(i).spikes,2);
end
figure; hold on;
bar(1:length(dat),Tall)
plot([1 length(dat)],[T T],'r');


% Trim Trials
idx = 1;
for i = 1:length(dat)
    if size(dat(i).spikes,2) >= T
        dat_trimmed(idx).spikes = dat(i).spikes(:,1:T);
        dat_trimmed(idx).trialId = dat(i).trialId;
        idx = idx + 1;
    end
end
dat = dat_trimmed;
save(strcat(filename,'_trimmed'),'dat','notes','target_position');