function [dat] = bz_scrubTracking(dat)
% USAGE  
%  [dat] = bz_scrubTracking(dat)
% 
% INPUTS
%   dat - struct created by calling dat = importdata(file.csv) on a csv
%         file exported from a .tak file
%
% OUTPUTS
%   dat - the same struct 1) outliers removed
%                         2) median filtering
%                         3) interpolation over missing frames
%
%
% 
% this functions takes the unedited *.csv exported from Motive, smoothes and
% resorts columns to match the position tracking formatting standards
% 
% David Tingley, 2017
% kathryn mcclain 2020 changed to pchip
%TODO
% check that units are in meters...


% find extreme outliers outside of tracking volume
badFrames = cell(3,1);
for i = 7:9
    badFrames{i-6} = find(abs(dat.data(:,i)-nanmedian(dat.data(:,i)))>3*mad(dat.data(:,i)));
end
badFrames = unique(vertcat(badFrames{:}));
dat.data(badFrames,7:9) = nan;

% dat.data((abs(dat.data(:,7))>nanmedian(dat.data(:,7))+mad(dat.data(:,7))*4),7)=nan;
% dat.data((abs(dat.data(:,8))>nanmedian(dat.data(:,8))+mad(dat.data(:,8))*4),8)=nan;
% dat.data((abs(dat.data(:,9))>nanmedian(dat.data(:,9))+mad(dat.data(:,9))*4),9)=nan;

% find poorly tracked frames using the error per marker column
try
dat.data(find(dat.data(:,10)>nanmean(dat.data(:,10))+nanstd(dat.data(:,10))*5),:)=nan;   
catch
end

% I think this is no good find dropped frames or large translational shifts and call them nan's here
% f = find(diff(dat.data(:,8))==0 | abs(diff(dat.data(:,8)))> nanmean(nanstd(abs(diff(dat.data(:,8)))))+ nanstd(abs(diff(dat.data(:,8)))) * 5);
% dat.data(f+1,8)=nan;
% f = find(diff(dat.data(:,9))==0 | abs(diff(dat.data(:,9)))> nanmean(nanstd(abs(diff(dat.data(:,9))))) + nanstd(abs(diff(dat.data(:,9)))) * 5);
% dat.data(f+1,9)=nan;
% f = find(diff(dat.data(:,7))==0 | abs(diff(dat.data(:,7)))> nanmean(nanstd(abs(diff(dat.data(:,7))))) + nanstd(abs(diff(dat.data(:,7)))) * 5);
% dat.data(f+1,7)=nan;

% median filtering
dat.data(:,7) = medfilt1(dat.data(:,7),5);% 24
dat.data(:,8) = medfilt1(dat.data(:,8),5);
dat.data(:,9) = medfilt1(dat.data(:,9),5);

% pattern matching interpolation
dat.data(:,7) = fillmissing(dat.data(:,7),'pchip','EndValues','none');
dat.data(:,8) = fillmissing(dat.data(:,8),'pchip','EndValues','none');
dat.data(:,9) = fillmissing(dat.data(:,9),'pchip','EndValues','none');

%  now change column order to new standards
% columns = [7 9 8 3 5 4 6 10 1 2]; % optitrack is Y-oriented instead of Z
% dat.data = dat.data(:,columns);

end