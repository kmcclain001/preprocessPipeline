% function to determine whether values of matrix lie in ranges

function [out,good_inds] = filter_mat(data,fannos)

range1 = [3 150];
range2 = [0 1];
range3 = [0 1];
range4 = [0 3];
range5 = [-4*pi 0];
range6 = [0 2*pi];
range7 = [-.1 .2];
b1 = data(:,1)>=range1(1) & data(:,1)<=range1(2);
b2 = data(:,2)>=range2(1) & data(:,2)<=range2(2);
b3 = data(:,3)>=range3(1) & data(:,3)<=range3(2);
b4 = data(:,4)>=range4(1) & data(:,4)<=range4(2);
b5 = data(:,5)>=range5(1) & data(:,5)<=range5(2);
b6 = data(:,6)>=range6(1) & data(:,6)<=range6(2);
b7 = fannos>=range7(1) & fannos<=range7(2);

good_inds = b1&b2&b3&b4&b5&b6;
out = data(good_inds,:);

end