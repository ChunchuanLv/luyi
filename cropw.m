function we = cropw(we, remove)
sorted_we = sort(we(:));
sorted_we(sorted_we==0)=[];
num_we = length(sorted_we);
remove_num = round(num_we*remove);
if remove_num > 0
    threshold = sorted_we(remove_num);
else
    threshold = 0;
end
we=we.*(we>threshold);
end