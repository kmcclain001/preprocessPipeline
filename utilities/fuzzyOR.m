function d = fuzzyOR(x)

nCol = size(x,2);

d = x(:,1);
for i = 1:nCol
    
    d = 1-(1-d).*(1-x(:,i));
end

end