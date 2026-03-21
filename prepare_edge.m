function edge_new = prepare_edge(edge)

[n1, n2] = size(edge);
edge_tem = edge;

% get rid of egde wider than 3
for j = 1:n2
    for i = 2:n1-1
        status = [edge(i-1,j), edge(i,j), edge(i+1,j)];
        if sum(status == [1 1 1]) == 3
            edge_tem(i,j) = 0;
        end
    end
end
edge_new = edge_tem;

% get rid of egde wider than 2
% edge_new = edge_tem;
% for j = 1:n2
%     for i = 2:n1-1
%         status = [edge_tem(i-1,j), edge_tem(i,j), edge_tem(i+1,j)];
%         if sum(status == [1 1 0]) == 3
%             edge_new(i,j) = 0;
%         end
%     end
% end

end 