function m = multilineText(t,cols)
%MULTILINETEXT Splits long text into lines of specified word length
t = split(t);
n_words = numel(t);
n_rows = ceil(n_words/cols);
n_cells = n_rows * cols;
t = [t; strings(n_cells-n_words,1)];
t = reshape(t,cols,n_rows);
t = transpose(t);
m = join(t);
end

