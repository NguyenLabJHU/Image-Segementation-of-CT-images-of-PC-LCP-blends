% -------------------------------------------------------------------------
% Image processing with PA/LCP sample
% This script is used for image processing and 3D reconstruction of PA/LCP
% blended samples.
%
% Parameter description:
%   This is a main script with no input arguments.
%   The workflow is controlled by variables such as filename, cfeature,
%   initialSlice, and sliceNumber.
%
% Main outputs:
%   1. Single-slice segmentation result
%   2. Area/volume fractions of void, LCP, and PA
%   3. 3D reconstruction result and threshold variation curves
% -------------------------------------------------------------------------
clear
clc
close all

% -------------------------------------------------------------------------
% Basic parameter setup
% -------------------------------------------------------------------------
% set up file path
filename = 'G:\PALCP blends characterization\XCT_APALCP_05292026\mixerdie_3ft_notched\';
% give sample name  for saving
samplename = 'mixerdie_3ft';
% Empirical parameters used to constrain the three Gaussian peak locations
cfeature = [0.6,0.2];   % mixerDie_3ft

% -------------------------------------------------------------------------
% Single-image analysis
% -------------------------------------------------------------------------

% Read an example slice
pic = imread([filename 'slice00882.tif']);
[n1,n2] = size(pic);

% Pre-processing: Gaussian filtering to suppress noise
pic = imgaussfilt(pic,1);

% Histogram of the original image
h0 = imhist(pic,2^16);
g0 = 0:1:2^16-1;
g0 = g0.';

% Empirical mixture ratio used as initial constraints for Gaussian fitting
a = 1;b = 0.5;c = 0.1;  % mixerDie 3ft

% Estimate background range and fit the background peaks
[x1,x2, mu, sig, A] = cal_bk(pic, 1,[a,b,c]);

% Extract histogram section for background fitting
h_bk = h0(x1:x2);
g_bk = g0(x1:x2);

% Compute two segmentation thresholds
[th1,th2] = cal_crossection(g_bk,h_bk,mu,cfeature,1);

% -------------------------------------------------------------------------
% Segmentation based on thresholds
% -------------------------------------------------------------------------
threshold = [th1 th2];
pic_sig = imquantize(pic,threshold);

% Temporary segmented image for extra marking
pic_ttm = pic_sig;

% -------------------------------------------------------------------------
% Swap PC and LCP labels
% In the original quantization result, class 2 and class 3 are exchanged
% -------------------------------------------------------------------------
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

% Display the original image and the segmented result
figure()
subplot(1,2,1)
imshow(pic,[])
subplot(1,2,2)
imshow(pic_sig,[])

% % Uncomment to visualize the marked auxiliary image
% figure()
% imshow(pic_ttm,[])
edge_ttm = edge(pic_ttm);

figure()
imshow(edge_ttm)

% Convert the segmented image to a pseudo-color image
pic_sig_rgb = label2rgb(pic_sig);

% -------------------------------------------------------------------------
% Detect the outermost edge
% -------------------------------------------------------------------------
tem = imfill(pic_sig);
outmost_edge = edge(tem);

% -------------------------------------------------------------------------
% Detect voids and compute relevant area fractions
% -------------------------------------------------------------------------
[pic_sig_new,Atotal, Avoid, ALCP, APA] = cal_detect_voids(pic_sig, outmost_edge);

% Convert the updated segmented image to pseudo-color display
pic_sig_new_rgb = label2rgb(pic_sig_new);

% Compute area fractions
r_void = Avoid/Atotal;
r_LCP = ALCP/Atotal;
r_PA = APA/Atotal;

% Mark boundary pixels for visualization
index = find(outmost_edge==1);
pic_sig(index) = 5;

figure()
pic_sig_new(index) = 5;
imshow(pic_sig_new,[]);

fprintf('LCP=%f,PC=%f,void=%f\n',r_LCP,r_PA,r_void)

%% 
% -------------------------------------------------------------------------
% 3D reconstruction
% -------------------------------------------------------------------------
clc
close all

% Set the starting slice and the total number of slices for reconstruction
initialSlice = 600;
sliceNumber = 20;

% Material flag (reserved for future use)
matflag = 0; 

% Estimate thresholds for each slice
[threshold] = volumeThreshold(filename, initialSlice, sliceNumber, cfeature, 0,[a,b,c]);
slice_list = threshold(:,1);
th1 = threshold(:,2);
th2 = threshold(:,3);

