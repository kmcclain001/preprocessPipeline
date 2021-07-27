function saveFig_km(fig,name)

figFold = 'C:\Users\kmcla\Dropbox\apAxis\rippleDetection\figures\presentationFigures';
%savefig(fig,[figFold filesep name]);
saveas(fig,[figFold filesep name '.jpg']);

end

