function out = getCellStructValue(S,fieldName)

tmp = cellfun(@(x) x.(fieldName),S,'UniformOutput',false);
out = vertcat(tmp{:});

end