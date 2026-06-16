clear
clc
close all

% set up coefficients
samplename = 'LME2_100';
filename = strcat('F:\LCP project\Imageprocessing\Rawdata\',samplename,'\SlicesY\');
cfeature = 0.3; % 0.3

% read mass ratio and matflag, calculate volume ratio
massRatio = str2num(samplename(6:8))/100;
if (massRatio == 1) || (massRatio == 0) % matflag=0, composite; matflag = 1, pure LCP or LCP
    matflag = 1;
else
    matflag = 0;
end
volRatio = 1.7*(1-massRatio)/(massRatio*1.2+(1-massRatio)*1.7);     % volume ratio of PC      

% analyze example image
% import example figure
pic = imread([filename 'slice00175.tif']);
[n1,n2] = size(pic);

% pre-peration: apply a filter
% pic = imgaussfilt(pic,2);

% histogram of raw figure
h0 = imhist(pic,2^16);
g0 = 0:1:2^16-1;
g0 = g0.';
% plot(g0,h0,'r.')

% pick section and detect background
[x1,x2,background] = cal_background(pic, cfeature, 1);

h_bk = h0(x1:x2);
g_bk = g0(x1:x2);

h_cmp = h0(background:x2);
g_cmp = g0(background:x2);

figure()
imshow(pic,[])
savefig('original image')

figure()
plot(g0,h0,'k-.','linewidth',1.5);hold on;
plot(g_bk,h_bk,'b-.','linewidth',3);hold on;
plot(g_cmp,h_cmp,'r-.','linewidth',3);hold on;
xlabel('Grey scale')
ylabel('Pixel Number')
grid on
legend('raw data','background','composite')
savefig('segmentation by mass')

% segmentation by mass
if matflag == 1 % pure LCP or PC
    % sgement image directly by background
    pic_sig = imquantize(pic,background);
    pic_ttm = pic_sig;
else            % composites
    % mass-based segmentation for composites
    totalIntensity = sum(h_cmp);
    intensity = 0;
    for i = background:x2
        intensity = intensity + h0(i);
        relativeintensity = intensity/totalIntensity;
        if relativeintensity >= volRatio
            % relativeintensity
            break;
        end
    end
    threshold = g0(i);

    % sgement image
    pic_sig = imquantize(pic,[background threshold]);
    pic_ttm = pic_sig;

    % flip PC and LCP
    sigtem = pic_sig;
    for i = 1:n1
        for j = 1:n2
            if pic_sig(i,j) == 2
                sigtem(i,j) = 3;
                pic_ttm(i,j) = 10;
            elseif pic_sig(i,j) == 3
                sigtem(i,j) = 2;
                pic_ttm(i,j) = 10;
            end
        end
    end
    pic_sig = sigtem;
end
figure()
imshow(pic_sig,[])
savefig('segmented image')

figure()
imshow(pic_ttm,[])
edge_ttm = edge(pic_ttm);
savefig('binary image')

figure()
imshow(edge_ttm)
savefig('edge of binary image')

% rgb figure
pic_sig_rgb = label2rgb(pic_sig);

% detect the outmost edge
tem = imfill(pic_sig);
outmost_edge = edge(tem);

% detect voids and calculate relavant fractions
[pic_sig_new,Atotal, Avoid, ALCP, APC] = cal_detect_voids(pic_sig, outmost_edge);

pic_sig_new_rgb = label2rgb(pic_sig_new);

r_void = Avoid/Atotal;
r_LCP = ALCP/Atotal;
r_PC = APC/Atotal;

index = find(outmost_edge==1);
pic_sig(index) = 5;

figure()
pic_sig_new(index) = 5;
imshow(pic_sig_new,[]);
savefig('image after void detection')

fprintf('LCP=%f,PC=%f,void=%f\n',r_LCP,r_PC,r_void)

samplename = [samplename 'comp'];
% save(samplename)
