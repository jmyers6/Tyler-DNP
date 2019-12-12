%% Determining the Number of Points Measured per Signal and the Number of Signals in an mRUI .txt Output File from JMRUI
%%
%% Input
% _FID_: is a .txt output mRUI file from JMRUI
%% Outputs
% _pointsPerSig_: is the number of measurements taken per signal
%%
% _numSigs_: is the number of signals in the input file
%% Child Functions
% _isdatfile_: checks if an input is a readible file
% _isint_: checks if an input is an integral number

function [pointsPerSig,numSigs] = numofMeasurements(FID)
    
    if nargin < 1
        disp('Error: No input')
        FID = input('Enter a .txt mRUI file from JMRUI to calcualte the points per signal and number of signals: ','s');
    end

    %% Reading the Measurements per Signal and Number of Signals from the Input
    % The number of measurements is written on the 5th line from the 18th
    % character of it, while the number of signals is writen on the 6th
    % line from the 17th character of it.
    
    FIDbool = isdatfile(FID);
    
    while FIDbool == 0
        disp('Error: Invalid input')
        FID = input('Enter a .txt mRUI file from JMRUI to calcualte the points per signal and number of signals: ','s');
        FIDbool = isdatfile(FID);
    end
        
    fin = fopen(FID);
    
    for el = 1:5
        line = fgetl(fin);
    end
    
    pointsPerSig = str2double(line(18:end));
    intp = isint(pointsPerSig);
    
    while intp == 0
        
        disp('Error: Invalid input')
        FID = input('Enter a .txt mRUI file from JMRUI to calcualte the points per signal and number of signals: ','s');
        cont = isdatfile(FID);
        
        if cont == 1
            
            fin = fopen(FID);
    
            for el = 1:5
                line = fgetl(fin);
            end
    
            pointsPerSig = str2double(line(18:end));
            intp = isint(pointsPerSig);
            
        end
        
    end
    
    line = fgetl(fin);
    
    numSigs = str2double(line(17:end));
    
    fclose(fin);
    
end

%% Notes
% The input used in the example was:
%%
% _FID_: 'Decay_DissolutionFID_1Pyr_09_12_19.txt'
%%
% The example was run by putting:
%%
% [pointsPerSig,numSigs] =
% numofMeasurements('Decay_DissolutionFID_1Pyr_09_12_19.txt') 
%%
% into the command window