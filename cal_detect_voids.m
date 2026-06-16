function [pic_sig_new, Atotal, Avoid, ALCP, APC] = cal_detect_voids(pic_sig, outmost_edge)
% calculate void, PC and LCP fractions
% in segemented image pic_sig, 1: air, 2: LCP, 3:PC

% initialization
[n1, n2] = size(pic_sig);
Atotal = 0;
Avoid = 0;
ALCP = 0;
APC = 0;
pic_sig_new = pic_sig;

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
                counter_x = 0;
                for k = j:n2  % shoot ray in +x direction
                    if (outmost_edge(i,k) == 1) && (outmost_edge(i,k-1) == 0) % arrive edge
                        counter_x = counter_x + 1;
                    end
                end

                counter_y = 0;
                for k = i:n1 % shoot ray in +y direction
                    if (outmost_edge(k,j) == 1) && (outmost_edge(k-1,j) == 0) % arrive edge
                        counter_y = counter_y + 1;
                    end
                end

                counter_x_back = 0;
                for k = 1:j-1  % shoot ray in -x direction
                    if (outmost_edge(i,k) == 1) && (outmost_edge(i,k-1) == 0) % arrive edge
                        counter_x_back = counter_x_back + 1;
                    end
                end

                counter_y_back = 0;
                for k = 1:i-1 % shoot ray in -y direction
                    if (outmost_edge(k,j) == 1) && (outmost_edge(k-1,j) == 0) % arrive edge
                        counter_y_back = counter_y_back + 1;
                    end
                end

                if ((-1)^counter_x == -1) && ((-1)^counter_y == -1) &&...
                   ((-1)^counter_x_back == -1) && ((-1)^counter_y_back == -1)   % counter is an odd number - void
                    Atotal = Atotal + 1;
                    Avoid = Avoid + 1;
                    pic_sig_new(i,j) = 4;       % make fourth feature
                end
            end
        else
            error('wrong image!');
        end
    end
end
end