function out = compare_dist(a,b, p_tol)

d = median(a)-median(b);
[~,p] = ttest2(a,b);

if p>=p_tol
    out = 0;
elseif d>0
    out = 1;
elseif d<0
    out = -1;
end

end