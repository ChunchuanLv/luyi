function r = recurrency(inum, w, w_active, ne)
we = w(1:ne,1:ne);
num_pattern = size(inum,1);
we_active = w_active(1:ne,num_pattern+1:ne);
r = sum(sum(we>mean(nonzeros(we(1:end,num_pattern+1:end)))))/sum(we_active(:));
end
