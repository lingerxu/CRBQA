function result = crbqa_calc_stats(block_list, input)

% block_list = seb_list_crp;
% input = block_crp_input;

% check fileds in 'input'
if ~exist('input', 'var')
    % this line of code is just to prevent from generating errors when
    % script checks whether a certain field exists.
    input.none_filed = 'No information here';
end

x_sample_rate = input.x_sample_rate;
y_sample_rate = input.y_sample_rate;

if isfield(input, 'WIDTH_THRESH')
    [block_width, block_height] = get_block_width_height(block_list, x_sample_rate, y_sample_rate);
%     pause
    mask_filter_width = block_width > input.WIDTH_THRESH;
    mask_filter_height = block_height > input.WIDTH_THRESH;
    mask_filter = mask_filter_width & mask_filter_height;
    block_list = block_list(mask_filter);
    result.mask_filter = mask_filter;
%     joint_blocks_tex_density = joint_blocks_tex_density(mask_filter_height & mask_filter_width);
end

num_block = length(block_list);

if isfield(input, 'individual_range_dur_x')
    individual_range_dur_x = input.individual_range_dur_x;
    if isfield(input, 'WIDTH_THRESH')
        individual_range_dur_x = individual_range_dur_x(mask_filter);
    end
    
    if length(individual_range_dur_x) == 1
        individual_range_dur_x = repmat(individual_range_dur_x, 1, num_block);
    elseif num_block ~= length(individual_range_dur_x)
        error('Number of blockes should be equal with length of individual_range_dur_x')
    end
    individual_width_prop = nan(num_block, 1);
end

if isfield(input, 'individual_range_dur_y')
    individual_range_dur_y = input.individual_range_dur_y;
    if isfield(input, 'WIDTH_THRESH')
        individual_range_dur_y = individual_range_dur_y(mask_filter);
    end
    
    if length(input.individual_range_dur_y) == 1
        individual_range_dur_y = repmat(individual_range_dur_y, 1, num_block);
    elseif num_block ~= length(individual_range_dur_y)
        error('Number of blockes should be equal with length of individual_range_dur_y')
    end
    individual_height_prop = nan(num_block, 1);
end

individual_start_point = nan(num_block, 2);
individual_end_point = nan(num_block, 2);
individual_center = nan(num_block, 2);
individual_height = nan(num_block, 1);
individual_width = nan(num_block, 1);
individual_overall_range = nan(num_block, 2);
% individual_overall_dur = nan(num_block, 1);
individual_area = nan(num_block, 1);
individual_width_height_ratio = nan(num_block, 1);
individual_vert_ratio = nan(num_block, 1);
individual_horz_ratio = nan(num_block, 1);
individual_start_diff = nan(num_block, 1);
individual_end_diff = nan(num_block, 1);
individual_abs_start_diff = nan(num_block, 1);
individual_abs_end_diff = nan(num_block, 1);
individual_xlead_corners = nan(num_block, 1);% meaning offsets are above the diag line

for bidx = 1:num_block
    block = block_list{bidx};
    
    xmin = block(1,1);
    xmax = block(4,1);
    ymin = block(1,2);
    ymax = block(2,2);
    
    individual_start_point(bidx, :) = [xmin ymin];
    individual_end_point(bidx, :) = [xmax ymax];
    center = [(xmin+xmax)/2 (ymin+ymax)/2];
    individual_center(bidx, :) = center;

    width = xmax - xmin + x_sample_rate;
    height = ymax - ymin + y_sample_rate;

%     if height == 0
%         height = SAMPLE_RATE;
%     end
%     if width == 0
%         width = SAMPLE_RATE;
%     end
    
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
    
    if isfield(input, 'individual_range_dur_x')
        individual_width_prop(bidx, :) = width/individual_range_dur_x(bidx);
    end
    if isfield(input, 'individual_range_dur_y')
        individual_height_prop(bidx, :) = height/individual_range_dur_y(bidx);
    end
end

result.num_block = num_block;
result.mean_height = mean(individual_height, 1);
result.median_height = median(individual_height, 1);
result.range_height = [min(individual_height) max(individual_height)];
if isfield(input, 'individual_range_dur_y')
    result.mean_height_prop = mean(individual_height_prop, 1);
    result.median_height_prop = median(individual_height_prop, 1);
    result.range_height_prop = [min(individual_height_prop) max(individual_height_prop)];
