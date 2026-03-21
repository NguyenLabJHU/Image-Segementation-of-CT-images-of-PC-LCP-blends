function [yc_index,Ilcp,Itotal, Slcp,Svoid, Stotal] = cal_neutralAxis_lcp(testIM,Elcp,Epc)
% calculate location of neutral axis for given cross-section image
% rotation - rotation angle
% Elcp, Epc - moduli
% h - resolution (pixel size)

% % rotata image if necessary
% rotation = -110;
% testIM = imrotate(testIM,rotation);

Stotal = 0;
Slcp = 0;
Spc = 0;
Svoid = 0;

Int_lcp = 0;
Int_pc = 0;

[n1,n2] = size(testIM);
% da = h^2;

% loop over all pixels
% intensity
% 4 - void, 3 - pc, 2 - lcp
for i = 1:n1
    for j = 1:n2
        % read pixel
        ptem = testIM(i,j);

        % check intensity
        if ptem == 2 % lcp
            Stotal = Stotal + 1;
            Slcp = Slcp + 1;
            Int_lcp = Int_lcp + Elcp*i;

        elseif ptem == 3 % pc
            Stotal = Stotal + 1;
            Spc = Spc + 1;
            Int_pc = Int_pc + Epc*i;

        elseif ptem == 4
            Svoid = Svoid + 1;

        elseif ptem == 0 % void
            continue;
        else
            error('invalid intensity!');
        end
    end
end
yc_index = round((Int_lcp + Int_pc) / (Elcp*Slcp + Epc*Spc));

% calculate momentum
Iz = 0;
Ilcp = 0;
Ipc = 0;
Itotal = 0;

% loop over all pixels
for i = 1:n1
    for j = 1:n2
        ptem = testIM(i,j);

        % calculate effective momentum
        if ptem ~= 0 % it's a real feature
            Itotal = Itotal + (i-yc_index)^2;
        end

        if ptem == 2 % lcp
            Ilcp = Ilcp + Elcp*(i-yc_index)^2;
        elseif ptem == 3% pc
            Ipc = Ipc + Epc*(i-yc_index)^2;
        elseif (ptem == 4) || (ptem == 0) % air
            continue
        end
    end
end
Iz = Ilcp + Ipc;
end