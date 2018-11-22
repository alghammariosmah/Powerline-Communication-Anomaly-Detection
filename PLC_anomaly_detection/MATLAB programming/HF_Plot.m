function [figure_handle] = HF_Plot(ProcessedData, hasLabels)
if (nargin ~=2 && nargin ~= 4)
    fprintf(1, 'Incorrect number of optional arguments. Expected 2 or 4, given %d\n', nargin);
    h = 0;
    return;
elseif (nargin == 4)
    % Check if time valid for this data
    check = max(int64(ProcessedData.HF_TimeTicks(:,1))) >= stop_TS ...
                && min(int64(ProcessedData.HF_TimeTicks(:,1))) <= start_TS;
    if( ~check )
        fprintf(1, 'Start or Stop time out of bounds\n');
        return;
    end
    
    % Truncate all data to be withing start and stop timestamps
    % Find start and top indexes for L1 data. Since there are 6 values per
    % second, we use min/max.
    
    % HF Indexes
    start_idx_HF = min(find(int64(ProcessedData.HF_TimeTicks(:,1)) == int64(start_TS) ));
    stop_idx_HF = max(find(int64(ProcessedData.HF_TimeTicks(:,1)) == int64(stop_TS) ));
    
    %Truncate data
    ProcessedData.HF = ProcessedData.HF(:, start_idx_HF:stop_idx_HF);
    ProcessedData.HF_TimeTicks = ProcessedData.HF_TimeTicks(start_idx_HF:stop_idx_HF, :);

end

% Labels (TaggingInfo) part relevant only for Training Datasets 
% **************************************************************
% Plot HF Noise time domain and labels. Green is ON and Red line is OFF, along with
% device category ID.
h(1) = subplot(211);
plot(ProcessedData.HF_TimeTicks,mean(ProcessedData.HF))
title('HF Time domain and ON/OFF Device Category IDs');
ylabel('Power Spectral Density');

if(hasLabels == true && isfield(ProcessedData,'TaggingInfo') )
    % Draw ON/OFF and device labels. TaggingInfo's each row is:
    % <ApplianceID, ApplianceName, Start_UNIX_TimeStamp, Stop_UNIX_TimeStamp>
    mi = min(mean(ProcessedData.HF));
    me = mean(mean(ProcessedData.HF));
    for i=1:size(ProcessedData.TaggingInfo,1)
        line([ProcessedData.TaggingInfo{i,3},ProcessedData.TaggingInfo{i,3}],[mi,me],'Color','g','LineWidth',2);
        %We add a little offset for display purposes to end marker since
        %event could be +- 30
        %seconds of the timestamp.
        offset = 25;
        line([ProcessedData.TaggingInfo{i,4} + offset,ProcessedData.TaggingInfo{i,4} + offset],[mi,me],'Color','r', 'LineWidth',2);    
        text(double(ProcessedData.TaggingInfo{i,3}),me,['ON-' ProcessedData.TaggingInfo{i, 2}] );
        text(double(ProcessedData.TaggingInfo{i,4}),me,['OFF'] );
    end
end

hold off;


% Plot HF Noise time-frequency domain
freq = linspace(1000000,0,4096); % FFT is of size 4096 point across 1 Mhz
h(2) = subplot(212);
imagesc(ProcessedData.HF_TimeTicks, freq, ProcessedData.HF);
title('High Frequency Noise');
ylabel('Frequency KHz');
axis xy;
y = [0:200000:1e6];
set(gca,'YTick',y);  % Apply the ticks to the current axes
set(gca,'YTickLabel', arrayfun(@(v) sprintf('%dK',v/1000), y, 'UniformOutput', false) ); % Define the tick labels based on the user-defined format

linkaxes(h,'x');

figure_handle = h;

end
