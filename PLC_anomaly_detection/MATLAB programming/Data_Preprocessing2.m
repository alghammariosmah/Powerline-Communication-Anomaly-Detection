function ProcessData = Data_Preprocessing2(ProcessedData)

parpool(4); % sparing 4 cores to process the data

hf_size = size(ProcessedData.HF);
taggingInfo_size = size(ProcessedData.TaggingInfo);
difference = [];
con3 = {};


% getting time ticks for each appliance
parfor j = 1:taggingInfo_size(1)
    count = 0;
    for i =  1:hf_size(2)  % HF on the time domain = 10,267
        if ProcessedData.TaggingInfo{j, 3} <= ProcessedData.HF_TimeTicks(i) && ProcessedData.HF_TimeTicks(i) <= ProcessedData.TaggingInfo{j, 4}
           count = count + 1;
        elseif j < taggingInfo_size(1)
            if ProcessedData.TaggingInfo{j, 4} <= ProcessedData.HF_TimeTicks(i) && ProcessedData.HF_TimeTicks(i) <= ProcessedData.TaggingInfo{j+1, 3}
                % Reducing Baseline HF noise to every 500 seconds
                if mod(ceil(ProcessedData.HF_TimeTicks(i)), 400) == 0 
                    % Calculating SNR for each appliance event
                   constant = 255 * ones(4096,1); % 255 dbVm 
                   SNR = 10*log10(constant./double(ProcessedData.HF(:, i)));
                 
                    % Saving All SNR calculations in a variable
                   % k = SNR(2048:end);
                   flip = fliplr(SNR')
                   all = sprintf(',%f',flip);
                   stringlist = strcat('baseline',all);
                   con3 =  [con3; {stringlist}];
                end                    
            end
        end
    end
    difference = [difference; count];
end
               


parfor j = 1:taggingInfo_size(1) % To calculate SNR of each appliance separately
    if difference(j) > 30
        % getting 30 maximum time ticks 
        count_down = 30;
        for i = 1:hf_size(2) % HF on the time domain = 10,267
            if ProcessedData.TaggingInfo{j, 3} <= ProcessedData.HF_TimeTicks(i) && ProcessedData.HF_TimeTicks(i) <= ProcessedData.TaggingInfo{j, 4}
                if count_down > 0;

                   % Calculating SNR for each appliance event
                   constant = 255 * ones(4096,1); % 255 dbVm 
                   SNR = 10*log10(constant./double(ProcessedData.HF(:, i)));
                   
                   % Saving All SNR calculations in a variable
                   % k = SNR(2048:end);
                   flip = fliplr(SNR')
                   all = sprintf(',%f',flip);
                    stringlist = strcat(char(ProcessedData.TaggingInfo{j, 2}),all);
                    con3 =  [con3; {stringlist}];

                   count_down = count_down - 1;
                end
            end
        end
    elseif difference(j) < 30
        for i = 1:hf_size(2) % HF on the time domain = 10,267
            if ProcessedData.TaggingInfo{j, 3} <= ProcessedData.HF_TimeTicks(i) && ProcessedData.HF_TimeTicks(i) <= ProcessedData.TaggingInfo{j, 4}
                % Calculating SNR for each appliance event
                constant = 255 * ones(4096,1); % 255 dbVm 
                SNR = 10*log10(constant./double(ProcessedData.HF(:, i)));

                 
                % Saving All SNR calculations in a variable
                % k = SNR(2048:end);
                flip = fliplr(SNR')
                 all = sprintf(',%f',flip);
                 stringlist = strcat(char(ProcessedData.TaggingInfo{j, 2}),all);
                 con3 =  [con3; {stringlist}];
                 
            end
        end
    end
    
end
delete(gcp('nocreate'))

% storing the data in a CSV file.
%filename = 'training_data1.csv';
%xlswrite(filename,con3,'Sheet1','A1')

fid=fopen('test4096t.txt','w');
fprintf(fid,'%s \n',con3{:});
fclose(fid);


%clear ('SNR','temp','taggingInfo_size','t','SNR','power_signal','power_noise','i', 'j', 'hf_size', 'hf_count',...
%'freq_noise','freq_signal','difference','difference2','count', 'count2', 'constant','appliance');

end


