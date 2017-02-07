% function visualize_recur_blocks(block_list, plot_args)
block_list = recur_block_vectors;

% if nargin < 3
    plot_args.no_info = 'no iplox_xtting parameters';
% end

if isfield(plot_args, 'x_time') && isfield(plot_args, 'y_time')
    x_axis = plot_args.x_time;
    y_axis = plot_args.y_time;
    is_time = true;
    x_unit = x_axis(2)-x_axis(1);
    y_unit = y_axis(2)-y_axis(1);
else
    x_axis = 1;
    y_axis = 1;
    is_time = false;
    x_unit = 1;
    y_unit = 1;
end
if ~isfield(plot_args, 'is_visible')
    plot_args.is_visible = true;
end
if ~isfield(plot_args, 'set_position')
    plot_args.set_position = [100 100 1200 800];
end
if ~isfield(plot_args, 'colormap')
    plot_args.colormap = { ...
        [0 0 1]; ... % blue
        [0 1 0]; ... % green
        [1 0 0]; ... % red
        [1 0 1]; ... % pink
        [1 0 0]; ... % red
        [1 0 1]; ... % pink
        };
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
if isfield(plot_args, 'is_visible')
    if plot_args.is_visible
        h1 = figure('Position', plot_args.set_position); % 
    else
        h1 = figure('Position', plot_args.set_position, 'Visible', 'off');
    end
else
    h1 = figure('Position', plot_args.set_position);
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
xlim_start = 1;
xlim_end = 1;
ylim_start = 1;
ylim_end = 1;

sub_plot(2, 2, 2);

hold on;

if isfield(plot_args, 'recur_time_band') && isfield(plot_args, 'is_plot_timeband') && plot_args.is_plot_timeband
%     plot(x_axis, y_axis+plot_args.recur_time_band(1), '-k');
%     plot(x_axis, y_axis+plot_args.recur_time_band(2), '-k');
    
    prev_band_offset = -plot_args.recur_time_band(1);
    prev_plot_box_x = [time_ref_begin time_ref_begin ...
     (time_ref_end-prev_band_offset) time_ref_end];
    prev_plot_box_y = [time_ref_begin (time_ref_begin+prev_band_offset) ...
        time_ref_end time_ref_end];
%     prev_plot_box_x
%     prev_plot_box_y
    fx = fill(prev_plot_box_x, prev_plot_box_y, 'r', 'EdgeColor', 'none');
    %         set(fx,'EdgeColor','r')

    next_band_offset = plot_args.recur_time_band(2);
    next_plot_box_x = [time_ref_begin time_ref_end  ...
     time_ref_end (time_ref_begin+next_band_offset)];
    next_plot_box_y = [time_ref_begin time_ref_end ...
        (time_ref_end-next_band_offset) time_ref_begin];
    fy = fill(next_plot_box_x, next_plot_box_y, 'r', 'EdgeColor', 'none');
    %         set(fy,'EdgeColor','r')

    alpha(fx, plot_args.recur_time_band_transparency);
    alpha(fy, plot_args.recur_time_band_transparency);
end

for bidx = 1:length(block_list)
    block_one = block_list(bidx, :);
    roi_one = block_one(end);
    roi_color_one = plot_args.colormap{roi_one};
    
    [plot_x, plot_y] = vector2plot_block(block_one);
    
    if is_time
        plot_x = x_time(plot_x);
        plot_y = y_time(plot_y);
    end
    xlim_start = min(xlim_start, plot_x(1));
    xlim_end = max(xlim_end, plot_x(4));
    ylim_start = min(ylim_start, plot_y(1));
    ylim_end = max(ylim_end, plot_y(2));
    
    fill(plot_x, plot_y, roi_color_one, 'EdgeColor', 'none');
end

if isfield(plot_args, 'sust_engage_blocks')
    sust_engage_blocks = plot_args.sust_engage_blocks;
    sust_engage_cvalue = plot_args.sust_engage_cvalue;
    
    for sebidx = 1:length(sust_engage_blocks)
        block_one = sust_engage_blocks{sebidx};
        roi_one = sust_engage_cvalue(sebidx);
        roi_color_one = plot_args.colormap{roi_one};
        new_joint_block_x = block_one(:,1)';
        new_joint_block_y = block_one(:,2)';
        seb_x = [new_joint_block_x new_joint_block_x(1)];
        seb_y = [new_joint_block_y new_joint_block_y(1)];

        plot(seb_x, seb_y, 'Color', roi_color_one, 'LineWidth', 1);
    %         if plot_args.is_plot_text
    %             text(block_one(4,1), block_one(2,2), num2str(sebidx), 'FontSize', 5); 
    %         end
    end
