function tstNorm()


t0 = 0;
g0 = 1;
tf = 50;
tSteps = tf*100;
C = 1;

gt = linspace(t0,tf,tSteps); 
at = linspace(t0,tf,tSteps); 
a = 1*sin(2*at); % Generate a(t)
g = .5*(0*a+2*sin(3*gt+pi/2)); % Generate g(t)

%a = circshift(a,[0  -100]);
%g = circshift(g,[0 -100]);
%a=(.8*(.5*a+.3*sin(3*gt))); % Generate g(t)


a(1:1000) = 0;%.1*sin(100*at(1:1000)+pi*randn);
g(1:1000) = 0;%.1*sin(100*at(1:1000)+pi*randn);
% a(1:1000) = .1*sin(100*at(1:1000)+pi*randn);
% g(1:1000) = .1*sin(100*at(1:1000)+pi*randn);
% a = a+.1*randn(size(a));
% g = g+.1*randn(size(g));

g = g0*(1+g);

% a(1001:end) = 1;
% g(1001:end) = .5;


Tspan = [t0 tf]; % Solve from t=1 to t=5
IC = -1; % y(t=0) = 1
[T Y] = ode45(@(t,y) myode(t,y,gt,g,at,a),Tspan,IC); % Solve ODE

Y = interp1(T,Y,gt);


clf
subplot(2,1,1)
%plot(at,a./norm(a))
plot(at,a)
hold on;
%plot(gt,g./(norm(a)),'r')
plot(gt,g,'r')

%plot(gt, (Y-mean(Y))./norm(Y-mean(Y)),'k');
plot(gt, Y,'k');

title('Plot of y as a function of time');
xlabel('Time'); ylabel('Y(t)');


subplot(2,1,2)

ftg =abs(fft(g));
fta =abs(fft(a));
fty =abs(fft((Y)));

plot(ftg(1:100)./norm(ftg(1:100)),'r');
hold on;
plot(fta(1:100)./norm(fta(1:100)));

plot(2:100,fty(2:100)./norm(fty(2:100)),'k','linewidth',2);




function dydt = myode(t,y,gt,g,at,a)
g = interp1(gt,g,t); % Interpolate the data set (ft,f) at time t
a = interp1(at,a,t); % Interpolate the data set (gt,g) at time t
dydt = (a - g.*y)/C ; % Evalute ODE at time t
end

end
