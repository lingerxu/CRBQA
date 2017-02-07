function results = crbqa_calc_stats(block_list, stats_args)
% This function extract a suite of quantitative measures based on
% Cross Recurrence Blocks in vector form.
% Such as height, width, shape, start time diff, end time diff, etc
% 
% 
% Cross Recurrence Block based Quantification Analysis (CRBQA) matlab package
% developed by Tian Linger Xu, txu@indiana.edu
% Last updated: Feb. 6, 2017
% 
% check fileds in 'stats_args'
if ~exist('stats_args', 'var')
    % this line of code is just to prevent from generating errors when
    % script checks whether a certain field exists.
    stats_args.none_filed = 'No information here';
end

num_blocks = size(block_list, 1);

individual_start_point = nan(num_blocks, 2);
individual_end_point = nan(num_blocks, 2);
individual_center = nan(num_blocks, 2);
individual_height = nan(num_blocks, 1);
individual_width = nan(num_blocks, 1);
individual_overall_range = nan(num_blocks, 2);
% individual_overall_dur = nan(num_blocks, 1);
individual_area = nan(num_blocks, 1);
individual_width_height_ratio = nan(num_blocks, 1);
individual_vert_ratio = nan(num_blocks, 1);
individual_horz_ratio = nan(num_blocks, 1);
individual_start_diff = nan(num_blocks, 1);
individual_end_diff = nan(num_blocks, 1);
individual_abs_start_diff = nan(num_blocks, 1);
individual_abs_end_diff = nan(num_blocks, 1);
individual_xlead_corners = nan(num_blocks, 1);% meaning offsets are above the diag line

for bidx = 1:num_blocks
    block = block_list(bidx, :);
    
    xmin = block(1,1);
    xmax = block(1,2);
    ymin = block(1,3);
    ymax = block(1,4);
    
    individual_start_point(bidx, :) = [xmin ymin];
    individual_end_point(bidx, :) = [xmax ymax];
    center = [(xmin+xmax)/2 (ymin+ymax)/2];
    individual_center(bidx, :) = center;

    width = xmax - xmin + 1;
    height = ymax - ymin + 1;
    
    individual_height(bidx, :) = height;
    individual_width(bidx, :) = width;
    individual_area(bidx, :) = height * width;
    individual_overall_range(bidx, :) = [min(xmin, ymin) max(xmax, ymax)];
    width_height_ratio = width/height;
    individual_width_height_ratio(bidx, :) = width_height_ratio;
    if width_height_ratio > 1
        individual_horz_ratio(bidx, :) = width_height_ratio;
    elseif width_height_ratio < 1
        individual_vert_ratio(bidx, :) = height/width;
    end
    individual_start_diff(bidx, :) = xmin - ymin;
    individual_abs_start_diff(bidx, :) = abs(xmin - ymin);
    individual_end_diff(bidx, :) = xmax - ymax;
    individual_abs_end_diff(bidx, :) = abs(xmax - ymax);
    time_diff_one = block(:,1) - block(:,2);
    individual_xlead_corners(bidx, :) = sum(time_diff_one < 0);
end

results.num_blocks = num_blocks;
results.mean_height = mean(individual_height, 1);
results.median_height = median(individual_height, 1);
% results.range_height = [min(individual_height) max(individual_height)];

results.mean_width = mean(individual_width, 1);
results.median_width = median(individual_width, 1);
% results.range_width = [min(individual_width) max(individual_width)];

individual_overall_dur = individual_overall_range(:, 2) - individual_overall_range(:, 1);
% results.mean_overall_dur = mean(individual_overall_dur, 1);
% results.median_overall_dur = median(individual_overall_dur, 1);

% results.mean_area = mean(individual_area, 1);
% results.median_area = median(individual_area, 1);
% results.range_area = [min(individual_area) max(individual_area)];

results.mean_width_height_ratio = mean(individual_width_height_ratio, 1);
results.median_width_height_ratio = median(individual_width_height_ratio, 1);
% results.range_width_height_ratio = [min(individual_width_height_ratio) max(individual_width_height_ratio)];

mask_shape_vertical = individual_width_height_ratio < 1;   
results.num_vertical_block = sum(mask_shape_vertical);
results.mask_shape_vertical = mask_shape_vertical;
if results.num_vertical_block > 0
    tmp_vert_rate_block = individual_width_height_ratio(mask_shape_vertical);
    tmp_vert_rate_block = 1 ./ tmp_vert_rate_block;
    results.mean_ratio_vertical_block = mean(tmp_vert_rate_block, 1);
    results.median_ratio_vertical_block = median(tmp_vert_rate_block, 1);
    results.range_ratio_vertical_block = [min(tmp_vert_rate_block, 1) max(tmp_vert_rate_block, 1)];
else
    results.mean_ratio_vertical_block = NaN;
    results.median_ratio_vertical_block = NaN;
    results.range_ratio_vertical_block = [NaN NaN];
end

mask_shape_horizontal = individual_width_height_ratio > 1;
results.num_horizontal_block = sum(mask_shape_horizontal);
results.mask_shape_horizontal = mask_shape_horizontal;
if results.num_horizontal_block > 0
    results.mean_ratio_horizontal_block = mean(individual_width_height_ratio(mask_shape_horizontal), 1);
    results.median_ratio_horizontal_block = median(individual_width_height_ratio(mask_shape_horizontal), 1);
    results.range_ratio_horizontal_block = [min(individual_width_height_ratio(mask_shape_horizontal), 1) ...
        max(individual_width_height_ratio(mask_shape_horizontal), 1)];
else
    results.mean_ratio_horizontal_block = NaN;
    results.median_ratio_horizontal_block = NaN;
    results.range_ratio_horizontal_block = [NaN NaN];
end

results.mean_start_diff = mean(individual_start_diff, 1);
results.median_start_diff = median(individual_start_diff, 1);
results.range_start_diff = [min(individual_start_diff) max(individual_start_diff)];
results.mean_abs_start_diff = mean(individual_abs_start_diff, 1);
results.median_abs_start_diff = median(individual_abs_start_diff, 1);
results.range_abs_start_diff = [min(individual_abs_start_diff) max(individual_abs_start_diff)];
results.mean_end_diff = mean(individual_end_diff, 1);
results.median_end_diff = median(individual_end_diff, 1);
results.range_end_diff = [min(individual_end_diff) max(individual_end_diff)];
results.mean_abs_end_diff = mean(individual_abs_end_diff, 1);
results.median_abs_end_diff = median(individual_abs_end_diff, 1);
results.range_abs_end_diff = [min(individual_abs_end_diff) max(individual_abs_end_diff)];
% results.mean_xlead_corners = mean(individual_xlead_corners, 1);
% results.median_xlead_corners = median(individual_xlead_corners, 1);

results.individual_start_point = individual_start_point;
results.individual_end_point = individual_end_point;
results.individual_center = individual_center;
results.individual_height = individual_height;
results.individual_width = individual_width;
% results.individual_overall_range = individual_overall_range;
% results.individual_overall_dur = individual_overall_dur;
% results.individual_area = individual_area;
results.individual_width_height_ratio = individual_width_height_ratio;
results.individual_start_diff = individual_start_diff;
results.individual_end_diff = individual_end_diff;
results.individual_abs_start_diff = individual_abs_start_diff;
results.individual_end_diff = individual_end_diff;
results.individual_abs_end_diff = individual_abs_end_diff;