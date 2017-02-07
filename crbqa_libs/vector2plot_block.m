function [plot_x, plot_y] = vector2plot_block(vector)
% This function transforms recurrence block in vector form 
%   <x_start, x_end, y_start, y_end, category_value>
% into a two array with length 4, including 4 corners of CRB
% <bottom left, top left, top right, bottom right>
% which is the data structure for plotting CRB in visualization

% <bottom left, top left, top right, bottom right>
% For plotting purposes, we include one side of edge on x-axis and y-axis
plot_x = [vector(1)   vector(1)         vector(2)+1  vector(2)+1];
plot_y = [vector(3)   vector(4)+1	 vector(4)+1  vector(3)];