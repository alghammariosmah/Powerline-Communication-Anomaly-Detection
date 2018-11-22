function [ProcessedData] =  ProcessHFRawData(Buffer)
% Move over HF Noise and Device label (tagging) data to our final structure as well
ProcessedData.HF = Buffer.HF;
ProcessedData.HF_TimeTicks = Buffer.TimeTicksHF;
% Copy Labels/TaggingInfo id they exist
if( isfield(Buffer,'TaggingInfo') )
    ProcessedData.TaggingInfo = Buffer.TaggingInfo;
end

end