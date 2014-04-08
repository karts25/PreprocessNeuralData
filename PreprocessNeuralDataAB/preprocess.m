% preprocess.m
% 
% Get 0/1 spike counts from Batista lab data
%
% INPUTS:
%
% params - structure with the following fields
%
% params.dat_folder      
% params.input_file      
% params.output_file    
% params.output_format   : 'gpfa'
% params.splitTargets    
% 
% params.checkSortquality    
% params.lowestSortquality    
% params.pruneShortedChannels 
% params.minFiringRate        
% 
% params.startMarker = 'timeGoCue';
% params.startOffset = 0;
% params.endMarker = 'timeTargetAcquired';
% params.endOffset = 0;


function spikes = preprocess(params)

fname = sprintf('%s/%s',params.dat_folder,params.input_file);
load(fname);

if exist('Data','var') % Patrick's data
    data = Data;
elseif exist('processedData','var') % Kristin's Processed data
    data = processedData;
end

selected_sorts = selectsorts(data,params);
spikes = getspikes(data,params,selected_sorts);
spikes = prunebyfiringrate(spikes,params);    