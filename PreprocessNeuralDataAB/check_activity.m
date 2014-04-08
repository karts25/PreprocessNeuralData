dat_filename = '20130316/officialDataset/Lincoln20160316handControl_psSorted_processed';
numtargets = 8;

sizes_mean = zeros(1,numtargets);
sizes_median = zeros(1,numtargets);
sizes_mode = zeros(1,numtargets);
for i = 1:numtargets
    load(strcat(dat_filename,'_target_',num2str(i)));
    sizes = zeros(1,length(dat));
    for j = 1:length(dat)
        sizes(j) = size(dat(j).spikes,2);
    end
    sizes_mean(i) = mean(sizes);
    sizes_median(i) = median(sizes);
    sizes_mode(i) = mode(sizes);
end