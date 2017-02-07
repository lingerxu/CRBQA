function crbqa_visualize_blocks(block_list, plot_args)
% This function visualize the Cross Recurrence Plot based on a list of
% Cross Recurrence Blocks in vector form.
% <x_start, x_end, y_start, y_end, category_value/ROI>
% 
% Cross Recurrence Block based Quantification Analysis (CRBQA) matlab package
% developed by Tian Linger Xu, txu@indiana.edu
% Last updated: Feb. 6, 2017

if nargin < 2
    plot_args.no_info = 'no plotting parameters';
end

if isfield(plot_args, 'x_time') && isfield(plot_args, 'y_time')
    is_time = true;
    [len_x, ~, x_axis] = format_inputdata(plot_args.x_time);
    [len_y, ~, y_axis] = format_inputdata(plot_args.y_time);
    x_unit = x_axis(2)-x_axis(1);
    y_unit = y_axis(2)-y_axis(1);
    x_axis = [x_axis; x_axis(end)+x_unit];
    y_axis = [y_axis; y_axis(end)+y_unit];
else
    is_time = false;
    x_axis = 1;
    y_axis = 1;
    x_unit = 1;
    y_unit = 1;
end
if isfield(plot_args, 'x_data_list') && isfield(plot_args, 'y_data_list')
    is_plot_data = true;
    x_data_list = plot_args.x_data_list;
    y_data_list = plot_args.y_data_list;
else
    is_plot_data = false;
end
if ~isfield(plot_args, 'category_list')
    category_list = plot_args.category_list;
else
    category_list = unique(block_list(:, end));
end
if ~isfield(plot_args, 'is_visible')
    is_visible = true;
else
    is_visible = plot_args.is_visible;
end
if ~isfield(plot_args, 'set_position')
    plot_args.set_position = [50 50 1200 800];
end
if ~isfield(plot_args, 'colormap')
    colormap = { ...
        [0 0 1]; ... % blue
        [0 1 0]; ... % green
        [1 0 0]; ... % red
        [1 0 1]; ... % pink
        [1 1 0]; ... % yellow
        [0 0 1]; ... % blue
        [1 0 1]; ... % pink
        [1 0 0]; ... % red
        [0 1 1]; ... % cran
        [0 1 0]; ... % green
        [0 0 0]; ... % black
        [0 0 0.7]; ... % dark blue
        [0.7 0 0.7]; ... % purple
        [0 0.7 0.7]; ... % greenblue
        [0.7 0 0]; ... % dark red
        [0 0.7 0]; ... % dark greed
        [1 0.5 0.2] ... % orange
        };
else
    colormap = plot_args.colormap;
end
if ~isfield(plot_args, 'is_plot_diag')
    is_plot_diag = false;
else
    is_plot_diag = plot_args.is_plot_diag;
end
if ~isfield(plot_args, 'is_create_video')
    is_create_video = false;
else
    is_create_video = plot_args.is_create_video;
end
if is_visible && ~isfield(plot_args, 'save_path')
    h1 = figure('Position', plot_args.set_position); % 
else
    h1 = figure('Position', plot_args.set_position, 'Visible', 'off');
end
if isfield(plot_args, 'cevent_name') && ~isfield(plot_args, 'cevent_transparency')
    plot_args.cevent_transparency = 0.6;
end
if ~isfield(plot_args, 'recur_time_band_transparency')
    plot_args.recur_time_band_transparency = 0.2;
end

if is_time
    xlabel_str = 'X time';
    ylabel_str = 'Y time';
else
    xlabel_str = 'X data index';
    ylabel_str = 'Y data index';
end
if isfield(plot_args, 'x_data_label')
    xlabel_str = sprintf('%s (%s)', xlabel_str, plot_args.x_data_label);
end
if isfield(plot_args, 'y_data_label')
    ylabel_str = sprintf('%s (%s)', ylabel_str, plot_args.y_data_label);
end

if isfield(plot_args, 'title_str')
    title_str = plot_args.title_str;
else
    title_str = 'Cross Recurrece Block based Plot';
