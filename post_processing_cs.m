% data post-processing
clear
clc
close all
%% momentum of voids
clear
clc
close all

Izvoid = [];
Izvoid_err = [];
Avoid = [];
Avoid_err = [];

load('LME0_025_cs.mat');
tem = mean(bendModuli(:,5)./bendModuli(:,4));
Izvoid = [Izvoid tem];
Izvoid_err= [Izvoid_err std(bendModuli(:,5)./bendModuli(:,4))];
Avoid = [Avoid mean(Svoid./St)];
Avoid_err = [Avoid_err std(Svoid./St)];

load('LME0_050_cs.mat');
tem = mean(bendModuli(:,5)./bendModuli(:,4));
Izvoid = [Izvoid tem];
Izvoid_err= [Izvoid_err std(bendModuli(:,5)./bendModuli(:,4))];
Avoid = [Avoid mean(Svoid./St)];
Avoid_err = [Avoid_err std(Svoid./St)];

load('LME0_075_cs.mat');
tem = mean(bendModuli(:,5)./bendModuli(:,4));
Izvoid = [Izvoid tem];
Izvoid_err= [Izvoid_err std(bendModuli(:,5)./bendModuli(:,4))];
Avoid = [Avoid mean(Svoid./St)];
Avoid_err = [Avoid_err std(Svoid./St)];

load('LME0_100_cs.mat');
tem = mean(bendModuli(:,5)./bendModuli(:,4));
Izvoid = [Izvoid tem];
Izvoid_err= [Izvoid_err std(bendModuli(:,5)./bendModuli(:,4))];
Avoid = [Avoid mean(Svoid./St)];
Avoid_err = [Avoid_err std(Svoid./St)];

load('LME1_025_cs.mat');
tem = mean(bendModuli(:,5)./bendModuli(:,4));
Izvoid = [Izvoid tem];
Izvoid_err= [Izvoid_err std(bendModuli(:,5)./bendModuli(:,4))];
Avoid = [Avoid mean(Svoid./St)];
Avoid_err = [Avoid_err std(Svoid./St)];

load('LME1_050_cs.mat');
tem = mean(bendModuli(:,5)./bendModuli(:,4));
Izvoid = [Izvoid tem];
Izvoid_err= [Izvoid_err std(bendModuli(:,5)./bendModuli(:,4))];
Avoid = [Avoid mean(Svoid./St)];
Avoid_err = [Avoid_err std(Svoid./St)];

load('LME1_075_cs.mat');
tem = mean(bendModuli(:,5)./bendModuli(:,4));
Izvoid = [Izvoid tem];
Izvoid_err= [Izvoid_err std(bendModuli(:,5)./bendModuli(:,4))];
Avoid = [Avoid mean(Svoid./St)];
Avoid_err = [Avoid_err std(Svoid./St)];

load('LME1_100_cs.mat');
tem = mean(bendModuli(:,5)./bendModuli(:,4));
Izvoid = [Izvoid tem];
Izvoid_err= [Izvoid_err std(bendModuli(:,5)./bendModuli(:,4))];
Avoid = [Avoid mean(Svoid./St)];
Avoid_err = [Avoid_err std(Svoid./St)];

load('LME2_025_cs.mat');
tem = mean(bendModuli(:,5)./bendModuli(:,4));
Izvoid = [Izvoid tem];
Izvoid_err= [Izvoid_err std(bendModuli(:,5)./bendModuli(:,4))];
Avoid = [Avoid mean(Svoid./St)];
Avoid_err = [Avoid_err std(Svoid./St)];

load('LME2_050_cs.mat');
tem = mean(bendModuli(:,5)./bendModuli(:,4));
Izvoid = [Izvoid tem];
Izvoid_err= [Izvoid_err std(bendModuli(:,5)./bendModuli(:,4))];
Avoid = [Avoid mean(Svoid./St)];
Avoid_err = [Avoid_err std(Svoid./St)];

load('LME2_075_cs.mat');
tem = mean(bendModuli(:,5)./bendModuli(:,4));
Izvoid = [Izvoid tem];
Izvoid_err= [Izvoid_err std(bendModuli(:,5)./bendModuli(:,4))];
Avoid = [Avoid mean(Svoid./St)];
Avoid_err = [Avoid_err std(Svoid./St)];

