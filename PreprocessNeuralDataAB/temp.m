timestamps = sort(randi(100,1,20),'ascend');
tstart = 25;
tend = 75;

timestamps_selected = timestamps((timestamps>=tstart)&(timestamps<=tend));
timestamps_selected = timestamps_selected - tstart;
spikes = zeros(1,round(tend-tstart));
spikes(timestamps_selected) = 1;
