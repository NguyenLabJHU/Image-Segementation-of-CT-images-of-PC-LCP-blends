function [x1,x2,background] = cal_background(pic, c, pflag)
% two operations: find up & low limit of target picture
% detect background from histogram
% pic: input figure, c: ratio between two peaks
% pflag: you determine whether to plot background

% initialization
% clear
% clc
% close all
% 
% filename = 'D:\XCT_0307\C4\SlicesY\';
% pic = imread([filename 'slice00050.tif']);

% get histogram
h0 = imhist(pic,2^16);
g0 = 0:1:2^16-1;
g0 = g0.';

% x1, x2 are the first non-zero element of h0 
% (x1, left to right, x2, right to left)
index = find(h0~=0);
x1 = g0(index(1));

h0_flip = flip(h0);
g0_flip = flip(g0);
index = find(h0_flip~=0);
x2 = g0_flip(index(1));

% 1st visualization
% figure()
% subplot(1,2,1)
% imshow(pic,[])
% subplot(1,2,2)
% plot(g0,h0,'r.');hold on
% plot([x1,x1],[0,max(h0)],'m--');hold on
% plot([x2,x2],[0,max(h0)],'m--');hold on

% make section
g = g0(x1+1:1:x2+1);
h = h0(x1+1:1:x2+1);

% do a 2-term gaussian fit
options = fitoptions('gauss2');
options.lower = [0 g0(x1) 0 0 (g0(x1)+g0(x2))/2 0];
f = fit(g,h,'gauss2',options);
A=[f.a1 f.a2];
mu=[f.b1 f.b2];
sig=[f.c1 f.c2];
[mu,I]=sort(mu);
sig=sig(I);A=A(I);

% detect background
background = c*mu(1)+(1-c)*mu(2);
background = round(background);

% 2nd visulization
if pflag == 1
    NormalDistribution=@(x,mu,sigma,a)a*exp(-((x-mu)./sigma).^2);
    x_fit= linspace(x1,x2,200);
    y1_fit=NormalDistribution(x_fit,mu(1),sig(1),A(1));
    y2_fit=NormalDistribution(x_fit,mu(2),sig(2),A(2));
    y_fit = y1_fit+y2_fit;
    figure()
    plot(g,h,'ro');hold on
    plot(x_fit,y1_fit);hold on
    plot(x_fit,y2_fit);hold on
    plot(x_fit,y_fit);hold on
    plot([background,background],[0,max(y_fit)],'m--');hold on
    legend('raw data','feature 1','feature 2','fitted data','background')
    savefig('background')
end
end