load('LME2_100_cs.mat');
tem = mean(bendModuli(:,5)./bendModuli(:,4));
Izvoid = [Izvoid tem];
Izvoid_err= [Izvoid_err std(bendModuli(:,5)./bendModuli(:,4))];
Avoid = [Avoid mean(Svoid./St)];
Avoid_err = [Avoid_err std(Svoid./St)];

void_LME0 = Izvoid(1:4);
void_LME1 = Izvoid(5:8);
void_LME2 = Izvoid(9:12);

void_LME0_err = Izvoid_err(1:4);
void_LME1_err = Izvoid_err(5:8);
void_LME2_err = Izvoid_err(9:12);

Avoid_LME0 = Avoid(1:4);
Avoid_LME1 = Avoid(5:8);
Avoid_LME2 = Avoid(9:12);

Avoid_LME0_err = Avoid_err(1:4);
Avoid_LME1_err = Avoid_err(5:8);
Avoid_LME2_err = Avoid_err(9:12);

figure()
errorbar([25 50 75 100],void_LME0,void_LME0_err,'s-');hold on
errorbar([25 50 75 100],void_LME1,void_LME1_err,'s-');hold on
errorbar([25 50 75 100],void_LME2,void_LME2_err,'s-');hold on

figure()
errorbar([25 50 75 100],Avoid_LME0,Avoid_LME0_err,'s-');hold on
errorbar([25 50 75 100],Avoid_LME1,Avoid_LME1_err,'s-');hold on
errorbar([25 50 75 100],Avoid_LME2,Avoid_LME2_err,'s-');hold on
%% confirm neutrial axis assumption - location of neutral axis
close all
clear
clc

figure()
load('LME0_050_cs.mat');
plot(cs,neuAxis_re,'o-');hold on

load('LME1_050_cs.mat');
plot(cs,neuAxis_re,'o-');hold on

load('LME2_050_cs.mat');
plot(cs,neuAxis_re,'o-');hold on

load('LME0_075_cs.mat');
plot(cs,neuAxis_re,'o-');hold on

load('LME1_075_cs.mat');
plot(cs,neuAxis_re,'o-');hold on

load('LME2_075_cs.mat');
plot(cs,neuAxis_re,'o-');hold on
grid on
%% confirm assumption - flexural moduli of 050 sample
clear
clc
close all

figure()
load('LME0_050_cs.mat');
plot(cs,flexMod_lcp,'o-');hold on
load('LME1_050_cs.mat');
plot(cs,flexMod_lcp,'o-');hold on
load('LME2_050_cs.mat');
plot(cs,flexMod_lcp,'o-');hold on
load('LME0_050_cs.mat');
plot(cs,flexMod_pc,'o-');hold on
load('LME1_050_cs.mat');
plot(cs,flexMod_pc,'o-');hold on
load('LME2_050_cs.mat');
plot(cs,flexMod_pc,'o-');hold on
%% effects of LCP concentration
clear
clc
close all

pc_mod = [];
pc_err = [];
lcp_mod = [];
lcp_err = [];
flex_mod = [];
flex_err = [];

load('LME0_025_cs.mat');
pc_mod = [pc_mod mean(flexMod_pc)];
pc_err = [pc_err std(flexMod_pc)];
lcp_mod = [lcp_mod mean(flexMod_lcp)];
lcp_err = [lcp_err std(flexMod_lcp)];
flex_mod = [flex_mod mean(flexMod)];
flex_err = [flex_err std(flexMod)];

load('LME0_050_cs.mat');
pc_mod = [pc_mod mean(flexMod_pc)];
pc_err = [pc_err std(flexMod_pc)];
lcp_mod = [lcp_mod mean(flexMod_lcp)];
lcp_err = [lcp_err std(flexMod_lcp)];
flex_mod = [flex_mod mean(flexMod)];
flex_err = [flex_err std(flexMod)];

load('LME0_075_cs.mat');
pc_mod = [pc_mod mean(flexMod_pc)];
pc_err = [pc_err std(flexMod_pc)];
lcp_mod = [lcp_mod mean(flexMod_lcp)];
lcp_err = [lcp_err std(flexMod_lcp)];
flex_mod = [flex_mod mean(flexMod)];
flex_err = [flex_err std(flexMod)];

