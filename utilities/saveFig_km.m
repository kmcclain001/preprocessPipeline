function saveFig_km(fig,name)

%figFold = 'C:\Users\kmcla\Dropbox\apAxis\figures\10_23_21';
figFold = 'C:\Users\kmcla\Dropbox\apAxis\figures\6_1_22';
savefig(fig,[figFold filesep name]);
saveas(fig,[figFold filesep name '.svg']);

end

