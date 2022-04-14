function y = removeHoles(x,minGap,minBlip)

% x = binary vector
% minInd = smallest hole permitted

y = x;

offInts = findIntervals(~y);

fillIn = offInts(diff(offInts,[],2)<(minGap),:);
for i = 1:size(fillIn,1)
    y(fillIn(i,1):fillIn(i,2)) = true;
end

onInts = findIntervals(y);
remove = onInts(diff(onInts,[],2)<minBlip,:);
for i = 1:size(remove,1)
    y(remove(i,1):remove(i,2))=false;
end

end

