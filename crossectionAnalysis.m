% analyze composite beam
clear
clc
close all

tic
% load data
sampleName = 'LME0_025';
load(strcat(sampleName,'.mat'));
clearvars -except Blend sampleName
load('rotationAngle.mat');
index = find(sample==sampleName);
rotation = angle(index);

% initialization
EL = [3578e3, 4017e3, 2636e3];
EP = [2579e3, 1452e3, 1452e3];
Elcp = EL(str2num(sampleName(4)));
Epc = EP(str2num(sampleName(4)));

% Elcp = 4000e6;
% Epc = 1500e6;
h = 10e-6;

% get one example image
% get rotation angle manually
ex_im = Blend(:,:,100);

% rotation = -10;
ex_im_new = imrotate(ex_im,rotation);


% do downsampling if necessary

% calculate location of neutral axis(y) and modulus (Iz)
[yc_index,~,~,~,~,~,~,~,~, ~] = cal_neutralAxis(ex_im_new,Elcp,Epc);
tem_im = ex_im_new;
tem_im(yc_index,:) = 10;
figure()
imshow(tem_im,[])


% try to analyze multiple cross-sections
n_cs = 190;         % number of cross-sections
cs_0 = 1;        % # if 1st cross-section

[n1,n2] = size(ex_im_new);
beam_new = zeros(n1,n2,n_cs);
flag = ones(n_cs,1);

neuAxis = [];
neuAxis_re = [];
bendModuli = [];
St = [];
Slcp = [];
Spc = [];
Svoid = [];
GF = [];

for i = 1:n_cs
    tem_im = Blend(:,:,cs_0 + i);
    % size(tem_im)
    tem_im = imrotate(tem_im,rotation);
    % size(tem_im)
    [yc_index,Ilcp,Ipc,Iz,Ivoid,Itotal, Slcp_tem,Spc_tem,Svoid_tem, Stotal_tem] ...
        = cal_neutralAxis(tem_im,Elcp,Epc);

    % determine box
    [upper,lower,left,right] = cal_box(tem_im);
    GF_tem = (2*(right-left)*(lower-upper)^3)*h^4;
    GF = [GF;GF_tem];

    % modify tem_im if possible
    if yc_index == yc_index
        tem_im(upper,:) = 10;
        tem_im(lower,:) = 10;
        tem_im(:,left) = 10;
        tem_im(:,right) = 10;
        tem_im(yc_index,:) = 10;

        % calculate relative neuAxis
        neuAxis_re = [neuAxis_re;(yc_index-upper)/(lower-upper)];
    else          % invalid yc_index
        flag(i) = 0;
        neuAxis_re = [neuAxis_re;0];
    end

    neuAxis = [neuAxis;yc_index];
    
    bendModuli = [bendModuli;[Ilcp,Ipc,Iz,Itotal,Ivoid]];
    St = [St;Stotal_tem];
    Slcp = [Slcp;Slcp_tem];
    Spc = [Spc;Spc_tem];
    Svoid = [Svoid;Svoid_tem];

    beam_new(:,:,i) = tem_im;
end
bendModuli = bendModuli.*h^4;
flexMod = bendModuli(:,3)./bendModuli(:,4);
flexMod_lcp = bendModuli(:,1)./bendModuli(:,4);
flexMod_pc = bendModuli(:,2)./bendModuli(:,4);
flexMod_modified = bendModuli(:,3)./GF;

St = St*h^2;
Spc = Spc*h^2;
Slcp = Slcp*h^2;
Svoid = Svoid*h^2;

% visualization
cs = (1:1:n_cs).';

% delete those NaN
index = find(Svoid==0);
flag(index) = 0;


index = find(flag==0);

cs(index) = [];
neuAxis(index) = [];
neuAxis_re(index) = [];
St(index) = [];
Slcp(index) = [];
Spc(index) = [];
Svoid(index) = [];
bendModuli(index,:) = [];
flexMod(index) = [];
flexMod_lcp(index) = [];
flexMod_pc(index) = [];


figure()
subplot(1,2,1)
plot(cs,neuAxis_re,'o-')
title('relative neutral axis location')
grid on
subplot(1,2,2)
plot(cs,neuAxis,'o-')
title('neutral axis location')
grid on

figure()
subplot(1,2,1)
plot(cs,Slcp,'o-');hold on
plot(cs,Spc,'o-');hold on
plot(cs,St,'o-');hold on
plot(cs,Svoid,'o-');hold on
legend('lcp','pc','composite','void')
% legend('lcp','composite','void')
title('Area')
grid on

subplot(1,2,2)
plot(cs,Svoid./(St+Svoid)*100,'o-');hold on
title('Area fraction of void(%)')
grid on

figure()
subplot(1,2,1)
plot(cs,bendModuli(:,1),'o-');hold on
plot(cs,bendModuli(:,2),'o-');hold on
plot(cs,bendModuli(:,3),'o-');hold on
legend('lcp','pc','composite')
% legend('lcp','composite')
title('bending modulus')
grid on

subplot(1,2,2)
plot(cs,flexMod_lcp,'o-');hold on
plot(cs,flexMod_pc,'o-');hold on
plot(cs,flexMod,'o-');hold on
legend('lcp','pc','composite')
% legend('lcp','composite')
title('Flexural Modulus')
grid on


tem = strcat(sampleName,'_cs_updated.mat');
save(tem)
toc