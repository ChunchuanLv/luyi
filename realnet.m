function [w_active pconn]= realnet(n, ne, p0, k, pos)
p = zeros(n,n);
for i=1:n
    for j=i+1:n
        p(i,j)=p0*exp(-norm(pos(i,:)-pos(j,:))^2*k);
    end
end
p = p+p';
w_active = p>rand(n,n);
pconn = sum(w_active(:))/(n*(n-1));
w_active(ne+1:end, ne+1:end)=0;
end