%% Graphing Microwave Sweep Data and Calculating Polarisation Frequencies
%%
%% Inputs
% _x_: is a column vector of the microwave frequencies sweeped
%%
% _y_: is an array of the signal for each microwave frequency
% sweeped. Each NMR peak is in a different column
%%
% _titl_: is the title of the microwave sweep plot and should be a
% character vector
%%
% _peaknames_: is a cell containing the names of each NMR peak
%% Alternative Inputs for When _x_ and _y_ are not Available (Hypersense)
% _sys_: should be set to 'N' indicating the data originated from the
% Hypersense System
%%
% _dat_: is the file that contains the sweep data. It is the exported .dat
% file from the Hypersense
%% Alternative Inputs for When _x_ and _y_ are not Available (Alpha System)
% _sys_: should be set to 'Y' indicating the data originated from the Alpha
% System
%%
% _dat_: is a cell that contains the data file(s). The first set
% of data should correspond to positive amplitudes, while the second set
% should correspond to negative amplitudes. If the amplitudes were
% calculated from MestReNova, _dat_ should be a character vector (file
% name)
%%
% _mic_: can either be a .csv file containing the frequencies used in GHz 
% or a column vector
%%
% _inp_: should be set to either 'A' or 'M' depending on if the
% amplitudes of the data were calculated using the AMARES algorithm in
% JMRUI ('A') or peak integration in MestReNova ('M')
%%
% _coilnum_: is the number of coils used to measure the data.
% This variable should always be set to '[]' unless _inp_ has been set to
% 'M'.
%%
% _field_: is a cell containing the names of the peaks quanitified
% from the data. It should always be set to '[]' unless _inp_ has been set
% to 'M', since the AMARES algorithm names the peaks.
%% Outputs
% _f_: is an eight term fourier function fitted to the microwave data used
% to calculate the optimum polarisation frequencies
%%
% _val1_: is an array containing the optimum frequencies to positively
% polarise each species
%%
% _val2_: is an array containing the optimum frequencies to negatively
% polarise each species
%% Child Functions
% _checkYN_: checks if an input is 'Y', 'y', 'N', 'n' or something else
%%
% _alphaparse_: parses data collected from the Alpha System and/or 300MHz
% magnet into the _x_ and _y_ arrays
%%
% _isdatfile_: checks if an input is a readible file
%%
% _parsedat_: parses data collected from the Hypersense into the _x_ and
% _y_ arrays

