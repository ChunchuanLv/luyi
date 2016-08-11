function plot_w(w)
n = size(w,1);
imagesc(w);            %# Create a colored plot of the wrix values
colormap(flipud(gray));  %# Change the colormap to gray (so higher values are
                         %#   black and lower values are white)

textStrings = num2str(w(:),'%0.2f');  %# Create strings from the wrix values
textStrings = strtrim(cellstr(textStrings));  %# Remove any space padding
[x,y] = meshgrid(1:n);   %# Create x and y coordinates for the strings
hStrings = text(x(:),y(:),textStrings(:),...      %# Plot the strings
                'HorizontalAlignment','center');
midValue = mean(get(gca,'CLim'));  %# Get the middle value of the color range
textColors = repmat(w(:) > midValue,1,3);  %# Choose white or black for the
                                             %#   text color of the strings so
                                             %#   they can be easily seen over
                                             %#   the background color
set(hStrings,{'Color'},num2cell(textColors,2),'Fontsize', 20);  %# Change the text colors

set(gca,'XTick',1:n,...                         %# Change the axes tick marks
        'YTick',1:n,...
        'TickLength',[0 0], 'Fontsize',20);
title('weight plot', 'Fontsize',25);
end