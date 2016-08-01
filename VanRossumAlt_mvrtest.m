function d = VanRossumAlt_mvrtest(x,y,tc,kerneltype)
% Naive method for calculating Van Rossum Distance
% Made by Radoslav Viliyanov Gabrovski
% Format: d = VanRossumAlt(x,y,time constant)

% MvR, Jan 2015. Slightly faster than Radoslav's code,
% but still slower than Kreuz.

% input: x,y: lists of spike times, tc: time-constant (tau)
% kerneltype =0,1,2

x=nonzeros(x);
y=nonzeros(y);
x_num = length(x);
y_num = length(y);

x=x/tc;
y=y/tc;
% use indices i,j for x and k,l for y


if (kerneltype==0) % single-sided exponential.
	d = 0;
	for i = 1:x_num
		for j = i+1:x_num
			d = d + 2*exp(-abs(x(i) - x(j)));
		end 
	end

	for k = 1:y_num
		for l = k+1:y_num
			d = d + 2*exp(-abs(y(k) - y(l)));
		end 
	end

	for i = 1:x_num
		for k = 1:y_num
			d = d -2 * exp(-abs(x(i) - y(k)));
		end 
	end
	d=d+x_num+y_num; % the i=j  contributions.
	% d = sqrt(2/tc*abs(d));
	d = sqrt(abs(d)/2); 
	return;

elseif (kerneltype==13) % debugging
	d = 0;
	for i = 1:x_num
		d = d +sum(exp(-abs(x-x(i))));
	end

	for k = 1:y_num
		d = d+ sum(exp(-abs(y-y(k))));
	end

	for i = 1:x_num
		d = d -2*sum(exp(-abs(x(i) - y)));
	end
	d = sqrt(abs(d)/2);
	return;
	
elseif (kerneltype==1) % double-sided exponential.
	d = 0;
	for i = 1:x_num
		for j = i+1:x_num
			d = d + 2*exp(-abs(x(i) - x(j)))*(1+abs(x(i) - x(j)));
		end 
	end

	for k = 1:y_num
		for l = k+1:y_num
			d = d + 2*exp(-abs(y(k) - y(l)))*(1+abs(y(k) - y(l)));
		end 
	end

	for i = 1:x_num
		for k = 1:y_num
			d = d -2 * exp(-abs(x(i) - y(k)))*(1+abs(x(i) - y(k)));
		end 
	end
	d=d+x_num+y_num; % the i=j  contributions.
	d = sqrt(abs(d)/2); 
	return;
elseif (kerneltype==2) % Gaussian kernel
	d = 0;
	for i = 1:x_num
		for j = i+1:x_num
			d = d + 2*exp(-(x(i) - x(j))^2/2);
		end 
	end

	for k = 1:y_num
		for l = k+1:y_num
			d = d + 2*exp(-(y(k) - y(l))^2/2);
		end 
	end

	for i = 1:x_num
		for k = 1:y_num
			d = d -2 * exp(-(x(i) - y(k))^2/2);
		end 
	end
	d=d+x_num+y_num; % the i=j  contributions.
	d = sqrt(abs(d)/2); % Distance was sqrt(2) times too big
	return;
end
end

