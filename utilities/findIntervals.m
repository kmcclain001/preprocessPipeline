function out = findIntervals(booString,varargin)
p = inputParser;
addParameter(p,'minLength',0,@isnumeric)

parse(p,varargin{:});
minLength = round(p.Results.minLength);

booString = reshape(booString,[1,length(booString)]);

starts = find(diff([false booString])>0);
ends = find(diff([booString false])<0);

out = [starts', ends'];

d = diff(out,[],2);
out(d<minLength,:) = [];

end