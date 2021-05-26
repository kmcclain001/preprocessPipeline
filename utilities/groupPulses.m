function groups = groupPulses(pulseTimes, gapRatio)

d = diff(pulseTimes);
gapLength = gapRatio*median(d);

gaps = [1,find(d>gapLength),length(pulseTimes)];

groups = zeros(size(pulseTimes));
for gIdx = 1:(length(gaps)-1)
    groups(gaps(gIdx):gaps(gIdx+1)) = gIdx;
end

end

