function [phase,peak_locs] = phase_from_peaks(signal)

if length(size(signal))>2 || sum(size(signal)==1)~=1
    error('signal is not a 1D vector')
end

phase = zeros(size(signal));
[~,peak_locs] = findpeaks(signal); %this doesnt include first or last point, which is good

if length(peak_locs)<2
    disp('dont have enough samples to get phase info');
    return
end

%for each cycle (distance between two peaks)
%assign each element its relative position between two peaks going from
%0-2pi
first_cycle = peak_locs(2) - peak_locs(1);
tmp = 1:peak_locs(2);
tmp = tmp - peak_locs(1)+1;
phase(1:peak_locs(2)) = mod(2*pi*tmp/first_cycle,2*pi);

last_cycle = peak_locs(end)-peak_locs(end-1);
tmp = peak_locs(end-1):length(phase);
tmp = tmp - peak_locs(end-1)+1;
phase(peak_locs(end-1):end) = mod(2*pi*tmp/last_cycle,2*pi);

if length(peak_locs)>3
    int_peaks = peak_locs(2:(end-1));
    
    for i =1:(length(int_peaks)-1)
        int_cycle = int_peaks(i+1)-int_peaks(i);
        tmp = 1:int_cycle;
        phase((int_peaks(i)+1):int_peaks(i+1)) = mod(2*pi*tmp/int_cycle,2*pi);
    end
end

end