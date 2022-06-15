% Reset kilosort output

f = checkFile('filename','rez.mat');

load([f.folder,filesep,f.name]);

disp('Converting to Phy format')
rezToPhy_KSW(rez);

fk = dir(['Kilosort*',filesep]);

PhyAutoClustering_km([fk.folder filesep fk.name]);