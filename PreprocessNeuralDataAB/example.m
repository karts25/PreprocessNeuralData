clc;
clear variables;

params.dat_folder      = '/Users/karthikl/Desktop/Research_Material/Neuraldata';
params.input_file      = 'Ike/Cleaner Data/Ike20131215outcenter_UDP_processed';
params.output_file     = 'Ike/Cleaner Data/Ike20131215outcenter_gpfa';
params.output_format   = 'gpfa';
params.splitTargets    = true;

params.checkSortquality     = false;
params.lowestSortquality    = NaN;
params.sortPropertiesfile   = '';
params.pruneShortedChannels = false;
params.minFiringRate        = 2; % per second

params.startMarker = 'timeGoCue';
params.startOffset = 0;
params.endMarker = 'timeTargetAcquired';
params.endOffset = 0;

%preprocess(params);

params.input_file = params.output_file;
plot_tuning_curve(params);