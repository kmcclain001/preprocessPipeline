function out = findNearest(timestamps, event_times)
%returns binary vector of length(timestmaps) that indicates when events
%occurred 
% EX aligning spike times to some different timestamp vector

t = reshape(timestamps,[length(timestamps),1]);
e = reshape(event_times,[1,length(event_times)]);

t_mat = repmat(t,[1,length(e)]);
[~,minIdx] = min(abs(t_mat-e));

out = zeros(size(timestamps));
out(minIdx) = 1;

if sum(out) ~= length(event_times)
    error('Events were not matched to timeline properly')
end
end