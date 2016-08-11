function [w_active pconn]= realnet(n, ne, p0, d0)
p = zeros(ne,ne);
w_active = zeros(n,n);
pos = rand(ne,ne);
for i=1:ne
    for j=i+1:ne
        p(i,j)=p0*exp(-norm(pos(i,:)-pos(j,:))^2/(2*d0^2));
    end
end
p = p+p';
we_active = p>rand(ne,ne);
pconn = sum(w_active(:))/(n*(n-1));
w_active(1:ne,1:ne)=we_active;
w_active(ne+1:end, 1:ne) = pconn>rand(n-ne,ne);
w_active(ne+1:end, ne+1:end)=0;
end