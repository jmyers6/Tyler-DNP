% loadJmruiAmares - Import jMRUI AMARES text output
%
% [output] = loadJmruiAmares(strFilename)
%
% OR:
% [output] = loadJmruiAmares(strFilename,'jmrui4_crlb_fix')
% which rescales the amplitude SDs to correct a bug in JMRUI4's AMARES
% implementation.
% 
% OR:
% [output] = loadJmruiAmares(strFilename, 1)
% for compatibility with version 1 output format.
%
% Import the AMARES results from jMRUI batch job output specified in
% strFilename.
%
% Example:
%
% fitted = loadJmruiAmares('Decay_Dissolution_28_11_19_even.txt')

% Copyright Chris Rodgers, University of Oxford, 2008-11.
% $Id: loadJmruiAmares.m 7516 2014-03-17 13:34:08Z crodgers $
%% Child Function
% _strsplit_pja.m_: splits a string into pieces at every occurence of its
% input

function [output] = loadJmruiAmares(strFilename, nVersion)

% Check input
error(nargchk(1, 2, nargin, 'struct'))

if ~ischar(strFilename)
    error('strFilename must be a string (not a %s).', class(strFilename))
end

bFixJmrui4CrlbBug = false;
if nargin < 2
    nVersion = 2;
elseif ischar(nVersion)
    if strcmp(nVersion,'jmrui4_crlb_fix')
        bFixJmrui4CrlbBug = true;
        nVersion = 2;
    else
        error('Unknown format for nVersion.')
    end
end

%% Import data
% names = cell(voxelCount,1);
% amplitudes = zeros(voxelCount,1);
% frequencies = zeros(voxelCount,1);

[fid, msg] = fopen(strFilename,'r');

% Skip this file if we can't open it
if fid==-1
    error('Could not open data file %s (%s)!',strFilename,msg);
end

%% Read each line of the file in turn and process

% Initialise output
output.headers = cell(0,2);
output.data = cell(0,0);

% Initialise state of reader code
bState = 0;
bRerunLine = 0;

% Main loop for reading file
while 1
    if bRerunLine
        bRerunLine = 0;
    else
        strLine = fgetl(fid);
    end
    
    %% Debug
%     fprintf('DBG: bState = %d, strLine = "%s"\n',bState,strLine)
    
    %% Test whether this line is "numeric"
    if bState == 0
        if any(regexp(strLine,'^\s*Points', 'once'))
            bState  = 1; % Header done - into body now?
            tmpNumericHeaderNames = strsplit_pja(char(9),strLine);
        else
            thisHeader = regexp(strLine,'^\s*([ A-Za-z0-9_,#-]*): (.*)$','tokens');
            if numel(thisHeader)>0
                output.headers(end+1,:) = thisHeader{1};
            end
        end
        
    %% Numeric header
    elseif bState == 1
        if any(regexp(strLine,'^\s*[-0-9]', 'once'))
            tmpNumericHeaderVals = str2double(strsplit_pja(char(9),strLine));
            
            tmp(:,1) = tmpNumericHeaderNames;
            tmp(:,2) = num2cell(tmpNumericHeaderVals);
            
            output.headers = [ output.headers; tmp];
            
        elseif any(regexp(strLine,'^Name of Algorithm: AMARES$', 'once'))
            bState = 2;
        end
        
    %% Peak names
    elseif bState == 2
        if ~isempty(strLine)
            % There's an extra TAB on the end, chop it off
            if strLine(end) == 9
                strLine(end) = [];
            end
            
            output.peakNames = strsplit_pja(char(9),strLine);
            
            bState = 3;
        end
        
    %% Results block - waiting for name
    elseif bState == 3
        
        if ~isempty(strLine)
            tmpCurrBlockName = strLine;
            tmpCurrBlockVals = [];
            bState = 4;
        end
        
    %% Results block - reading in data values
    elseif bState == 4
        
        % If there's an extra TAB on the end, chop it off
        if ~isempty(strLine) && strLine(end) == 9
            strLine(end) = [];
        end
        
        if any(regexp(strLine,'^(\s*[-0-9�]|Not known)', 'once'))
            tmpCurrBlockVals(end+1,:) = str2double(strsplit_pja(char(9),strLine)); %#ok<AGROW>
        else
            % Finished results block
            output.data(end+1).name = tmpCurrBlockName;
            output.data(end).vals = tmpCurrBlockVals;
            
            bRerunLine = 1;
            bState = 3;
        end
    end
    
    % Break the loop if EOF
    if feof(fid)
        break
    end
end

% All done - close and return results
fclose(fid);

% If version 2, return data sorted both by line and by peak.
if nVersion == 2
    output.dataByPeak = orderByPeak(output);
    output.dataByLine = output.data;
    
    % Store the "global" data: noise level, [Mg], etc.
    output.dataGlobal = struct();
    
    noiseDx = find(strcmp({output.dataByLine.name},'Noise : '),1,'first');
    if ~isempty(noiseDx)
        output.dataGlobal.noise = output.data(noiseDx).vals;
    end
    
    phMgDx = find(strcmp({output.dataByLine.name},'pH	Standard deviation of pH	[Mg2+]	Standard deviation of [Mg2+]'),1,'first');
    if ~isempty(phMgDx)
        output.dataGlobal.pH = output.data(phMgDx).vals(:,1);
        output.dataGlobal.pH_SD = output.data(phMgDx).vals(:,2);
        output.dataGlobal.Mg = output.data(phMgDx).vals(:,3);
        output.dataGlobal.Mg_SD = output.data(phMgDx).vals(:,4);
    end
    
    % Remove duplicate .data from output. (It's now called .dataByLine instead.)
    output = rmfield(output,'data');
    
    % Rescale amplitude CRLBs if requested
    output.dataGlobal.bFixJmrui4CrlbBug = bFixJmrui4CrlbBug;
    if bFixJmrui4CrlbBug
        fn = fieldnames(output.dataByPeak);
        for fnDx = 1:numel(fn)
            output.dataByPeak.(fn{fnDx}).Standard_deviation_of_Amplitudes = ...
                output.dataByPeak.(fn{fnDx}).Standard_deviation_of_Amplitudes ...
                ./ output.dataGlobal.noise;
        end
    end
end
end

function [x] = orderByPeak(data)
    % Sort the returned information by peak name
    thePeakNames = regexprep(regexprep(data.peakNames,'[^A-Za-z0-9]','_'),'^([^A-Za-z])','x$1');
    theResTypes = regexprep(regexprep({data.data.name},' *([\[\(].*[\]\)]|: *)$',''),'[^A-Za-z0-9]','_');

    % Avoid loading the "global" data because it is of a different
    % dimension. It's picked up in the calling code instead.
    % N.B. We have to specify the exist names now because Matlab AMARES
    % output doesn't have any "global" data so we can no longer simply skip
    % the final 2 fields.
    theResTypes(cellfun(@(x) ~isempty(x),regexp(theResTypes,'^(Noise|pH|CSI_Shift_vector|FIDs_hash)','once'))) = [];
    
    for resdx=1:numel(theResTypes)
        for peakdx=1:numel(data.peakNames)
            x.( thePeakNames{peakdx} ).( theResTypes{resdx} ) = data.data(resdx).vals(:,peakdx);
        end
    end
end