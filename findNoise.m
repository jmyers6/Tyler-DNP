%% Calculating the Noise from an NMR Experiment
%%
% NMR data is often described by its signal to noise (SNR) ratio. In this
% function, the noise of an NMR experiment is defined by the standard
% deviation of the last eighth of the points in the experiment's time
% domain. If there is more than one signal inside the inputted file, only
% the noise for the first signal will be calculated.
%%
% In NMR experiments, data is collected in both real and imaginary
% components. The noise is calculated separately for both components and
% then outputted as the average of the two
%% Input
% _dat_: is a cell containing the .txt mRUI FID files from JMRUI, where 
% the noise is to be calculated from in each element
%% Output
% _noise_: is an array containing the calculated noise for each inputted
% FID file in each element
%% Child Function
% _numofMeasurements_: returns the number of measurements taken per signal
% for a .txt mRUI FID file from JMRUI

function noise = findNoise(dat)

    cont = 0;
    
    %% Verifying the Existence and Validity of the Input

    if nargin == 1
        if string(class(dat)) == "cell"
            cont = 1;
            try
                readmatrix(dat{1});
            catch
                disp('Invalid files entered')
                cont = 0;
            end
        end
    end
    
    %% Calculating the Noise if the Input is Valid
    % The number of noise parameters calculated is equal to the number of
    % files inputted. The standard deviation is taken along the last eighth
    % of the points in the time domain of both the real and imaginary parts
    % of the data. The final calculated noise is the mean of those two
    % values
    
    if cont == 1
        
        numEnt = length(dat);
        pointsPerSig = numofMeasurements(dat{1});
        noisesVar = zeros(numEnt,1);
        
        for el = 1:numEnt
            FIDa = readmatrix(dat{el});
    
            FID = FIDa(1:pointsPerSig,1:2);
    
            rows = length(FID(:,1));
    
            lastEighth = floor(rows/8);
    
            noises = std(FID(end-lastEighth:end,:));
    
            noisesVar(el) = mean(noises);
        end
        
    else
        
        %% Calling the User to Input FID files if the Input was Invalid or Missing
        % The user is called to enter a FID file, where the noise is
        % calculated as described above. The user can then enter additional
        % FID files, where the noise is appended to the previously
        % calcualted ones until the user terminates input by typing 'N'
        % when prompted
        
        datn = input('Enter the .txt file containing the FID: ','s');
        FIDa = readmatrix(datn);
        pointsPerSig = numofMeasurements(datn);
        FID = FIDa(1:pointsPerSig,1:2);
        rows = length(FID(:,1));
        lastEighth = floor(rows/8);
        noises = std(FID(end-lastEighth:end,:));
        noisesVar = mean(noises);
        bool = 0;
        
        while bool == 0
            
            inp = input('Is there data from another coil to process? (Y/N): ','s');
            bool = checkYN(inp);
            
            if bool == 0
                disp('Error: Enter Y or N to signify whether to process another set of FID data')
            end
            
        end
        
        while bool == 1
            
            datn = input('Enter the next .txt file containing the FID: ','s');
            FIDa = readmatrix(datn);
            pointsPerSig = numofMeasurements(dat{1});
            FID = FIDa(1:pointsPerSig,1:2);
            rows = length(FID(:,1));
            lastEighth = floor(rows/8);
            noises = std(FID(end-lastEighth:end,:));
            noisesVar = [noisesVar; mean(noises)];
            inp = input('Is there data from another coil to process? (Y/N): ','s');
            bool = checkYN(inp);
            
            while bool == 0
                disp('Error: Enter Y or N to signify whether to process another set of FID data')
                inp = input('Is there data from another coil to process? (Y/N): ','s');
                bool = checkYN(inp);
            end
            
        end
        
    end
    
    noise = noisesVar;
    
end

%% Notes
% The input used in the example was:
%%
% _dat_: {'Decay_DissolutionFID_1Pyr_09_12_19.txt','ThermalFID_1Pyr_10_12_19.txt'}
%%
% The example was run by putting:
%%
% noise = findNoise({'Decay_DissolutionFID_1Pyr_09_12_19.txt','ThermalFID_1Pyr_10_12_19.txt'})
%%
% into the command window