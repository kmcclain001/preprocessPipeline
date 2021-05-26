function T = cconv2(M,F,dim,shape)
%M = matrix
%F = filter
%dim = dimension to wrap around (1 meeans top>bottom, 2 means left>right, 3 means both)

if ~exist('shape','var')
    shape = 'same';
end
    
if sum((size(M)-size(F))<0)>0
    error('Filter bigger than matrix')
end

if dim ==1
    Mwrap = [M;M;M];
    P = conv2(Mwrap,F,shape);
    T = P(size(M,1)+(1:size(M,1)),:);
elseif dim == 2
    Mwrap = [M,M,M];
    P = conv2(Mwrap,F,shape);
    T = P(:,size(M,2)+(1:size(M,2)));
elseif dim == 3
    Mwrap = repmat(M,3);
    P = conv2(Mwrap,F,'same');
    T = P(size(M,1)+(1:size(M,1)),size(M,2)+(1:size(M,2)));
else
    error('invalid dimension')
end
end