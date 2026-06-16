function pic_new = detec_void(pic,edge)

[n1,n2] = size(pic);
Atotal = 0;
Avoid = 0;
ALCP = 0;
APC = 0;
pic_new = pic;

for i = 1:n1
    for j = 1:n2

        if pic(i,j) == 2  % LCP
            Atotal = Atotal + 1;
            ALCP = ALCP + 1;
        elseif pic(i,j) == 3  % PC
            Atotal = Atotal + 1;
            APC = APC+ 1;
        elseif pic(i,j) == 1  % air
            if edge(i,j) == 1
                continue
            else
                % initialize counter for cross number algorithm

                counter = 0;
                for k = i:n1-1
                    if (edge(k,j) == 0) && (edge(k+1,j) == 1)
                        left = k+1;
                        for m = k+1:n1-1
                            if (edge(m,j)==1) && (edge(m+1,j)==0)
                                right = m;
                            end
                        end
                    end
                end

                tem = edge(left:right,j);
                sta = sum(tem);


                if left == right
                    counter = counter + 0;
                elseif sta == 2      % real edge
                    counter = counter + 1;
                elseif sta == (right-left+1)
                   counter = counter + 0;
                end


                if ((-1)^counter == -1)  % counter is an odd number - void
                    Atotal = Atotal + 1;
                    Avoid = Avoid + 1;
                    pic_new(i,j) = 4;       % make fourth feature
                end
            end
        else
            error('wrong image!');
        end

    end
end
end