function plotnet(w_active, xy)
    n = size(w_active,1);
    gplotdc(w_active,xy);
    ne = n-1;
    for k = 1:n
        if k > ne
            label = 'Inh';
        else
            label = 'Exc';
        end
        text(xy(k,1),xy(k,2),['  ' num2str(k) label],'Color','k', ...
            'FontSize',12,'FontWeight','b')
    end
end