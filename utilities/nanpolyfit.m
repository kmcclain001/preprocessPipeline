function out = nanpolyfit(x,y,n)

bad_inds = isnan(x)|isnan(y);

out = polyfit(x(~bad_inds),y(~bad_inds),n);

end