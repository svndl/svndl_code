function [residError allElpFid] =  compareManyPolhemusFiducials(subjId,elpDir)



freesurfDir = getpref('freesurfer','SUBJECTS_DIR');
subjDir = fullfile(freesurfDir,subjId);

fiducialFile = fullfile(subjDir,'bem',[subjId '_fiducials.txt']);
mriFiducials = load(fiducialFile);


fileList = dir(fullfile(elpDir,'*.elp'));

dotSize =60;
figure(1);
clf
scatter3( mriFiducials(:,1)/1000, mriFiducials(:,2)/1000,mriFiducials(:,3)/1000, dotSize, 'g', 'filled' ),
hold on;
scatter3( mriFiducials(3,1)/1000,mriFiducials(3,2)/1000,mriFiducials(3,3)/1000,20*dotSize,'kx');
scatter3( mriFiducials(1,1)/1000,mriFiducials(1,2)/1000,mriFiducials(1,3)/1000,20*dotSize,'k+');
scatter3( mriFiducials(2,1)/1000,mriFiducials(2,2)/1000,mriFiducials(2,3)/1000,20*dotSize,'k*');
     length(fileList)
mirrorCnt = 0;
     
for iFile = 1:length(fileList)
    
    elpFile = fullfile(elpDir,fileList(iFile).name);
    
    [elpFid scf] = getElpFid(elpFile);
    
    [t r] = alignFiducials(elpFid,mriFiducials);
    
    trans = [ r, t'; 0 0 0 1];
    allElpFid(iFile,:,:) = elpFid;
    
    if det(r) <0;
        mirrorCnt = mirrorCnt +1;
        
        elpFile
       % continue;
    end
    
    
    elpFid = [elpFid, [1; 1; 1;]];
    transFid = trans*elpFid';
    transFid = [transFid(1:3,:)/1000]';

    scatter3( transFid(:,1), transFid(:,2),transFid(:,3), dotSize, 'r', 'filled' ),

       % scatter3( transFid(1,1), transFid(1,2),transFid(1,3), 1200, 'kd', 'filled' ),
    %scatter3( transFid(2,1), transFid(2,2),transFid(2,3), 1200, 'kd', 'filled' ),
    %    scatter3( transFid(3,1), transFid(3,2),transFid(3,3), 1200, 'kd', 'filled' ),

    %    legend('MRI defined fiducials','Electrode Fiducials','NOSE','Electrodes')

    elecCoord = [1000*scf.x', 1000*scf.y', 1000*scf.z', ones(length(scf.x),1)];

    transElec = trans*elecCoord';
    transElec = [transElec(1:3,:)/1000]';

    
 scatter3( transElec(:,1), transElec(:,2),transElec(:,3), 60, 'k', 'filled' ),
         
    
    fidDiff = (1000*transFid-mriFiducials);

    fidError(iFile,:) = (sqrt(sum(fidDiff.^2,2)));

    totalError(iFile) = sum(fidError(iFile,:));

%    msg = sprintf('LEFT Ear Error: %f mm Right Ear Error: %f mm Nasion Error : %f mm\n Total Error %f mm',...
%        fidError(iFile,1),fidError(2),fidError(3),totalError(iFile));
%    disp(msg)
end

mirrorCnt

residError = fidError;

figure(2)
subplot(3,1,1)
hist(totalError)

subplot(3,1,2)
hist(fidError)

function [elpFid scf]= getElpFid(elpFile)

% read the elp file
eloc = readelp(elpFile); %

elp.lpa = [eloc(2).X eloc(2).Y eloc(2).Z]; 
elp.rpa = [eloc(3).X eloc(3).Y eloc(3).Z]; 
elp.nasion = [eloc(1).X eloc(1).Y eloc(1).Z]; 

Lx = eloc(2).X;
Ly = eloc(2).Y;

Nx = eloc(1).X; % distance from the ctf origin to nasion

cs = - Lx / sqrt( Lx*Lx + Ly*Ly );
sn =   Ly / sqrt( Lx*Lx + Ly*Ly );


% convert fiducials
lpa.x = elp.lpa( 1 ) * cs - elp.lpa( 2 ) * sn - Nx * cs;
lpa.y = elp.lpa( 1 ) * sn + elp.lpa( 2 ) * cs;
lpa.z = elp.lpa( 3 );

rpa.x = elp.rpa( 1 ) * cs - elp.rpa( 2 ) * sn - Nx * cs;
rpa.y = elp.rpa( 1 ) * sn + elp.rpa( 2 ) * cs;
rpa.z = elp.rpa( 3 );

nas.x = elp.nasion( 1 ) * cs - elp.nasion( 2 ) * sn - Nx * cs;
nas.y = elp.nasion( 1 ) * sn + elp.nasion( 2 ) * cs;
nas.z = elp.nasion( 3 );


elpFid = 1000*[ lpa.x, lpa.y, lpa.z; ...
                rpa.x, rpa.y, rpa.z; ...
                nas.x, nas.y, nas.z];

            
            
            
            
            
for i=5:length(eloc);
   
elp.x(i-4) = eloc(i).X;
elp.y(i-4) = eloc(i).Y;
elp.z(i-4) = eloc(i).Z;

end
elp.sensorN = length(elp.x)+1;

%elp = elec_emse2matlab( elpfile ); % read the elp file

Lx = elp.lpa( 1 );
Ly = elp.lpa( 2 );
Nx = elp.nasion( 1 );     % distance from the ctf origin to nasion
cs = - Lx / sqrt( Lx*Lx + Ly*Ly );
sn =   Ly / sqrt( Lx*Lx + Ly*Ly );

% convert elp c.f. (CTF) to subject centered c.f. (NEUROMAG), i.e. LPA on -x, RPA on x, NAS
% on y, origin on LPA - RPA line, but only approx between LPA and RPA.
scf.x = elp.x * cs - elp.y * sn - Nx * cs;
scf.y = elp.x * sn + elp.y * cs;
scf.z = elp.z;
            
            
            
            
            
            
            