load('LME0_100_cs.mat');
pc_mod = [pc_mod mean(flexMod_pc)];
pc_err = [pc_err std(flexMod_pc)];
lcp_mod = [lcp_mod mean(flexMod_lcp)];
lcp_err = [lcp_err std(flexMod_lcp)];
flex_mod = [flex_mod mean(flexMod)];
flex_err = [flex_err std(flexMod)];

load('LME1_025_cs.mat');
pc_mod = [pc_mod mean(flexMod_pc)];
pc_err = [pc_err std(flexMod_pc)];
lcp_mod = [lcp_mod mean(flexMod_lcp)];
lcp_err = [lcp_err std(flexMod_lcp)];
flex_mod = [flex_mod mean(flexMod)];
flex_err = [flex_err std(flexMod)];

load('LME1_050_cs.mat');
pc_mod = [pc_mod mean(flexMod_pc)];
pc_err = [pc_err std(flexMod_pc)];
lcp_mod = [lcp_mod mean(flexMod_lcp)];
lcp_err = [lcp_err std(flexMod_lcp)];
flex_mod = [flex_mod mean(flexMod)];
flex_err = [flex_err std(flexMod)];

load('LME1_075_cs.mat');
pc_mod = [pc_mod mean(flexMod_pc)];
pc_err = [pc_err std(flexMod_pc)];
lcp_mod = [lcp_mod mean(flexMod_lcp)];
lcp_err = [lcp_err std(flexMod_lcp)];
flex_mod = [flex_mod mean(flexMod)];
flex_err = [flex_err std(flexMod)];

load('LME1_100_cs.mat');
pc_mod = [pc_mod mean(flexMod_pc)];
pc_err = [pc_err std(flexMod_pc)];
lcp_mod = [lcp_mod mean(flexMod_lcp)];
lcp_err = [lcp_err std(flexMod_lcp)];
flex_mod = [flex_mod mean(flexMod)];
flex_err = [flex_err std(flexMod)];

load('LME2_025_cs.mat');
pc_mod = [pc_mod mean(flexMod_pc)];
pc_err = [pc_err std(flexMod_pc)];
lcp_mod = [lcp_mod mean(flexMod_lcp)];
lcp_err = [lcp_err std(flexMod_lcp)];
flex_mod = [flex_mod mean(flexMod)];
flex_err = [flex_err std(flexMod)];

load('LME2_050_cs.mat');
pc_mod = [pc_mod mean(flexMod_pc)];
pc_err = [pc_err std(flexMod_pc)];
lcp_mod = [lcp_mod mean(flexMod_lcp)];
lcp_err = [lcp_err std(flexMod_lcp)];
flex_mod = [flex_mod mean(flexMod)];
flex_err = [flex_err std(flexMod)];

load('LME2_075_cs.mat');
pc_mod = [pc_mod mean(flexMod_pc)];
pc_err = [pc_err std(flexMod_pc)];
lcp_mod = [lcp_mod mean(flexMod_lcp)];
lcp_err = [lcp_err std(flexMod_lcp)];
flex_mod = [flex_mod mean(flexMod)];
flex_err = [flex_err std(flexMod)];

load('LME2_100_cs.mat');
pc_mod = [pc_mod mean(flexMod_pc)];
pc_err = [pc_err std(flexMod_pc)];
lcp_mod = [lcp_mod mean(flexMod_lcp)];
lcp_err = [lcp_err std(flexMod_lcp)];
flex_mod = [flex_mod mean(flexMod)];
flex_err = [flex_err std(flexMod)];

pc_LME0 = pc_mod(1:4);
pc_LME1 = pc_mod(5:8);
pc_LME2 = pc_mod(9:12);

pc_LME0_err = pc_err(1:4);
pc_LME1_err = pc_err(5:8);
pc_LME2_err = pc_err(9:12);

lcp_LME0 = lcp_mod(1:4);
lcp_LME1 = lcp_mod(5:8);
lcp_LME2 = lcp_mod(9:12);

lcp_LME0_err = lcp_err(1:4);
lcp_LME1_err = lcp_err(5:8);
lcp_LME2_err = lcp_err(9:12);

flex_LME0 = flex_mod(1:4);
flex_LME1 = flex_mod(5:8);
flex_LME2 = flex_mod(9:12);

