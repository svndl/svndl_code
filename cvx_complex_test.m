%% Set up variables

%Complex case

nSensors = 10;
nSources = 80;
nMeasurements = 10;

%Mixing matrix
M = randn(nSensors,nSources);
%M=Achunk(1:nSensors,1:nSources);


%Simulated Source Coeff.
realX = sprand(nSources,nMeasurements,.01);
imagX = sprand(nSources,nMeasurements,.01);


%% Simulate data
x_true=complex(full(realX),full(imagX));


D=M*x_true;


%% Do cvx optimization

lambda = 1;

cvx_begin
    variable x(nSources,nMeasurements) complex
    minimize(norm(M*x-D,'fro')+lambda*norm(x,1))
    subject to
      abs(x)<1
cvx_end




%% Setup up data as concatenated basis

%%Non complex Case


x_true_cat = [realX imagX];

D=M*x_true_cat;

%% Do cvx
lambda = 1;
cvx_begin
    variable x(nSources,2*nMeasurements)
    minimize(norm(M*x-D,'fro')+lambda*norm(x,1))
    subject to
      abs(x)<1
cvx_end

