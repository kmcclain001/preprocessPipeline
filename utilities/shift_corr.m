% x is a circular variable
% y is a linear variable

function best_r = shift_corr(x,y)

shifterations = 100;
shifts = linspace(0,2*pi,shifterations);

x = reshape(x,[length(x),1]);
x_shift = repmat(x,1,shifterations);

shifts = repmat(shifts,length(x),1);
x_shift = x_shift+shifts;

x_shift = mod(x_shift,2*pi);

y = reshape(y,[length(y),1]);
r_options = corr(x_shift,y);

best_r = min(r_options);

end


    