flex_LME0_err = flex_err(1:4);
flex_LME1_err = flex_err(5:8);
flex_LME2_err = flex_err(9:12);

% figure()
% plot([25 50 75 100],pc_LME0,'s-');hold on
% plot([25 50 75 100],pc_LME1,'s-');hold on
% plot([25 50 75 100],pc_LME2,'s-');hold on

% figure()
% plot([25 50 75 100],lcp_LME0,'s-');hold on
% plot([25 50 75 100],lcp_LME1,'s-');hold on
% plot([25 50 75 100],lcp_LME2,'s-');hold on

% figure()
% plot([25 50 75 100],flex_LME0,'s-');hold on
% plot([25 50 75 100],flex_LME1,'s-');hold on
% plot([25 50 75 100],flex_LME2,'s-');hold on

figure()
errorbar([25 50 75 100],pc_LME0/1e9,pc_LME0_err/1e9,'k-');hold on
errorbar([25 50 75 100],pc_LME1/1e9,pc_LME1_err/1e9,'r-');hold on
errorbar([25 50 75 100],pc_LME2/1e9,pc_LME2_err/1e9,'b-');hold on
grid on
legend('no LME','1 LME','2 LME')

figure()
errorbar([25 50 75 100],lcp_LME0/1e9,lcp_LME0_err/1e9);hold on
errorbar([25 50 75 100],lcp_LME1/1e9,lcp_LME1_err/1e9);hold on
errorbar([25 50 75 100],lcp_LME2/1e9,lcp_LME2_err/1e9);hold on
grid on
legend('no LME','1 LME','2 LME')

figure()
errorbar([25 50 75 100],flex_LME0/1e9,flex_LME0_err/1e9);hold on
errorbar([25 50 75 100],flex_LME1/1e9,flex_LME1_err/1e9);hold on
errorbar([25 50 75 100],flex_LME2/1e9,flex_LME2_err/1e9);hold on
grid on
legend('no LME','1 LME','2 LME')

load expData.mat

close all
figure()
% indx = [1 2 3 4];
for indx = 1:3
    scatter(flex_LME0(indx)/1e9,data(1,indx)/1e3);hold on
end

for indx = 1:3
    scatter(flex_LME1(indx)/1e9,data(2,indx)/1e3);hold on
end

for indx = 1:3
    scatter(flex_LME2(indx)/1e9,data(3,indx)/1e3);hold on
end
legend()
% axis equal
% plot([0.5,4.5],[0.5,4.5])


%%
clear
clc
close all

load comp_flex_storage.mat
load comp_flex_storage_2.mat
figure()
% indx = [1 2 3 4];
for indx = 1:3
    scatter(flex_LME0(indx)/1e9,data(1,indx)/1e3);hold on
end

for indx = 1:3
    scatter(flex_LME1(indx)/1e9,data(2,indx)/1e3);hold on
end

for indx = 1:3
    scatter(flex_LME2(indx)/1e9,data(3,indx)/1e3);hold on
end
legend()


figure('units','pixel','position',[100, 100, 800, 600])
errorbar([25 50 75 100],flex_LME0/1e9,flex_LME0_err/1e9,'-','linewidth',2.5,'color','#000000');hold on
errorbar([25 50 75 100],flex_LME1/1e9,flex_LME1_err/1e9,'-','linewidth',2.5,'color','#FF0000');hold on
errorbar([25 50 75 100],flex_LME2/1e9,flex_LME2_err/1e9,'-','linewidth',2.5,'color','#0000FF');hold on
plot(exp2(:,1),exp2(:,2),'-s','linewidth',2.5,'color','#892ade','markersize',12,...
    'markeredgecolor','#892ade');hold on;
grid on
lgd = legend('no LME','1 LME','2 LME','Kalkar et al.');
lgd.FontName = 'Times New Roman';
lgd.FontSize = 20;
lgd.Location = 'northwest';
xlabel('LCP mass fraction (%)')
ylabel('Flexural modulus (GPa)')
ax = gca;
ax.FontName = 'Times New Roman';
ax.FontSize = 20;
% title('PC/LCP (50/50)')
xlim([0 100])
ylim([1.5 4.0])
xticks([0 20 45 60 80 100])
yticks([1.5 2 2.5 3 3.5 4])
grid on

