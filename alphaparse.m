%% Parsing Data Collected from the Alpha System and/or 300MHz Magnet
%%
%% Inputs
% _mic_: If the data is from a microwave sweep, _mic_ can either be a .csv
% file containing the frequencies used in GHz or a column vector
%%
% _inp_: should be set to either 'A' or 'M' depending on if the
% amplitudes of the data were calculated using the AMARES algorithm in
% JMRUI ('A') or peak integration in MestReNova ('M')
%%
% _mbool_: should be set to 'Y' if the data is from a microwave
% sweep. Otherwise, it can be set to anything else.
%%
% _dat_: is a cell that contains the data file(s). If the data is
% from a microwave sweep processed using AMARES from JMRUI, the first set
% of data should correspond to positive amplitudes, while the second set
% should correspond to negative amplitudes. If the amplitudes were
% calculated from MestReNova, _dat_ should be a character vector (file
% name)
%%
% _coilnum_: is the number of coils used to measure the data.
% This variable should always be set to '[]' unless _inp_ has been set to
% 'M'.
%%
% _field_: is a cell containing the names of the peaks quanitified
% from the data. It should always be set to '[]' unless _inp_ has been set
% to 'M', since the AMARES algorithm names the peaks.
%%
% _proc_: is the procpar file associated with the data. If _mbool_
% is set to 'Y', _proc_ is not necessary and can be set to '[]'.
%% Outputs
% _x_: is a column vector containing the x-data.
%%
% _y_: is a column vector containing the y-data.
%%
% _peaknames_: _peaknames is a cell, where each element contains the name of
% one of the peaks from the data
%% Child Functions
% _checkinp_: checks if an input is 'A', 'a, 'M', 'm' or something else
%%
% _checkYN_: checks if an input is 'Y', 'y', 'N', 'n' or something else
%%
% _processAMARESSweep_: parses .txt AMARES outputs from a frequency sweep
% into structure arrays
%%
% _isdatfile_: verifies an input is a readible file
%%
% _processAMARES_: parses .txt AMARES outputs into a structure array
%%
% _summestrenova_: parses the custom integral .csv output from MestReNova
% into a structure array
%%
% _isint_: checks if an input is an integer
%%
% _readmatrixrig_: is a more rigorous version of the readmatrix function
% that does not throw exceptions
%%
% _ampsfromfitted_: parses the amplitudes from process raw data in a
% structure array into an array
%%
% _timeFromProcpar_: creates an array of times where measurements were
% taken using the TR (repetition time(s)) from the procpar file for an NMR
% experiment
%%
% _createColumnNum_: allows for manual entry of values to create a column
% vector
%%
% _zeroToNaN_: converts all zeros within an array to NaN (Not a Number)