end
result.mean_width = mean(individual_width, 1);
result.median_width = median(individual_width, 1);
result.range_width = [min(individual_width) max(individual_width)];
if isfield(input, 'individual_range_dur_x')
    result.mean_width_prop = mean(individual_width_prop, 1);
    result.median_width_prop = median(individual_width_prop, 1);
    result.range_width_prop = [min(individual_width_prop) max(individual_width_prop)];
end
individual_overall_dur = individual_overall_range(:, 2) - individual_overall_range(:, 1);
result.mean_overall_dur = mean(individual_overall_dur, 1);
result.median_overall_dur = median(individual_overall_dur, 1);
result.mean_area = mean(individual_area, 1);
result.median_area = median(individual_area, 1);
result.range_area = [min(individual_area) max(individual_area)];
result.mean_width_height_ratio = mean(individual_width_height_ratio, 1);
result.median_width_height_ratio = median(individual_width_height_ratio, 1);
result.range_width_height_ratio = [min(individual_width_height_ratio) max(individual_width_height_ratio)];

mask_shape_vertical = individual_width_height_ratio < 1;   
result.num_vertical_block = sum(mask_shape_vertical);
result.mask_shape_vertical = mask_shape_vertical;
if result.num_vertical_block > 0
    tmp_vert_rate_block = individual_width_height_ratio(mask_shape_vertical);
    tmp_vert_rate_block = 1 ./ tmp_vert_rate_block;
    result.mean_ratio_vertical_block = mean(tmp_vert_rate_block, 1);
    result.median_ratio_vertical_block = median(tmp_vert_rate_block, 1);
    result.range_ratio_vertical_block = [min(tmp_vert_rate_block, 1) max(tmp_vert_rate_block, 1)];
else
    result.mean_ratio_vertical_block = NaN;
    result.median_ratio_vertical_block = NaN;
    result.range_ratio_vertical_block = [NaN NaN];
end

mask_shape_horizontal = individual_width_height_ratio > 1;
result.num_horizontal_block = sum(mask_shape_horizontal);
result.mask_shape_horizontal = mask_shape_horizontal;
if result.num_horizontal_block > 0
    result.mean_ratio_horizontal_block = mean(individual_width_height_ratio(mask_shape_horizontal), 1);
    result.median_ratio_horizontal_block = median(individual_width_height_ratio(mask_shape_horizontal), 1);
    result.range_ratio_horizontal_block = [min(individual_width_height_ratio(mask_shape_horizontal), 1) ...
        max(individual_width_height_ratio(mask_shape_horizontal), 1)];
else
    result.mean_ratio_horizontal_block = NaN;
    result.median_ratio_horizontal_block = NaN;
    result.range_ratio_horizontal_block = [NaN NaN];
end

result.mean_start_diff = mean(individual_start_diff, 1);
result.median_start_diff = median(individual_start_diff, 1);
result.range_start_diff = [min(individual_start_diff) max(individual_start_diff)];
result.mean_abs_start_diff = mean(individual_abs_start_diff, 1);
result.median_abs_start_diff = median(individual_abs_start_diff, 1);
result.range_abs_start_diff = [min(individual_abs_start_diff) max(individual_abs_start_diff)];
result.mean_end_diff = mean(individual_end_diff, 1);
result.median_end_diff = median(individual_end_diff, 1);
result.range_end_diff = [min(individual_end_diff) max(individual_end_diff)];
result.mean_abs_end_diff = mean(individual_abs_end_diff, 1);
result.median_abs_end_diff = median(individual_abs_end_diff, 1);
result.range_abs_end_diff = [min(individual_abs_end_diff) max(individual_abs_end_diff)];
result.mean_xlead_corners = mean(individual_xlead_corners, 1);
result.median_xlead_corners = median(individual_xlead_corners, 1);

