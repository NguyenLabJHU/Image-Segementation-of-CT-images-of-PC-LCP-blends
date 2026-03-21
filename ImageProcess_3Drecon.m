% reconstruct 3d image of PC/LCP blends
clear
clc
close all

% 3D reconstruction
% you determine sample name, starting slice and total number of slices in reconstruction
samplename = 'LME0_025';
initialSlice = 100;
sliceNumber = 200;
cfeature = 0.1;

% read mass ratio and matflag, calculate volume ratio
massRatio = str2num(samplename(6:8))/100;
if (massRatio == 1) || (massRatio == 0) % matflag=0, composite; matflag = 1, pure LCP or LCP
    matflag = 1;
else
    matflag = 0;
end
volRatio = 1.40*(1-massRatio)/(massRatio*1.19+(1-massRatio)*1.40);     % volume ratio of PC    

filename = strcat('F:\LCP project\Imageprocessing\Rawdata\', samplename,'\SlicesY\');
[PC, LCP, Blend, Void, vol, vlcp, vpc, vvoid] = volumeRender(filename, initialSlice, sliceNumber, volRatio, matflag, cfeature, 0);

% vPC = volshow(PC);
% vLCP = volshow(LCP);
vBlend = volshow(Blend);
% vVoid = volshow(Void);
% volratio = vpc/vlcp

rv_LCP = vlcp/vol;
rv_PC = vpc/vol;
rv_void = vvoid/vol;

samplename = strcat(samplename,"_volume_updated0910");
save(samplename)