% -------------------------------------------------------------------------
% Smooth / interpolate abnormal threshold values
% -------------------------------------------------------------------------
th1_new = th1;
th2_new = th2;

% Alternative filtering methods, currently not used
% kernel = ones(1,51);
% th1_new = conv(th1,kernel,'same');
% th2_new = conv(th2,kernel,'same');
%
% th1_new = myFilter(th1,kernel);
% th2_new = myFilter(th2,kernel);

% Replace outliers using linear interpolation based on moving median
th1_new = filloutliers(th1,"linear","movmedian",81);
th2_new = filloutliers(th2,"linear","movmedian",81);

% Plot threshold variation versus slice number
figure()
plot(slice_list,th1,'o-');hold on
plot(slice_list,th2,'o-');hold on
plot(slice_list,th1_new,'o-');hold on
plot(slice_list,th2_new,'o-');hold on
xlabel('slice number');
ylabel('thresholds')
grid on
legend('threshold 1','threshold 2','filtered threshold 1','filtered threshold 2')

% Combine the updated thresholds
threshold_new = [slice_list,th1_new,th2_new];

%% 
% Use the smoothed thresholds for volume rendering
[PA, LCP, Blend, Void, Raw, vol, vlcp, vpa, vvoid] = ...
    volumeRender_PA(filename, initialSlice, sliceNumber,threshold_new);

% 3D visualization of the blended segmentation result
% vPC = volshow(PA);
% vLCP = volshow(LCP);
vBlend = volshow(Blend);
% vVoid = volshow(Void);

% Compute the volume ratio between PA and LCP
volratio = vpa/vlcp

% Volume fractions relative to the total volume
rv_LCP = vlcp/vol;
rv_PA = vpa/vol;
rv_void = vvoid/vol;

% save(samplename)

%% 
% -------------------------------------------------------------------------
% Function: background fitting
%
% Parameter description:
%   pic      - input image, expected to be a 16-bit grayscale image
%   pflag    - flag indicating whether to display intermediate results
%   mixRatio - initial constraints for the three-peak Gaussian fitting [a,b,c]
%
% Output description:
%   x1  - leftmost non-zero gray value in the histogram
%   x2  - rightmost non-zero gray value in the histogram
%   mu  - center locations of the three Gaussian peaks
%   sig - width parameters of the three Gaussian peaks
%   A   - amplitude parameters of the three Gaussian peaks
% -------------------------------------------------------------------------
function [x1,x2, mu, sig, A] = cal_bk(pic, pflag, mixRatio)
% two operations: find up & low limit of target picture
% detect background from histogram
% pic: input figure, c: ratio between two peaks
% pflag: you determine whether to plot background

% Compute histogram
h0 = imhist(pic,2^16);
g0 = 0:1:2^16-1;
g0 = g0.';

% x1 and x2 are the first non-zero elements of h0
% (x1: from left to right, x2: from right to left)
index = find(h0~=0);
x1 = g0(index(1));

h0_flip = flip(h0);
g0_flip = flip(g0);
index = find(h0_flip~=0);
x2 = g0_flip(index(1));

% First visualization: image and histogram range
if pflag == 1
    figure()
    subplot(1,2,1)
    imshow(pic,[])
    subplot(1,2,2)
    plot(g0,h0,'r.');hold on
    plot([x1,x1],[0,max(h0)],'m--');hold on
    plot([x2,x2],[0,max(h0)],'m--');hold on
end

% Extract valid histogram section
g = g0(x1+1:1:x2+1);
h = h0(x1+1:1:x2+1);

% Extract mixture ratio parameters
a = mixRatio(1);
b = mixRatio(2);
c = mixRatio(3);

% Fit the histogram using a three-Gaussian model
options = fitoptions('gauss3');
options.lower = [0 a*g(1)+(1-a)*g(end) 0 ...
    0 b*g(1)+(1-b)*g(end) 0 ...
    0 c*g(1)+(1-c)*g(end) 0];
options.upper = [inf g(end) inf inf g(end) inf inf g(end) inf];

f = fit(g,h,'gauss3',options);
A=[f.a1 f.a2 f.a3];
mu=[f.b1 f.b2 f.b3];
sig=[f.c1 f.c2 f.c3];

% Sort peaks by center position
[mu,I]=sort(mu);
sig=sig(I);
A=A(I);