end
xlim_start = x_axis(1);
xlim_end = x_axis(end);
ylim_start = y_axis(1);
ylim_end = y_axis(end);

if is_plot_data
    subplot('Position', [0.2 0.2 0.75 0.75]);
end
hold on;

for bidx = 1:length(block_list)
    block_one = block_list(bidx, :);
    roi_one = block_one(end);
    roi_color_one = colormap{roi_one};
    
    [plot_x, plot_y] = vector2plot_block(block_one);
    
    if is_time
        plot_x = x_axis(plot_x);
        plot_y = y_axis(plot_y);
    end
    xlim_start = min(xlim_start, plot_x(1));
    xlim_end = max(xlim_end, plot_x(4));
    ylim_start = min(ylim_start, plot_y(1));
    ylim_end = max(ylim_end, plot_y(2));
    
    fill(plot_x, plot_y, roi_color_one, 'EdgeColor', 'none');
end

xlabel(xlabel_str);
ylabel(ylabel_str);

if isfield(plot_args, 'xlim_start')
    xlim_start = plot_args.xlim_start;
end
if isfield(plot_args, 'xlim_end')
    xlim_end = plot_args.xlim_end;
end
if isfield(plot_args, 'ylim_start')
    ylim_start = plot_args.ylim_start;
end
if isfield(plot_args, 'ylim_end')
    ylim_end = plot_args.ylim_end;
end
xlim_range = [xlim_start-x_unit xlim_end];
xlim(xlim_range);
ylim_range = [ylim_start-y_unit ylim_end];
ylim(ylim_range);

title(title_str)
hold off;
data_plot_width = 120;

if is_plot_data
    % plot data streams on x-axis
    h_datax = subplot('Position', [0.2 0.05 0.75 0.08]);
    x_intervals = stream2intervals(x_data_list, category_list);
    dim_x = length(x_intervals);
    plot_height = data_plot_width/dim_x;
    xlim(xlim_range);
    ylim([0 data_plot_width]);
    set(h_datax, 'XTick',[]);
    set(h_datax, 'YTick',[]);
    hold on;
    for dimidx = 1:dim_x
        intervals_one = x_intervals{dimidx};
        y_low = data_plot_width-dimidx*plot_height;
        y_up = y_low + plot_height+1;
        plot_y = [y_low y_up y_up y_low];
        for eidx = 1:size(intervals_one, 1)
            plot_x = [intervals_one(eidx, 1) intervals_one(eidx, 1) intervals_one(eidx, 2)+1 intervals_one(eidx, 2)+1];
            fill(plot_x, plot_y, colormap{intervals_one(eidx, 3)}, 'EdgeColor', 'none');
        end
    end
    hold off;
    xlabel(sprintf('%d input data streams on x-axis', dim_x));
    
    % plot data streams on y-axis
    h_datay = subplot('Position', [0.03 0.2 0.08 0.75]);
    y_intervals = stream2intervals(y_data_list, category_list);
    dim_y = length(y_intervals);
    plot_height = data_plot_width/dim_y;
    xlim([0 data_plot_width]);
    ylim(ylim_range);
    set(h_datay, 'XTick',[]);
    set(h_datay, 'YTick',[]);
    hold on;
    for dimidx = 1:dim_y
        intervals_one = y_intervals{dimidx};
        x_low = data_plot_width-dimidx*plot_height;
        x_up = x_low + plot_height+1;
        plot_x = [x_low x_low x_up x_up];
        for eidx = 1:size(intervals_one, 1)
            plot_y = [intervals_one(eidx, 1) intervals_one(eidx, 2)+1 intervals_one(eidx, 2)+1 intervals_one(eidx, 1)];
            fill(plot_x, plot_y, colormap{intervals_one(eidx, 3)}, 'EdgeColor', 'none');
        end
    end
    hold off;
    ylabel(sprintf('%d input data streams on y-axis', dim_y));
end

if isfield(plot_args, 'save_path')
    plot_savefile = fullfile(plot_args.save_path, [title_str '.png']);
    saveas(h1, plot_savefile);
    fprintf('Plot saved as %s.\n', plot_savefile);
    close(h1);
end