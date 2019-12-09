%% Determining the Time After the Start of an NMR Experiment Each Measurement was Taken
%% 
%% Inputs
% _proc_: is the procpar file for the NMR experiment of interest
%%
% _num_: is the number of measurements that were taken during the
% experiment
%% Output
% _x_: is a column vector containing all the times after the start of the
% experiment measurements were taken at
%% Child Functions
% _ampsfromfitted_: Parses the amplitudes from the .txt output from AMARES
% in JMRUI into an array
%%
% _TRfromProcpar_: Parses the _tr_ parameter from the procpar file of an
% NMR experiment into an array

function x = timeFromProcpar(proc,num)

    numbool = 1;
    
    %% Verifying that _num_ Exists and is a Whole Number of Measurements
    % If _num_ is not valid or does not exist, it is determined by running
    % the ampsfromfitted function and setting _num_ to the number of
    % amplitudes (measurements) from the first AMARES file and peak.

    if nargin < 2
        numbool = 0;
    elseif isint(num) ~= 1
        numbool = 0;
    end
    
    if numbool == 0
        amps = ampsfromfitted;
        num = length(amps);
    end
    
    procbool = 0;
    
    %% Verifying _proc_ Exists
    % In order to run timeFromProcpar, a procpar file is necessary. If
    % there is no _proc_ input, the user is called in readprocpar (child of
    % TRfromProcpar) to enter a valid procpar file.
    
    if nargin >= 1
        procbool = 1;
    end
    
    if procbool == 1
        TR = TRfromProcpar(proc);
    else
        TR = TRfromProcpar;
    end
    
    %% Determining the TR for Each Measurement
    % If TR was varied, it will be in an array, where each TR should be
    % used recursively to calculate the time a measurement took place.
    % Otherwise, TR is a number, and the TRs array is created to the length
    % of the number of measurements. If the number of measurements is
    % inconsistent with the number of TRs used if TR is not an integer, TR
    % is set to 1 to calculate the _x_ column vector.
    
    lenTR = length(TR);
    
    if lenTR == num
        
        TRs = TR;
        
    elseif isint(TR) == 1
        
        TRs = zeros(num,1);
        
        for el = 1:num
            TRs(el) = TR;
        end
        
    else
        
        disp('Error: Time values cannot be determined; TR will now be assumed to be constant and equal to 1')
    
        TRs = zeros(num,1);
        
        for el = 1:num
            TRs(el) = 1;
        end
        
    end
    
    %% Generating _x_
    % _x_ is populated via a recursive relationship, where the TR at a
    % measurement is added to the preceding _x_ value at the previous
    % measurement.
    
    x = zeros(num,1);
    x(1) = TRs(1);
    
    for el = 2:num
        x(el) = x(el-1)+TRs(el);
    end
    
end

%% Notes
% The inputs in the example used are:
%%
% _proc_: 'procpar21_11_19'
%%
% _num_: 25
%%
% The example was run by putting:
%%
% x = timeFromProcpar('procpar21_11_19',25)
%%
% into the command window