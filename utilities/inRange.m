function out = inRange(x,r,hard)
% r = range(s)

out = false(size(x));

for i = 1:size(r,1)
    
    if hard
        out = out| x>=r(i,1) & x<=r(i,2);
    else
        out = out| x>r(i,1) & x<r(i,2);
    end
end
end