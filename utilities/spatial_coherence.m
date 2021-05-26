% Function for computing spatial coherence of pixels
% Correlated vectors are:
%   1) Firing rate of each pixel
%   2) Mean firing rate neighbors of each pixel
% Gives a measure of spatial smoothness
%
% Inputs:
%   G = graph of environment (found in .linear.behavior.mat files)
%   node_inds = indices of nodes to include
%   FR = vector of firing rates, index corresponds to node index in G
%
% Outputs:
%   sp_cor = spatial coherence
%
% Based on Mizuseki & Buzsaki 2013 Cell Reports
% Author Kathryn McClain
%

function sp_cor = spatial_coherence(G,node_inds,FR,varargin)

    p = inputParser;
    addParameter(p,'radius',1,@isfloat);
    parse(p,varargin{:});
    r = p.Results.radius;
    
    this_node_fr = zeros(1,length(node_inds));
    neighbor_node_fr = zeros(1,length(node_inds));
    
    for i = 1:length(node_inds)
        this_node_fr(i) = FR(node_inds(i));
        neighbor_nodes = neighbors_of_neighbors(G,node_inds(i),r);
        neighbor_node_fr(i) = mean(FR(neighbor_nodes(:,1)));
    end
    
    C = corrcoef(this_node_fr,neighbor_node_fr);
    if length(C)==1
        sp_cor = C;
    else
        sp_cor = C(1,2);
    end
end