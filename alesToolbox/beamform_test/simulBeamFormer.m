%% script

time = dftmtx(100);

F = fwd(:,1:100:end);

source = F(:,50);


dat = source*real(time(50,:));
figure(10);
plot(dat)


