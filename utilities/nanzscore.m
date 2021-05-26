function out = nanzscore(x)
% only works for 1d vectors for now

out = nan(size(x));
out(~isnan(x)) = zscore(x(~isnan(x)));

end