% Second visualization: fitted curves
if pflag == 1
    NormalDistribution=@(x,mu,sigma,a)a*exp(-((x-mu)./sigma).^2);
    x_fit= linspace(x1,x2,200);
    y1_fit=NormalDistribution(x_fit,mu(1),sig(1),A(1));
    y2_fit=NormalDistribution(x_fit,mu(2),sig(2),A(2));
    y3_fit=NormalDistribution(x_fit,mu(3),sig(3),A(3));
    y_fit = y1_fit+y2_fit+y3_fit;
    figure()
    loglog(g,h,'ro');hold on
    loglog(x_fit,y1_fit);hold on
    loglog(x_fit,y2_fit);hold on
    loglog(x_fit,y3_fit);hold on
    axis([x1 x2 1 max(h)])
    legend('raw data','feature 1','feature 2','feature 3')
    % savefig('background')
end

% Return integer-valued peak locations
mu = round(mu);
end

%% 
% -------------------------------------------------------------------------
% Function: compute threshold cross-sections
%
% Parameter description:
%   g      - gray-axis coordinates of the background histogram
%   h      - histogram counts
%   mu     - center locations of the three Gaussian peaks
%   c      - threshold ratio parameters [c1,c2]
%   ptflag - flag indicating whether to display threshold locations
%
% Output description:
%   th1 - first segmentation threshold
%   th2 - second segmentation threshold
% -------------------------------------------------------------------------
function [th1,th2] = cal_crossection(g,h,mu,c,ptflag)
% calculate crossection

% Old intersection-based strategy, currently not used
% % NormalDistribution=@(x,mu,sigma,a)a*exp(-((x-mu)./sigma).^2);
% % x_fit= linspace(x1,x2,200);
% % y1_fit=NormalDistribution(x_fit,mu(1),sig(1),A(1));
% % y2_fit=NormalDistribution(x_fit,mu(2),sig(2),A(2));
% % y3_fit=NormalDistribution(x_fit,mu(3),sig(3),A(3));
% % y_fit = y1_fit+y2_fit+y3_fit;
% %
% % ND_1 = @(x)A(1)*exp(-((x-mu(1))./sig(1)).^2);
% % ND_2 = @(x)A(2)*exp(-((x-mu(2))./sig(2)).^2);
% % ND_3 = @(x)A(3)*exp(-((x-mu(3))./sig(3)).^2);
% %
% % solhd1 = @(x)(A(1)*exp(-((x-mu(1))./sig(1)).^2)-A(2)*exp(-((x-mu(2))./sig(2)).^2));
% % solhd2 = @(x)(A(2)*exp(-((x-mu(2))./sig(2)).^2)-A(3)*exp(-((x-mu(3))./sig(3)).^2));
% %
% % fsolve(solhd1,0.5*x1+0.5*x2)
% % % fsolve(ND_1,x1)

% Round peak centers
mu = round(mu);

% Find the indices corresponding to the three peaks
index1 = find(g==mu(1));
index2 = find(g==mu(2));
index3 = find(g==mu(3));

% Old minimum-based threshold strategy, currently not used
% temp1 = h(index1:index2);
% temp2 = h(index2:index3);
% [~,loc1] = min(temp1);
% [~,loc2] = min(temp2);
%
% tem1 = g(index1:index2);
% tem2 = g(index2:index3);
% th1 = tem1(loc1);
% th2 = tem2(loc2);

% Select thresholds using fixed relative positions between peaks
th1 = g(round(index1*c(1)+index2*(1-c(1))));
th2 = g(round(index2*c(2)+index3*(1-c(2))));

% Visualize thresholds and peak positions
if ptflag == 1
    figure()
    loglog(g,h,'r.');hold on
    loglog([mu(1),mu(1)],[1,max(h)],'m--');hold on
    loglog([mu(2),mu(2)],[1,max(h)],'m--');hold on
    loglog([mu(3),mu(3)],[1,max(h)],'m--');hold on
    loglog([th1,th1],[1,max(h)],'g-.');hold on
    loglog([th2,th2],[1,max(h)],'g-.');hold on
    axis([min(g) max(g) 1 max(h)])
    legend('raw data','\mu_1','\mu_2','\mu_3',...
        'threshold 1','threshold 2','threshold 3')
end
end

