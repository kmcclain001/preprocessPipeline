function [r,p] = nancorr(x,y,varargin)

g = varargin;
bad_inds = isnan(x)|isnan(y);
if sum(bad_inds) == length(x)
    r = [];
    p = [];
    return
end
[r,p] = corr(x(~bad_inds),y(~bad_inds),g{:});

end