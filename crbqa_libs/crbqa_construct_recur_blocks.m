function [recur_block_vectors, category_list] = crbqa_construct_recur_blocks(x_data_list, y_data_list, category_list, null_value)
% CRBQA stands for Cross Recurrence Block Quantification Analysis. This
% function receives two array of categorical/nominal data, and construct a 
% Cross Recurrenc plot, consiting a list of Cross Recurrence Blocks.
% 
% INPUT:
%	x_data_list: a N by D matrix consisting of integers, which will be 
%       the data on the x-axis of the constructed Cross Recurrence Plot. 
%       N is the length of the time series, the number of observarions collected; 
%       D is the dimension of data input source.
%	y_data_list: a M by K matrix consisting of integers, which will be
%       the data on the y-axis of the constructed Cross Recurrence Plot.
%       M is the length of the time series, the number of observarions collected; 
%       K is the dimension of data input source.
%   category_list: interested categories where two system match based
%       on data input.
%   null_value: set all other values to a null value; default value is -99.
% 
% OUTPUT:
%   recur_block_vectors: In the output, each Cross Recurrence Block will be
%       stored as a vector of five numbers:
%       <x_start, x_end, y_start, y_end, category_value/ROI>
%       x_start, x_end, y_start, y_end will be integers representing the index
%       number from x_data_list, and y_data_list - the index of time stamp that
%       the state match between two systems starts
% 
% Cross Recurrence Block based Quantification Analysis (CRBQA) matlab package
% developed by Tian Linger Xu, txu@indiana.edu
% Last updated: Feb. 6, 2017

BVECTOR_LEN = 5;
 [len_x, dim_x, x_data_list] = format_inputdata(x_data_list);
 [len_y, dim_y, y_data_list] = format_inputdata(y_data_list);

num_categories = length(category_list);

for index_cat = 1:num_categories
    cat_one = category_list(index_cat);
    tmp_residue = cat_one - floor(cat_one);
    if tmp_residue > eps
        error('Categorical values have to be integers, %d is not a valid input.\n', cat_one);
    end
end
if nargin < 4
    null_value = -99;
end

mask_x = ismember(x_data_list, category_list);
mask_y = ismember(y_data_list, category_list);
x_data_list(~mask_x) = null_value;
y_data_list(~mask_y) = null_value;

% Start construct Cross Recurrence Block
recur_block_counter = 0;
% each vector represents one block <x_start, x_end, y_start, y_end, category value>
recur_block_vectors = nan(0, BVECTOR_LEN);
recur_block_cat_value = [];
recur_block_max_y = [];

for catidx = 1:num_categories
    recur_point_list{catidx} = [];
end

x_index_list = 1:len_x;
y_index_list = 1:len_y;

% The final output can still be visualized as a two dimensional plot as the
% traditional CRP, but every point in the plot can have multiple match
% values.
for index_y = 1:len_y
    cat_row = unique(y_data_list(index_y, :));
    cat_row = cat_row(cat_row ~= null_value);

    if isempty(cat_row)
        continue
    end

    for index_cat = 1:length(cat_row)
        cat_point = cat_row(index_cat);
        
        x_joint_row = abs(x_data_list - cat_point) < eps;
        x_joint_row = sum(x_joint_row, 2);
        x_tmp = x_joint_row > 0;
        num_points = sum(x_tmp);

        if num_points < 1
            continue
        end

        point_list_one = [x_index_list(x_tmp)' repmat(index_y, num_points, 1)];
%         recur_point_list{cat_point} = [recur_point_list{cat_point}; point_list_one];

        % when there is still unassigned lines
        % Search if there is an exisiting block that this recurrence match
        % point can be merged into
        poss_block_cat_mask = recur_block_cat_value == cat_point;
        poss_block_index_mask = index_y <= (recur_block_max_y + 1);
        poss_block_mask = poss_block_cat_mask & poss_block_index_mask;
        poss_block_idx_list = find(poss_block_mask);

        [decomposed_line_list, lines_len_list] = get_line_indices_decomposed(point_list_one);
        
        unassigned_mask = true(length(decomposed_line_list), 1);            

        % go through all the existing boxes, see if the points
        % belong to certain block
        for bidx = 1:length(poss_block_idx_list)
            block_one = recur_block_vectors(poss_block_idx_list(bidx), 1:4);
            unassigned_lines_one = decomposed_line_list(unassigned_mask);

            dist_list_one = calc_dist_line2block(unassigned_lines_one, block_one);

            mask_adjacent_lines = dist_list_one < 1+eps;
            num_adjacent_lines = sum(mask_adjacent_lines);
            if num_adjacent_lines > 0
                adjacent_points_one = vertcat(unassigned_lines_one{mask_adjacent_lines});
                tmp_x_list = [block_one(1); block_one(2); adjacent_points_one(:,1)];
                tmp_y_list = [block_one(3); block_one(3); adjacent_points_one(:,2)];
                new_block_one = [min(tmp_x_list) max(tmp_x_list) min(tmp_y_list) max(tmp_y_list)];

                recur_block_vectors(poss_block_idx_list(bidx), 1:4) = new_block_one;
                recur_block_max_y(poss_block_idx_list(bidx)) = new_block_one(4);
                unassigned_mask(unassigned_mask) = ~mask_adjacent_lines;
            end
        end

        % if there are lines left unassigned, meaning they will be the start
        % lines of new recur blocks
        if sum(unassigned_mask) > 0
            unassigned_lines_one = decomposed_line_list(unassigned_mask);

            for dlidx = 1:length(unassigned_lines_one)
                line_one = unassigned_lines_one{dlidx};
                new_block_x = [min(line_one(:,1)) max(line_one(:,1))];

                recur_block_counter = recur_block_counter + 1;
                recur_block_vectors(recur_block_counter, 1:4) = [new_block_x index_y index_y];
                recur_block_max_y(recur_block_counter) = index_y;
                recur_block_cat_value(recur_block_counter) = cat_point;
            end
        end
    end % end of one categorical value one round of comparison (a y point with all x data)
end % end of one round of comparison (a y point with all x data)

recur_block_vectors(:, 5) = recur_block_cat_value';