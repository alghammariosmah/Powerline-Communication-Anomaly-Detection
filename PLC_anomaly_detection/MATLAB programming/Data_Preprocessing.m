function ProcessedData = Data_Preprocessing(ProcessedData)
% UNIX time when appliance activities happen 
min_ts = min(cellfun(@(x)x(1), ProcessedData.TaggingInfo(:,3)));
max_ts = max(cellfun(@(x)x(1), ProcessedData.TaggingInfo(:,4)));

% HF Indexes where activities happen
start_idx_HF = min(find(int64(ProcessedData.HF_TimeTicks(:,1)) == int64(min_ts) ));
stop_idx_HF = max(find(int64(ProcessedData.HF_TimeTicks(:,1)) == int64(max_ts) ));

% Cutting HF where the appliance where On/Off events occur
ProcessedData.HF_TimeTicks = ProcessedData.HF_TimeTicks(start_idx_HF:stop_idx_HF);
ProcessedData.HF = ProcessedData.HF(:, start_idx_HF:stop_idx_HF);
ProcessedData.TaggingInfo = ProcessedData.TaggingInfo;

hf_size = size(ProcessedData.HF);

for i = 1:hf_size(2) % HF on the time domain = 10,267
    % Extrapolate missing values or values under the minumum value
    A = ProcessedData.HF(:, i);
    A= double(A);
    [out,idx]=sort(A);
    val=out(9);
    A(A < val) = 0;
    x = 1:length(A);
    xi = 1:length(A);
    zs = A==0;% Zeros locations
    A(zs) = [];
    x(zs)=[];
    output = interp1(x, A, xi,'nearest' ,'extrap');
    ProcessedData.HF(:, i) =output';
end


clear ('max_ts','min_ts','start_idx_HF','stop_idx_HF','start_idx_L1','stop_idx_L1','start_idx_L2','stop_idx_L2','output','A', 'out','idx','val','xi','x');
end