function [x,y,peaknames] = alphaparse(mic,inp,mbool,dat,coilnum,field,proc)
    
    %% Calling the User if There is Insufficient Information to Process the Files in _dat_
    % Depending on if the data came from AMARES or MestReNova, its type
    % etc., it needs to processed differently to extract the y-data. If
    % insufficient or invalid inputs have been entered, the user will be
    % called to enter the information needed to correctly process the data.
    
    inpbool = 0;
    
    while inpbool == 0
        
        if nargin < 2
            
            prompt = 'Is the data the output .txt AMARES from JMRUI or the Integration from MestReNova? (A/M): ';
            inp = input(prompt,'s');
            
            inpbool = checkinp(inp);
            
        else
            
            inpbool = checkinp(inp);
            
            if inpbool == 0
                
                prompt = 'Is the data the output .txt AMARES from JMRUI or the Integration from MestReNova? (A/M): ';
                inp = input(prompt,'s');
                
            end
            
        end
        
    end
    
    if inpbool == 1
        
        mboolean = 0;
        
        while mboolean == 0
            
            if nargin < 3
                
                prompt1 = 'Is this set of data from a microwave sweep? (Y/N): ';
                mbool = input(prompt1,'s');
                mboolean = checkYN(mbool);
                
            else
                
                mboolean = checkYN(mbool);
                
                if mboolean == 0
                    prompt1 = 'Is this set of data from a microwave sweep? (Y/N): ';
                    mbool = input(prompt1,'s');
                end
                
            end
            
        end
        
        if mboolean == 1
            
            datbool = 0;
            
            if nargin >= 4
                if string(class(dat)) == "cell"
                    if length(dat) == 2
                        if isdatfile(dat{1}) == 1
                            if isdatfile(dat{2}) == 1
                                datbool = 1;
                            end
                        end
                    end
                end
            end
            
            %% Processing the Data into a Structure Array
            % The files in _dat_ are processed into a structure array 
            % allowing access to the y data using the _ampsfromfitted_ 
            % function. How _dat_ is processed depends on if the data is
            % from a microwave sweep and whether AMARES or MestReNova was
            % used to quantify the peaks in _dat_.
            
            if datbool == 1
                [fitted,fittedneg] = processAMARESSweep(dat{1},dat{2});
            else
                [fitted,fittedneg] = processAMARESSweep;
            end
            
        elseif mboolean == 2
            
            datbool = 0;
            
            if nargin >= 4
                
                if string(class(dat)) == "cell"
                    
                    lendat = length(dat);
                    datval = 1;
                    
                    for el = 1:lendat
                        
                        datboolh = isdatfile(dat{el});
                        
                        if datboolh == 0
                            datval = 0;
                        end
                        
                    end
                    
                    if datval == 1
                        datbool = 1;
                    end
                    
                end
                
            end
            
            if datbool == 1
                fitted = processAMARES(dat);
            else
                fitted = processAMARES;
            end
            
        end
        
    elseif inpbool == 2
        
        mboolean = 2;
        
        datbool = 0;
        coilbool = 0;
        fieldbool = 0;
        
        if nargin >= 4
            if isdatfile(dat) == 1
                datbool = 1;
            end
        end
        
        if nargin >= 5
            if isint(coilnum) == 1
                coilbool = 1;
            end
        end
        
        if nargin >= 6
            if string(class(field)) == "cell"
                fieldbool = 1;
            end
        end
        
        if datbool == 1
            
            if coilbool == 1
                
                if fieldbool == 1
                    fitted = summestrenova(dat,coilnum,field);
                else
                    fitted = summestrenova(dat,coilnum);
                end
                
            else
                
                if fieldbool == 1
                    fitted = summestrenova(dat,[],field);
                else
                    fitted = summestrenova(dat);
                end
                
            end
            
        else
            
            if coilbool == 1
                
                if fieldbool == 1
                    fitted = summestrenova([],coilnum,field);
                else
                    fitted = summestrenova([],coilnum);
                end
                
            else
                
                if fieldbool == 1
                    fitted = summestrenova([],[],field);
                else
                    fitted = summestrenova;
                end
                
            end
            
        end
        
    end
    
    %% Sorting Data Based on Peak into _y_
    % The data in the structure array is processed into _y-data_ by:
    %%
    % Summing data from different coils in the case of AMARES data
    %%
    % Concatenating data corresponding to negative polarisation to data
    % corresponding to positive polarisation and ensuring the signs of the
    % amplitudes in the negative data is negative in the case of microwave
    % sweep data processed by AMARES
    
    [amps,peaknames,numpeak] = ampsfromfitted(fitted);
    numchs = length(amps);
    
    if mboolean == 1
        ampnega = ampsfromfitted(fittedneg);
        ampneg = -1.*ampnega;
        numchs = numchs+length(ampneg);  
    end
    
    y = zeros(numchs,numpeak);
    
    if mboolean == 1
    
        for el = 1:numpeak
            aampn = ampsfromfitted(fitted,1,el);
            aampnnega = ampsfromfitted(fittedneg,1,el);
            aampnneg = -1.*aampnnega;
            amps = [aampn;aampnneg];
            y(:,el) = amps;
        end
        
    else
        
        %% Generating the _x-data_
        % Depending on the type of the data, the _x-data_ is generated by:
        %%
        % Summing the repetition times (TR) in experiments where time is
        % the independent variable
        %%
        % In the case of microwave sweep data, the _x-data_ is the
        % frequencies sweeped, so it has to be imported from a .csv file 
        % or entered as set of frequencies in a column vector.
        
        numamar = length(fitted);
        
        procbool = 0;
        
        if nargin >= 7
            if isdatfile(proc) == 1
                procbool = 1;
            end
        end
        
        if procbool == 1
            x = timeFromProcpar(proc,numchs);
        else
            x = timeFromProcpar([],numchs);
        end
        
        for el = 1:numpeak
            for ele = 1:numamar 
                aampn = ampsfromfitted(fitted,ele,el);
                y(:,el) = y(:,el)+aampn;
            end
        end
        
    end
    
    if mboolean == 1
        
        micbool = 1;
    
        if nargin < 1
            micbool = 0;
        elseif isdatfile(mic) ~= 1
            micbool = 0;
        end
        
        if string(class(mic)) == "double"
            if length(mic) == numchs
                micbool = 1;
            end
        end
        
        if micbool == 0
        
            prompt = 'Would you like to enter the x-data individually (Y) or in a .csv file (N)? (Y/N): ';
        
            xmboole = 0;
        
            while xmboole == 0
                xmbool = input(prompt,'s');
                xmboole = checkYN(xmbool);
            end
        
            if xmboole == 1
                mic = createcolumnNum(numchs);
            elseif xmboole == 2
                mic = readmatrixrig;
            end
             
        else
            
            if string(class(mic)) == "double"
                if length(mic) ~= numchs
                    mic = createcolumnNum(numchs);
                end
            else
                mic = readmatrixrig(mic);
            end
                
        end
    
        x = mic;
    
    end
    
    y = zeroToNaN(y);
        
end

%% Notes
% The inputs used in the example are:
%%
% _mic_: 'micval27_11_19.csv'
%%
% _inp_: 'A'
%%
% _mbool_: 'Y'
%%
% _dat_: {'Microwave_Sweep_27_11_19_pos.txt', 'Microwave_Sweep_27_11_19_neg.txt'}
%%
% The outputs in the example are:
%%
% _x_: The microwave frequencies sweeped in GHz
%%
% _y_: The amplitudes of the signal at each microwave frequency for each
% peak
%%
% _peaknames_: The name of the peak quantified
%%
% The example was run by putting:
%%
% [x,y,peaknames] =
% alphaparse('micval27_11_19.csv','A','Y',
% {'Microwave_Sweep_27_11_19_pos.txt','Microwave_Sweep_27_11_19_neg.txt'})
%%
% into the command window