end

if isfield(plot_args, 'cevent_data')
    cevent_data_one = plot_args.cevent_data{gidx};
    num_cevent_data = size(cevent_data_one, 1);
    plot_args.title_str = sprintf('%s with %s', title_str_start, plot_args.cevent_module);

    for ceidx = 1:num_cevent_data
        cevent_one = cevent_data_one(ceidx, :);
        roi_color_one = plot_args.colormap{cevent_one(1,3)};

        cevent_block_x = [cevent_one(1,1) cevent_one(1,1) cevent_one(1,2) cevent_one(1,2)];
        cevent_block_y = [cevent_one(1,1) cevent_one(1,2) cevent_one(1,2) cevent_one(1,1)];
        rect = fill(cevent_block_x, cevent_block_y, roi_color_one, 'EdgeColor', 'k'); %roi_color_one, , 
        alpha(rect, plot_args.cevent_transparency);

%             text(cevent_one(1,2), cevent_one(1,2), [plot_args.cevent_module int2str(ceidx)], 'Color', 'k', 'FontSize', 6);
        text(cevent_one(1,2), cevent_one(1,1), int2str(ceidx), 'Color', 'k', 'FontSize', 8, 'FontWeight', 'bold');
    end
    title(sprintf('x-%s y-%s with %d %s', plot_args.x_data_label, plot_args.y_data_label, num_cevent_data, plot_args.cevent_module));  
end
% 
% if is_create_video
%     frame_list = plot_args.frame_list;
%     sub_id = plot_args.sub_id;
%     
%     xlim([xlim_start xlim_end]);
%     ylim([ylim_start ylim_end]);
%         
%     for fmidx = length(frame_list):-1:1
%         frame_one = frame_list(fmidx);
%         time_one = frame_num2time(frame_one, sub_id);
%         
%         white_block_x = [time_ref_begin+0.01 time_ref_begin+0.01 xlim_end xlim_end];
%         white_block_y = [time_one ylim_end ylim_end time_one];
%         rect = fill(white_block_x, white_block_y, [1 1 1], 'EdgeColor', 'none');
%         
%         white_block_x = [time_one time_one xlim_end xlim_end];
%         white_block_y = [time_ref_begin+0.01 time_one time_one time_ref_begin+0.01];
%         rect = fill(white_block_x, white_block_y, [1 1 1], 'EdgeColor', 'none');
%         
%         plot_save_one = fullfile(plot_args.save_path, sprintf('crb_%d_aviframe_%d.png', sub_id, frame_one));
%         saveas(h1, plot_save_one);
%     end
% end

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
xlim([xlim_start-x_unit xlim_end]);
ylim([ylim_start-y_unit ylim_end]);

% if is_plot_diag
%     plot(x_axis, y_axis, '-k'); % , 'LineWidth', 1
%     sec_delay = 5;
%     plot(x_axis((30*sec_delay+1):end), y_axis(1:end-30*sec_delay), '-', 'Color', [0.4 0 0.4], 'LineWidth', 2);
% end

% title_str
title(title_str, 'FontSize', 8);

if isfield(plot_args, 'x_time') && isfield(plot_args, 'y_time')
    x_axis = plot_args.x_time;
    y_axis = plot_args.y_time;
    is_time = true;
    x_unit = x_axis(2)-x_axis(1);
    y_unit = y_axis(2)-y_axis(1);
else
    x_axis = 1;
    y_axis = 1;
    is_time = false;
    x_unit = 1;
    y_unit = 1;
end

hold off;

sub_plot([0.1 0 0.9 0.1]);

if exist(plot_args, 'save_path')
    plot_savefile = fullfile(plot_args.save_path, [plot_args.title_str '.png']);
    saveas(h1, plot_savefile);
    close(h1);
end