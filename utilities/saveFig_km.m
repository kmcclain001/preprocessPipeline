function saveFig_km(fig,name)

figFold = 'G:\Ethel_210212\figures\4-5-21';

savefig(fig,[figFold filesep name]);
saveas(fig,[figFold filesep name '.jpg']);

end