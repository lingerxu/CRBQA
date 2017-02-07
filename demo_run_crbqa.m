clear all;

addpath('crbqa_libs')
% Cross Recurrence Block based Quantification Analysis (CRBQA) matlab package
% developed by Tian Linger Xu, txu@indiana.edu
% Last updated: Feb. 6, 2017
% 
% Use help for more detailed comments in each function, e.g.
%   help crbqa_construct_recur_blocks
% 
% For more information regarding this method, please refer to this paper: 
%   http://www.indiana.edu/~dll/papers/xu_cogsci16.pdf
% 

% load nominal data streams on x-axis and y-axis of the CRP for
% constructing Cross Recurrence Blocks
load('crbqa_test_data.mat');

% define the interested categorical value set
category_list = [1 2 3 4];

fprintf('Starting constructing Cross Recurrence Blocks based on input data...\n')

% Call main function to generate the list of cross recurrence blocks based
% on 2 input data arrays.
% In output, each block is economically stored as a vector of five numbers:
% <x_start, x_end, y_start, y_end, category_value/ROI>
tic
[recur_block_vectors, category_list] = crbqa_construct_recur_blocks(x_data_list, y_data_list, category_list);
toc

% Visualize the results and input data 
plot_args.x_data_list = x_data_list;
plot_args.y_data_list = y_data_list;
plot_args.category_list = category_list;
% User can also save the figure as pngs by specifying a path
% plot_args.save_path = '.';
crbqa_visualize_blocks(recur_block_vectors, plot_args);

% Tally stats based on CRBs
stats = crbqa_calc_stats(recur_block_vectors)