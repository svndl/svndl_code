%% Setup constants
ySize = 500; %number of x pixels
xSize = 500; %number of y pixels

a=4; %radial Cycles per image
b=4; %Number of windings per image, 0 = radial grating, 
phase=pi/4;

%transfer function parameters, linear: c50=1000,
%Rmax=1001,n=1,rectify=false
c50 =.3;
Rmax=1;
n=17;
rectify = true;

%% Make image
xCoords = linspace(-1,1,xSize);
yCoords = linspace(-1,1,ySize);
[xGrid yGrid] = meshgrid(xCoords, yCoords);

%for nonlineaity
tf = -1:.01:1;

%Make log-polar transformation
theta = atan2(yGrid,xGrid);
rho =log(sqrt(xGrid.^2+yGrid.^2));

%Take log polar coordinates and make a grating
spiralImage = sin(a*theta+(b*rho+1)+phase);

%Run image through a sigmoidal non-linearity
if rectify==false,
    spiralImage= Rmax*sign(spiralImage.^(n+1)).*(spiralImage.^n./(abs(spiralImage.^n)+c50^n));
    %nonlinear transfer function
    transFunc = Rmax*sign(tf.^(n+1)).*(tf.^n./(abs(tf.^n)+c50^n));
else
    spiralImage= abs(Rmax*(spiralImage.^n./(abs(spiralImage.^n)+c50^n)));
    transFunc = Rmax*abs((tf.^n./(abs(tf.^n)+c50.^n)));

end

stimImage=(spiralImage);


%% Plot stuff
figure(1)
imagesc( stimImage)
colormap('gray')
figure(2)
imagesc(fliplr(stimImage));
colormap('gray')
figure(3),

plot(tf,transFunc,'linewidth',3)
