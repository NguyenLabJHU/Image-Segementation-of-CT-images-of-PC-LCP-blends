function [th1,th2] = cal_crossection(g,h,mu)
% calculate crossection

% % NormalDistribution=@(x,mu,sigma,a)a*exp(-((x-mu)./sigma).^2);
% % x_fit= linspace(x1,x2,200);
% % y1_fit=NormalDistribution(x_fit,mu(1),sig(1),A(1));
% % y2_fit=NormalDistribution(x_fit,mu(2),sig(2),A(2));
% % y3_fit=NormalDistribution(x_fit,mu(3),sig(3),A(3));
% % y_fit = y1_fit+y2_fit+y3_fit;
% 
% 
% ND_1 = @(x)A(1)*exp(-((x-mu(1))./sig(1)).^2);
% ND_2 = @(x)A(2)*exp(-((x-mu(2))./sig(2)).^2);
% ND_3 = @(x)A(3)*exp(-((x-mu(3))./sig(3)).^2);
% 
% solhd1 = @(x)(A(1)*exp(-((x-mu(1))./sig(1)).^2)-A(2)*exp(-((x-mu(2))./sig(2)).^2));
% solhd2 = @(x)(A(2)*exp(-((x-mu(2))./sig(2)).^2)-A(3)*exp(-((x-mu(3))./sig(3)).^2));
% 
% fsolve(solhd1,0.5*x1+0.5*x2)
% % fsolve(ND_1,x1)

mu = round(mu);

index1 = find(g==mu(1));
index2 = find(g==mu(2));
index3 = find(g==mu(3));

temp1 = h(index1:index2);
temp2 = h(index2:index3);
[~,loc1] = min(temp1);
[~,loc2] = min(temp2);

tem1 = g(index1:index2);
tem2 = g(index2:index3);
th1 = tem1(loc1);
th2 = tem2(loc2);

% figure()
% plot(g,h,'r.');hold on
% plot([mu(1),mu(1)],[0,max(h)],'m--');hold on
% plot([mu(2),mu(2)],[0,max(h)],'m--');hold on
% plot([mu(3),mu(3)],[0,max(h)],'m--');hold on
% plot([th1,th1],[0,max(h)],'g-.');hold on
% plot([th2,th2],[0,max(h)],'g-.');hold on
end