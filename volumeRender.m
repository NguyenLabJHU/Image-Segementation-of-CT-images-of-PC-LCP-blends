function [PC, LCP, Blend, Void, vol, vlcp, vpc, vvoid] = volumeRender(filename, initialSlice, sliceNumber, volRatio, matflag, cfeature, pflag)

% determine dimension of image
tem = strcat(filename,'slice00000.tif');
pic0 = imread(tem);
[n1,n2] = size(pic0);

% initialization
PC = zeros(n1,n2,sliceNumber);
LCP = PC;
Blend = PC;
Void = PC;

vol = 0;
vpc = 0;
vlcp = 0;
vvoid = 0;

for i=1:sliceNumber
    j = initialSlice + i;
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

    % apply a filter
    % pictem = imgaussfilt(pictem,2);

    % determine background and range
    [x1,x2,background] = cal_background(pictem,cfeature, pflag);
    Upperlimit = x2;

    pictem(pictem<=background) = 0;
    
    % pictem = imadjust(pictem,[],[],2);
    % pictem = adapthisteq(pictem,'cliplimit',0.1,'numtiles',[2,2],'distribution','exponential');

    if matflag == 1  % it's pure material
        blend = imquantize(pictem,background);
    else
        threshold = SegBYmass(pictem, volRatio, background, Upperlimit);

        blend = imquantize(pictem,[background, threshold]);
        % flip PC and LCP
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
        % now we have air(1), LCP(2), PC(3)
    end

    % detect the outmost edge
    edgetem = imfill(blend);
    outmost_edge = edge(edgetem);

    % detect voids and calculate relavant fractions
    [blend_new,Atotal, Avoid, ALCP, APC] = cal_detect_voids(blend, outmost_edge);
    vol = vol + Atotal;
    vlcp = vlcp + ALCP;
    vpc = vpc + APC;
    vvoid = vvoid + Avoid;

    blend_new(blend_new==1) = 0;
    pc = blend_new;
    lcp = blend_new;
    void = blend_new;

    pc(pc==3) = 1;
    pc(pc==2) = 0;
    pc(pc==4) = 0;

    lcp(lcp==2) = 1;
    lcp(lcp==3) = 0;
    lcp(lcp==4) = 0;

    void(void==4) = 1;
    void(void==2) = 0;
    void(void==3) = 0;

    % vpc = vpc + sum(sum(pc));
    % vlcp = vlcp + sum(sum(lcp));
    PC(:,:,i) = pc;
    LCP(:,:,i) = lcp;
    Blend(:,:,i) = blend_new;
    Void(:,:,i) = void;
end

% vPC = volshow(PC);
% vLCP = volshow(LCP);
% vBlend = volshow(Blend);
% volratio = vpc/vlcp
end