% vert time diff
result.vert_mean_start_diff = mean(individual_start_diff(mask_shape_vertical), 1);
result.vert_median_start_diff = median(individual_start_diff(mask_shape_vertical), 1);
result.vert_range_start_diff = [min(individual_start_diff(mask_shape_vertical)) max(individual_start_diff(mask_shape_vertical))];
result.vert_mean_abs_start_diff = mean(individual_abs_start_diff(mask_shape_vertical), 1);
result.vert_median_abs_start_diff = median(individual_abs_start_diff(mask_shape_vertical), 1);
result.vert_range_abs_start_diff = [min(individual_abs_start_diff(mask_shape_vertical)) max(individual_abs_start_diff(mask_shape_vertical))];
result.vert_mean_end_diff = mean(individual_end_diff(mask_shape_vertical), 1);
result.vert_median_end_diff = median(individual_end_diff(mask_shape_vertical), 1);
result.vert_range_end_diff = [min(individual_end_diff(mask_shape_vertical)) max(individual_end_diff(mask_shape_vertical))];
result.vert_mean_abs_end_diff = mean(individual_abs_end_diff(mask_shape_vertical), 1);
result.vert_median_abs_end_diff = median(individual_abs_end_diff(mask_shape_vertical), 1);
result.vert_range_abs_end_diff = [min(individual_abs_end_diff(mask_shape_vertical)) max(individual_abs_end_diff(mask_shape_vertical))];
% horz time diff
result.horz_mean_start_diff = mean(individual_start_diff(mask_shape_horizontal), 1);
result.horz_median_start_diff = median(individual_start_diff(mask_shape_horizontal), 1);
result.horz_range_start_diff = [min(individual_start_diff(mask_shape_horizontal)) max(individual_start_diff(mask_shape_horizontal))];
result.horz_mean_abs_start_diff = mean(individual_abs_start_diff(mask_shape_horizontal), 1);
result.horz_median_abs_start_diff = median(individual_abs_start_diff(mask_shape_horizontal), 1);
result.horz_range_abs_start_diff = [min(individual_abs_start_diff(mask_shape_horizontal)) max(individual_abs_start_diff(mask_shape_horizontal))];
result.horz_mean_end_diff = mean(individual_end_diff(mask_shape_horizontal), 1);
result.horz_median_end_diff = median(individual_end_diff(mask_shape_horizontal), 1);
result.horz_range_end_diff = [min(individual_end_diff(mask_shape_horizontal)) max(individual_end_diff(mask_shape_horizontal))];
result.horz_mean_abs_end_diff = mean(individual_abs_end_diff(mask_shape_horizontal), 1);
result.horz_median_abs_end_diff = median(individual_abs_end_diff(mask_shape_horizontal), 1);
result.horz_range_abs_end_diff = [min(individual_abs_end_diff(mask_shape_horizontal)) max(individual_abs_end_diff(mask_shape_horizontal))];

result.individual_start_point = individual_start_point;
result.individual_end_point = individual_end_point;
result.individual_center = individual_center;
result.individual_height = individual_height;
if isfield(input, 'individual_range_dur_x')
    result.individual_width_prop = individual_width_prop;
end
if isfield(input, 'individual_range_dur_y')
    result.individual_height_prop = individual_height_prop;
end
result.individual_width = individual_width;
result.individual_overall_range = individual_overall_range;
result.individual_overall_dur = individual_overall_dur;
result.individual_area = individual_area;
result.individual_width_height_ratio = individual_width_height_ratio;
result.individual_vert_ratio = individual_vert_ratio;
result.individual_horz_ratio = individual_horz_ratio;
result.individual_start_diff = individual_start_diff;
result.individual_end_diff = individual_end_diff;
result.individual_abs_start_diff = individual_abs_start_diff;
result.individual_end_diff = individual_end_diff;
result.individual_abs_end_diff = individual_abs_end_diff;
result.individual_xlead_corners = individual_xlead_corners;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% calculate texture of blocks if it is passed through block input argument
if isfield(input, 'is_cal_texture')
    is_cal_texture = input.is_cal_texture;
    if ~isfield(input, 'tex_blocks_list')
        error('For calculating textures of the blocks, the containing blocks should be filled in this field: tex_blocks_list.');
    end
    tex_blocks_list = input.tex_blocks_list;
    if isfield(input, 'WIDTH_THRESH')
        tex_blocks_list = tex_blocks_list(mask_filter);
    end
    if length(tex_blocks_list) ~= num_block
        error('The length of tex_blocks_list should be equal to the number of Sustained Engagement Blocks.')
    end
else
    is_cal_texture = false;
end

if is_cal_texture
    tex_area_list = nan(num_block, 1);
    tex_number_list = nan(num_block, 1);
    for tdidx = 1:num_block
        tmp_tex_area = cellfun( ...
            @(block_one) ...
            get_block_area(block_one, x_sample_rate, y_sample_rate), ...
            tex_blocks_list{tdidx}, ...
            'UniformOutput', 0);
        tex_area_list(tdidx) = sum(vertcat(tmp_tex_area{:}));
        tex_number_list(tdidx) = length(tex_blocks_list{tdidx});
    end
    result.individual_tex_block_area = tex_area_list;
    result.individual_density = tex_area_list ./ individual_area;
    result.individual_tex_number = tex_number_list;
    result.mean_density = nanmean(result.individual_density);
    result.overall_density = sum(tex_area_list) / sum(individual_area);
    result.mean_tex_number = nanmean(tex_number_list);
end