function [f,val1,val2] = sweepscatter(x,y,sys,dat,mic,inp,coilnum,field,titl,peaknames)
    
    alg = 0;
    
    if nargin < 10
        peaknames = {'Data'};
    end
    
    %% Checking if _x_ and _y_ are Valid
    % If no _x_ or _y_ arrays are entered, or if they are invalid, such as
    % if they have inconsistent dimensions, they must be calculated using
    % the alternative inputs.
    
    xlen = length(x);
    ylen = length(y);
    
    if nargin < 2
        alg = 1;
    elseif isempty(x) == 1
        alg = 1;
    elseif isempty(y) == 1
        alg = 1;
    elseif xlen ~= ylen
        alg = 1;
        
    end
    
    %% Calling the User if There is Insufficient Data to Calculate the _x_ and _y_ Arrays
    % If the inputted _x_ and _y_ arrays are not valid, they will need to
    % be calculated from the other inputs. If the other inputs are
    % insufficient or invalid, the user will be called to enter the missing
    % information.
    
    if alg == 1
        
        prompt = 'Was the data collected using the Alpha System (Y) or the Hypersense (N)? (Y/N): ';
        
        if nargin < 3
            sys = input(prompt,'s');
        end
        
        sysbool = checkYN(sys);
        
        while sysbool == 0
            sys = input('Please enter Y if the data was collected using the Alpha System or N if the data was collected using the Hypersense (Y/N): ','s');
            sysbool = checkYN(sys);
        end
        
        if sysbool == 1
            if nargin >= 8
                [x,y,peaknames] = alphaparse(mic,inp,'Y',dat,coilnum,field);
            elseif nargin >= 7
                [x,y,peaknames] = alphaparse(mic,inp,'Y',dat,coilnum);
            elseif nargin >= 6
                [x,y,peaknames] = alphaparse(mic,inp,'Y',dat);
            elseif nargin >= 5
                [x,y,peaknames] = alphaparse(mic,[],'Y',dat);
            elseif nargin >= 4
                [x,y,peaknames] = alphaparse([],[],'Y',dat);
            else
                [x,y,peaknames] = alphaparse([],[],'Y');
            end
        elseif sysbool == 2
            
            if nargin < 4
                dat = input('Enter the .dat file containing the Microwave Sweep data: ','s');
            end
            
            datbool = isdatfile(dat);
                
            while datbool == 0
                dat = input('Error: Please enter a valid .dat file','s');
                datbool = isdatfile(dat);
            end
                
            if datbool == 1
                data = parsedat(dat);
                x = data(:,1);
                y = data(:,2);
            end
                
        end
        
    end
    
    %% Establishing the Dimensions of the Outputted Arrays
    % There should be one value each to negatively and positively polarise
    % each species in a sample. The _val1_ and _val2_ arrays are intialised
    % here with the proper dimensions.
    
    nums = length(peaknames);
    val1 = zeros(nums,1);
    val2 = zeros(nums,1);
    
    %% Generating the Microwave Sweep Plot
    % The microwave sweep raw data is first plotted
    % An eight term fourier function is then fit to the data, and it is
    % solved over the domain of the frequencies.
    % The absolute minimums and maxiumums of the fourier function are
    % calculated, which are the values of _val2_ and val1_ respectively
    % The fitted fourier function is then plotted over the data. If there
    % are multiple data sets, they are plotted on top of each other in the
    % same figure.
    

    figure('Position',[0 0 800 600]) 
    
    scatter(x,y(:,1),'filled')
    xlim([min(x) max(x)])
    ylim([(1.1*min(y(:))) (1.1*max(y(:)))])
    hold on
    
    f = fit(x,y(:,1),'fourier8');
    plot(x,y(:,1),'k')
    
    rangeint = (max(x)-min(x))/1000; 
    range = min(x):rangeint:max(x);
    yarray = f(range); 
    
    ymin = min(yarray); 
    ymax = max(yarray);
    
    inl = yarray == ymin;
    inh = yarray == ymax;
    
    val1(1) = range(inl);
    val2(1) = range(inh);
    
    val1disp = num2str(val1(1));
    val2disp = num2str(val2(1));
    
    vardisp = strcat('This sample species should be negatively polarised at', {' '}, val2disp, 'GHz or positively polarised at', {' '}, val1disp, 'GHz');
    
    leny = length(y(1,:));
    
    if leny > 1
        
        for el = 2:leny
            
            scatter(x,y(:,el),'filled')
    
            f = fit(x,y(:,el),'fourier8');
            plot(x,y(:,el),'k')
    
            rangeint = (max(x)-min(x))/1000; 
            range = min(x):rangeint:max(x);
            yarray = f(range); 
    
            ymin = min(yarray); 
            ymax = max(yarray);
    
            inl = yarray == ymin;
            inh = yarray == ymax;
    
            val1(el) = range(inl);
            val2(el) = range(inh);
    
            val1disp = num2str(val1(el));
            val2disp = num2str(val2(el));
    
            vardisp = strcat('This sample species should be negatively polarised at', {' '}, val2disp, 'GHz or positively polarised at', {' '}, val1disp, 'GHz');
            
        end
    end
    
    len = length(x); 
    y1 = zeros(len,1);
    plot(x,y1,'k')
    grid on
    grid minor
    
    if leny == 1
        dim = [.13 0 .3 .17]; 
        annotation('textbox',dim,'String',vardisp,'FitBoxToText','on');
        hLeg = legend(vardisp);
        set(hLeg,'visible','off')
    end
    
    xlabel('Frequency /GHz')
    ylabel('Signal Strength /Arbitrary Units')
    
    if nargin < 9
        titl = 'Microwave Sweep';
    elseif isempty(titl) == 1
        titl = 'Microwave Sweep';
    elseif string(class(titl)) ~= "char"
        titl = 'Microwave Sweep'; 
    end
    
    title(titl)
    
    if length(peaknames) > 1
        
        numlen = length(peaknames)*2;
        legpeaks = cell(numlen,1);
        
        for el = 1:length(peaknames)
            inda = el*2;
            ind = inda-1;
            legpeaks{ind} = peaknames{el};
        end
        
        legend(legpeaks)
        
    end
    
end

%% Notes
% The inputs used in the example are:
%%
% _x_: []
%%
% _y_: []
%%
% _sys_: 'N'
%%
% _dat_: '1Pyr_7_10_sweep.dat'
%%
% _mic_: []
%%
% _inp_: []
%%
% _coilnum_: []
%%
% _field_: []
%%
% _titl_: 'Microwave Sweep of ^{13}C 1-Pyruvate Using OX063 7/10/19'
%%
% The example was run by putting:
%%
% [f,val1,val2] = sweepscatter([],[],'N','1Pyr_7_10_sweep.dat',[],[],[],[],
% 'Microwave Sweep of ^{13}C 1-Pyruvate Using OX063 7/10/19') 
%%
% into the command window