%% 
% -------------------------------------------------------------------------
% Function: detect voids, PC, and LCP areas
%
% Parameter description:
%   pic_sig     - segmented image with class labels:
%                 1: air
%                 2: LCP
%                 3: PC
%   outmost_edge - outer boundary map
%
% Output description:
%   pic_sig_new - relabeled segmented image
%   Atotal      - total effective area
%   Avoid       - void area
%   ALCP        - LCP area
%   APC         - PC area
% -------------------------------------------------------------------------
function [pic_sig_new, Atotal, Avoid, ALCP, APC] = cal_detect_voids(pic_sig, outmost_edge)

% Initialize statistics
[n1, n2] = size(pic_sig);
Atotal = 0;
Avoid = 0;
ALCP = 0;
APC = 0;
pic_sig_new = pic_sig;

% Traverse all pixels
for i = 1:n1
    for j = 1:n2

        if pic_sig(i,j) == 2  % LCP
            Atotal = Atotal + 1;
            ALCP = ALCP + 1;

        elseif pic_sig(i,j) == 3  % PC
            Atotal = Atotal + 1;
            APC = APC+ 1;

        elseif pic_sig(i,j) == 1  % air
            % If the pixel lies on the outer boundary, skip it
            if outmost_edge(i,j) == 1
                continue
            else
                % ---------------------------------------------------------
                % Use a ray-crossing / cross-number style method to decide
                % whether the pixel is inside a closed region.
                % Rays are cast in four directions: +x, +y, -x, -y.
                % The number of boundary crossings is counted.
                % ---------------------------------------------------------

                % +x direction
                counter_x = 0;
                for k = j:n2
                    if (outmost_edge(i,k) == 1) && (outmost_edge(i,k-1) == 0)
                        counter_x = counter_x + 1;
                    end
                end

                % +y direction
                counter_y = 0;
                for k = i:n1
                    if (outmost_edge(k,j) == 1) && (outmost_edge(k-1,j) == 0)
                        counter_y = counter_y + 1;
                    end
                end

                % -x direction
                counter_x_back = 0;
                for k = 1:j-1
                    if (outmost_edge(i,k) == 1) && (outmost_edge(i,k-1) == 0)
                        counter_x_back = counter_x_back + 1;
                    end
                end

                % -y direction
                counter_y_back = 0;
                for k = 1:i-1
                    if (outmost_edge(k,j) == 1) && (outmost_edge(k,k-1) == 0)
                        counter_y_back = counter_y_back + 1;
                    end
                end

                % If all four directions have an odd number of crossings,
                % the pixel is classified as void
                if ((-1)^counter_x == -1) && ((-1)^counter_y == -1) &&...
                   ((-1)^counter_x_back == -1) && ((-1)^counter_y_back == -1)
                    Atotal = Atotal + 1;
                    Avoid = Avoid + 1;
                    pic_sig_new(i,j) = 4;       % Mark as void
                end
            end
        else
            error('wrong image!');
        end
    end
end
end

%% 
% -------------------------------------------------------------------------
% Function: volume rendering
%
% Parameter description:
%   filename      - folder path containing image slices
%   initialSlice  - starting slice index
%   sliceNumber   - number of slices to read
%   threshold     - threshold table for each slice, formatted as
%                   [slice_id, th1, th2]
%
% Output description:
%   PC            - 3D binary matrix for PC
%   LCP           - 3D binary matrix for LCP
%   Blend         - 3D segmentation matrix
%   Void          - 3D binary matrix for void
%   Raw           - raw image stack
%   vol           - total effective volume
%   vlcp          - LCP volume
%   vpa           - PC volume
%   vvoid         - void volume
%   threshold_save - threshold record generated inside the function
% -------------------------------------------------------------------------
function [PC, LCP, Blend, Void, Raw, vol, vlcp, vpa, vvoid,threshold_save] = ...
    volumeRender_PA(filename, initialSlice, sliceNumber,threshold)

% Read the first image to determine image size
tem = strcat(filename,'slice00000.tif');
pic0 = imread(tem);
[n1,n2] = size(pic0);

% Initialize 3D arrays
PA = zeros(n1,n2,sliceNumber);
LCP = PA;
Blend = PA;
Void = PA;
Raw = PA;

% Initialize volume statistics
vol = 0;
vpa = 0;
vlcp = 0;
vvoid = 0;

threshold_save = [];

