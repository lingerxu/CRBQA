function dist_list = calc_dist_line2block(line_indices_list, recur_block)
% This function gets

dist_list = nan(length(line_indices_list), 1);
range_x = [recur_block(1) recur_block(2)];
range_y = [recur_block(3) recur_block(4)];

for lidx = 1:length(line_indices_list)
    line_one = line_indices_list{lidx};
    xmin_line = min(line_one(:,1));
    xmax_line = max(line_one(:,1));
    ymin_line = min(line_one(:,2));
    ymax_line = max(line_one(:,2));
    
    maxminx = max([xmin_line range_x(1)]);
    minmaxx = min([xmax_line range_x(2)]);
    overlap_x = minmaxx - maxminx;

    maxminy = max([ymin_line range_y(1)]);
    minmaxy = min([ymax_line range_y(2)]);
    overlap_y = minmaxy - maxminy;

    if overlap_x > 0 % if there is overlap
        xmin_dist = 0;
    else
        xmin_dist = -(overlap_x);
    end

    if overlap_y > 0 % if there is overlap
        ymin_dist = 0;
    else
        ymin_dist = -(overlap_y);
    end
    
    dist_list(lidx) = max(xmin_dist, ymin_dist);
end