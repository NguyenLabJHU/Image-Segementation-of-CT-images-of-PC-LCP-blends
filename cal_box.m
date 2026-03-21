function [upper,lower,left,right] = cal_box(ex_im)
% find the box that contains all non-zero feature in the image

[n1,n2] = size(ex_im);
upper = 0;
lower = 0;
left = 0;
right = 0;

% find upper limit
for i = 1:n1
    row_tem = ex_im(i,:);
    res = find(row_tem ~= 0);
    if ~isempty(res)
        upper = i;
        break;
    end
end

% find lower limit
for i = 1:n1
    row_tem = ex_im(n1+1-i,:);
    res = find(row_tem ~= 0);
    if ~isempty(res)
        lower = n1+1-i;
        break;
    end
end

% find left limit
for i = 1:n2
    row_tem = ex_im(:,i);
    res = find(row_tem ~= 0);
    if ~isempty(res)
        left = i;
        break;
    end
end

% find right limit
for i = 1:n2
    row_tem = ex_im(:,n2+1-i);
    res = find(row_tem ~= 0);
    if ~isempty(res)
        right = n2+1-i;
        break;
    end
end
 
end