for i=1:sliceNumber
    j = initialSlice + i;

    % Generate the current slice filename
    if j<11
        imdex=sprintf('slice0000%d.tif',j-1);
    elseif j<101
        imdex=sprintf('slice000%d.tif',j-1);
    elseif j<1001
        imdex=sprintf('slice00%d.tif',j-1);
    else
        imdex=sprintf('slice0%d.tif',j-1);
    end

    % Concatenate full file path
    imdex = [filename imdex]
    pictem = imread(imdex);

    % ---------------------------------------------------------------------
    % The following processing pipeline is kept as a commented backup:
    % 1. Gaussian filtering
    % 2. Background fitting
    % 3. Automatic threshold calculation
    % ---------------------------------------------------------------------
    % pictem = imgaussfilt(pictem,1);
    %
    % [x1,x2, mu, sig, A] = cal_bk(pictem, pflag, mixRatio);
    %
    % h0 = imhist(pictem,2^16);
    % g0 = 0:1:2^16-1;
    % g0 = g0.';
    %
    % h_bk = h0(x1:x2);
    % g_bk = g0(x1:x2);
    %
    % [th1,th2] = cal_crossection(g_bk,h_bk,mu,cfeature,pflag);
    %
    % threshold = [th1, th2];
    % threshold_save = [threshold_save;[j,th1,th2]];
    
    % Quantize the current slice using externally provided thresholds
    blend = imquantize(pictem,threshold(i,2:3));
    
    % ---------------------------------------------------------------------
    % Swap class labels 2 <-> 3
    % Final class convention:
    % air(1), LCP(2), PC(3)
    % ---------------------------------------------------------------------
    [n1,n2] = size(blend);
    blendtem = blend;
    for k1 = 1:n1
        for k2 = 1:n2
            if blend(k1,k2) == 2
                blendtem(k1,k2) = 3;
            elseif blend(k1,k2) == 3
                blendtem(k1,k2) = 2;
            end
        end
    end
    blend = blendtem;
    
    % Class meaning after swapping:
    % air(1), LCP(2), PC(3)

    % Detect the outermost boundary
    edgetem = imfill(blend);
    outmost_edge = edge(edgetem);

    % Detect voids and accumulate area information
    [blend_new,Atotal, Avoid, ALCP, APA] = cal_detect_voids(blend, outmost_edge);
    vol = vol + Atotal;
    vlcp = vlcp + ALCP;
    vpa = vpa + APA;
    vvoid = vvoid + Avoid;

    % Set background class to zero and separate different phases
    blend_new(blend_new==1) = 0;
    pc = blend_new;
    lcp = blend_new;
    void = blend_new;

    % Extract PC
    pc(pc==3) = 1;
    pc(pc==2) = 0;
    pc(pc==4) = 0;

    % Extract LCP
    lcp(lcp==2) = 1;
    lcp(lcp==3) = 0;
    lcp(lcp==4) = 0;

    % Extract void
    void(void==4) = 1;
    void(void==2) = 0;
    void(void==3) = 0;

    % Save each slice result
    % vpc = vpc + sum(sum(pc));
    % vlcp = vlcp + sum(sum(lcp));
    PC(:,:,i) = pc;
    LCP(:,:,i) = lcp;
    Blend(:,:,i) = blend_new;
    Void(:,:,i) = void;
    Raw(:,:,i) = pictem;
end

% Optional visualization of the 3D result
% vPC = volshow(PC);
% vLCP = volshow(LCP);
% vBlend = volshow(Blend);
% volratio = vpc/vlcp
end

%% 
% -------------------------------------------------------------------------
% Function: automatically estimate thresholds for each slice
%
% Parameter description:
%   filename      - folder path containing image slices
%   initialSlice  - starting slice index
%   sliceNumber   - number of slices
%   cfeature      - threshold location ratio parameter
%   pflag         - flag indicating whether to display fitting results
%   mixRatio      - three-peak fitting constraint ratio [a,b,c]
%
% Output description:
%   threshold_save - threshold table for each slice, formatted as
%                    [slice_id, th1, th2]
% -------------------------------------------------------------------------
function [threshold_save] = ...
    volumeThreshold(filename, initialSlice, sliceNumber, cfeature, pflag,mixRatio)
% old output: [PC, LCP, Blend, Void, vol, vlcp, vpa, vvoid,threshold_save]
% determine dimension of image
tem = strcat(filename,'slice00000.tif');
pic0 = imread(tem);
[n1,n2] = size(pic0);

% Initialize 3D arrays (used mainly as placeholders)
PA = zeros(n1,n2,sliceNumber);
LCP = PA;
Blend = PA;
Void = PA;