set(gcf,'PaperUnits','inches');
set(gcf,'PaperPosition',[0 0 8 6]);   % width 8 in, height 6 in
set(gcf,'PaperSize',[8 6]);
print(gcf,'-depsc','-vector','-r600','flex_mod_wErrBar.eps')
%%
clear
clc
close all

figure()
load('LME0_050_cs.mat');
plot(cs,flexMod_pc,'o-');hold on
load('LME1_050_cs.mat');
plot(cs,flexMod_pc,'o-');hold on
load('LME2_050_cs.mat');
plot(cs,flexMod_pc,'o-');hold on
legend('LME 0','LME 1','LME 2')
grid on
title('flexural modulus of PC')

figure()
load('LME0_050_cs.mat');
plot(cs,flexMod,'o-');hold on
load('LME1_050_cs.mat');
plot(cs,flexMod,'o-');hold on
load('LME2_050_cs.mat');
plot(cs,flexMod,'o-');hold on
legend('LME 0','LME 1','LME 2')
grid on
title('flexural modulus')

figure()
load('LME0_050_cs.mat');
plot(cs,Svoid./(St+Svoid)*100,'o-');hold on
load('LME1_050_cs.mat');
plot(cs,Svoid./(St+Svoid)*100,'o-');hold on
load('LME2_050_cs.mat');
plot(cs,Svoid./(St+Svoid)*100,'o-');hold on
legend('LME 0','LME 1','LME 2')
grid on
title('void fraction')

figure()
load('LME0_050_cs.mat');
plot(cs,bendModuli(:,5)./bendModuli(:,4),'o-');hold on
load('LME1_050_cs.mat');
plot(cs,bendModuli(:,5)./bendModuli(:,4),'o-');hold on
load('LME2_050_cs.mat');
plot(cs,bendModuli(:,5)./bendModuli(:,4),'o-');hold on
legend('LME 0','LME 1','LME 2')
grid on
title('Momentum related to voids')

%%
close all
figure()
load('LME0_075_cs.mat');
plot(cs,flexMod,'o-');hold on
load('LME1_075_cs.mat');
plot(cs,flexMod,'o-');hold on
load('LME2_075_cs.mat');
plot(cs,flexMod,'o-');hold on
legend('LME 0','LME 1','LME 2')
grid on
title('flexural modulus')

figure()
load('LME0_075_cs.mat');
plot(cs,flexMod_modified,'o-');hold on
load('LME1_075_cs.mat');
plot(cs,flexMod_modified,'o-');hold on
load('LME2_075_cs.mat');
plot(cs,flexMod_modified,'o-');hold on
legend('LME 0','LME 1','LME 2')
grid on
title('modified flexural modulus')

figure()
load('LME0_075_cs.mat');
plot(cs,flexMod_lcp,'o-');hold on
load('LME1_075_cs.mat');
plot(cs,flexMod_lcp,'o-');hold on
load('LME2_075_cs.mat');
plot(cs,flexMod_lcp,'o-');hold on
legend('LME 0','LME 1','LME 2')
grid on
title('flexural modulus of LCP')

figure()
load('LME0_075_cs.mat');
plot(cs,flexMod_pc,'o-');hold on
load('LME1_075_cs.mat');
plot(cs,flexMod_pc,'o-');hold on
load('LME2_075_cs.mat');
plot(cs,flexMod_pc,'o-');hold on
legend('LME 0','LME 1','LME 2')
grid on
title('flexural modulus of PC')

figure()
load('LME0_050_cs.mat');
plot(cs,Svoid./(St+Svoid)*100,'o-');hold on
load('LME1_050_cs.mat');
plot(cs,Svoid./(St+Svoid)*100,'o-');hold on
load('LME2_050_cs.mat');
plot(cs,Svoid./(St+Svoid)*100,'o-');hold on
legend('LME 0','LME 1','LME 2')
grid on
title('void fraction')

figure()
load('LME0_075_cs.mat');
plot(cs,bendModuli(:,5)./bendModuli(:,4),'o-');hold on
load('LME1_075_cs.mat');
plot(cs,bendModuli(:,5)./bendModuli(:,4),'o-');hold on
load('LME2_075_cs.mat');
plot(cs,bendModuli(:,5)./bendModuli(:,4),'o-');hold on
legend('LME 0','LME 1','LME 2')
grid on
title('Momentum related to voids')