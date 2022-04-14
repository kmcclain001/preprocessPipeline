function saveFig_km(fig,name)

%figFold = 'C:\Users\kmcla\Dropbox\apAxis\figures\10_23_21';
figFold = 'C:\Users\kmccl\Dropbox\apAxis\figures\10_23_21';
savefig(fig,[figFold filesep name]);
saveas(fig,[figFold filesep name '.jpg']);

end

