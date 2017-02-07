function [lines_list, lines_len_list] = get_line_indices_decomposed(line_indices)
% This function decompose a line, which is an array of N by 2 integers. Go
% through every point, and find breaking points, and output a list of
% consecutive lines.
% 
% This function belongs to CRBQA matlab package developed by ]
%   Tian Linger Xu, txu@indiana.edu

% determine whether all the points are on a vertical, horizontal or
% diagonal lines
if isempty(line_indices)
    warning('The input is empty.');
    lines_list = {};
    lines_len_list = [];
    return
end

x_unique = unique(line_indices(:,1));
y_unique = unique(line_indices(:,2));

if length(x_unique) == 1
    decompose_column = 2;
elseif length(y_unique) == 1
%     is_horizontal = true;
    decompose_column = 1;
else
    % only diagnal points are on one line
    decompose_column = 1;
% else
%     error('This function only work with points fall on one line');
end

decompose_indices = line_indices(:, decompose_column);
[~, sort_idx] = sort(decompose_indices);
line_indices = line_indices(sort_idx, :);

counter_lines = 0;
lines_list = {};
lines_len_list = [];

% When time diff has a jump that's larger than sample rate, we can
% determine that one continous line ended and another began
decompose_indices_interval = abs(decompose_indices(2:end) - decompose_indices(1:end-1));
new_line_start_idx = find(decompose_indices_interval > 1);
new_line_start_idx = [0; new_line_start_idx];

for nlidx = 2:length(new_line_start_idx)
    counter_lines = counter_lines + 1;
    line_one = line_indices((new_line_start_idx(nlidx-1)+1):new_line_start_idx(nlidx), :);
    lines_list{counter_lines} = line_one;
    lines_len_list = [lines_len_list; size(line_one, 1)];
end

counter_lines = counter_lines + 1;
line_one = line_indices(new_line_start_idx(end)+1:end, :);
lines_list{counter_lines} = line_one;
lines_len_list = [lines_len_list; size(line_one, 1)];

if sum(lines_len_list) ~= size(line_indices, 1)
    error('Decomposed lines len sum does not match with original line');
end