% Initialize accumulated statistics
vol = 0;
vpa = 0;
vlcp = 0;
vvoid = 0;

threshold_save = [];

for i=1:sliceNumber
    j = initialSlice + i;

    % Generate the current slice filename
    if j<11
        imdex=sprintf('slice0000%d.tif',j-1);
    elseif j<101
        imdex=sprintf('slice000%d.tif',j-1);
    elseif j<1001
        imdex=sprintf('slice00%d.tif',j-1);
    else
        imdex=sprintf('slice0%d.tif',j-1);
    end

    imdex = [filename imdex]
    pictem = imread(imdex);

    % Apply Gaussian filtering to reduce noise
    pictem = imgaussfilt(pictem,1);

    % Estimate background and valid intensity range
    [x1,x2, mu, sig, A] = cal_bk(pictem, pflag, mixRatio);

    h0 = imhist(pictem,2^16);
    g0 = 0:1:2^16-1;
    g0 = g0.';

    h_bk = h0(x1:x2);
    g_bk = g0(x1:x2);

    % Compute thresholds
    [th1,th2] = cal_crossection(g_bk,h_bk,mu,cfeature,pflag);
    
    % Optional enhancement steps, currently unused
    % pictem = imadjust(pictem,[],[],2);
    % pictem = adapthisteq(pictem,'cliplimit',0.1,'numtiles',[2,2],'distribution','exponential');

    % Save slice index and thresholds
    tem = [j,th1,th2];
    if isempty(th1) || isempty(th2)
        tem = threshold_save(i-1,:);
    end
    threshold_save = [threshold_save;tem];

    % ---------------------------------------------------------------------
    % The original segmentation and statistics workflow is commented out
    % in this function. It can be re-enabled if needed.
    % ---------------------------------------------------------------------
    % blend = imquantize(pictem,threshold);
    % 
    % % flip PC and LCP
    % [n1,n2] = size(blend);
    % blendtem = blend;
    % for k1 = 1:n1
    %     for k2 = 1:n2
    %         if blend(k1,k2) == 2
    %             blendtem(k1,k2) = 3;
    %         elseif blend(k1,k2) == 3
    %             blendtem(k1,k2) = 2;
    %         end
    %     end
    % end
    % blend = blendtem;
    % % now we have air(1), LCP(2), PC(3)
    % 
    % 
    % % detect the outmost edge
    % edgetem = imfill(blend);
    % outmost_edge = edge(edgetem);
    % 
    % % detect voids and calculate relavant fractions
    % [blend_new,Atotal, Avoid, ALCP, APA] = cal_detect_voids(blend, outmost_edge);
    % vol = vol + Atotal;
    % vlcp = vlcp + ALCP;
    % vpa = vpa + APA;
    % vvoid = vvoid + Avoid;
    % 
    % blend_new(blend_new==1) = 0;
    % pc = blend_new;
    % lcp = blend_new;
    % void = blend_new;
    % 
    % pc(pc==3) = 1;
    % pc(pc==2) = 0;
    % pc(pc==4) = 0;
    % 
    % lcp(lcp==2) = 1;
    % lcp(lcp==3) = 0;
    % lcp(lcp==4) = 0;
    % 
    % void(void==4) = 1;
    % void(void==2) = 0;
    % void(void==3) = 0;
    % 
    % % vpc = vpc + sum(sum(pc));
    % % vlcp = vlcp + sum(sum(lcp));
    % PC(:,:,i) = pc;
    % LCP(:,:,i) = lcp;
    % Blend(:,:,i) = blend_new;
    % Void(:,:,i) = void;
end

% vPC = volshow(PC);
% vLCP = volshow(LCP);
% vBlend = volshow(Blend);
% volratio = vpc/vlcp
end

%% 
% -------------------------------------------------------------------------
% Function: simple weighted filtering
%
% Parameter description:
%   x - input data vector
%   w - weight vector / kernel
%
% Output description:
%   y - filtered data
% -------------------------------------------------------------------------
function y = myFilter(x,w)

n = length(x);
m = floor(length(w)/2);

y = zeros(size(x));

w = w(:);

for i = 1:n

    idx1 = max(1,i-m);
    idx2 = min(n,i+m);

    xx = x(idx1:idx2);
    xx = xx(:);

    ww = w((idx1-i+m+1):(idx2-i+m+1));
    ww = ww(:);

    ww = ww/sum(ww);

    y(i) = dot(xx,ww);

end

end