function s = matSymMeasure(X)

if size(X,1)~=size(X,2)
    error('SQUARE MATRIX IDIOT')
end

X(isnan(X)) = 0;

a = norm(X+X')-norm(X-X');
b = norm(X+X')+norm(X-X');

s = a/b;

end
