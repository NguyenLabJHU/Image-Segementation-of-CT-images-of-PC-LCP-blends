function [pic_sig_new, Atotal, Avoid, ALCP, APC] = cal_detect_voids_x(pic_sig, outmost_edge)
% calculate void, PC and LCP fractions
% in segemented image pic_sig, 1: air, 2: LCP, 3:PC

% initialization
[n1, n2] = size(pic_sig);
Atotal = 0;
Avoid = 0;
ALCP = 0;
APC = 0;
pic_sig_new = pic_sig;
edge_new = prepare_edge(outmost_edge);

% loop over all pixels
for i = 1:n1
    for j = 1:n2

        if pic_sig(i,j) == 2  % LCP
            Atotal = Atotal + 1;
            ALCP = ALCP + 1;
        elseif pic_sig(i,j) == 3  % PC
            Atotal = Atotal + 1;
            APC = APC+ 1;
        elseif pic_sig(i,j) == 1  % air
            if outmost_edge(i,j) == 1
                continue
            else
                % initialize counter for cross number algorithm

                counter = 0;
                for k = i+1:n1
                    if (edge_new(k,j) == 1) && (edge_new(k-1,j) == 0) % arrive edge
                        counter = counter + 1;
                    end
                end

                if ((-1)^counter == -1)  % counter is an odd number - void
                    Atotal = Atotal + 1;
                    Avoid = Avoid + 1;
                    pic_sig_new(i,j) = 20;       % make fourth feature
                end
            end
        else
            error('wrong image!');
        end
    end
end
end