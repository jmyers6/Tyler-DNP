%% Combining MRI Data Collected using Multiple Channels via Whitened Singular Value Decomposition (WSVD)
%%
% Data in MRI machines is often collected using multiple channels to
% maximise the likelihood of the sample being detectd by at least one
% channel. However, interpreting the data is non-trivial. WSVD combines the
% data from all channels in a manner that maximises the signal to noise
% ratio (SNR). 
%%
% NB Depending on the amount of data, this function can take multiple
% minute to run, since it was implemented using MATLAB alone, which is less
% optimised for parsing than other languages, such as Perl
%% Inputs
% _dat_: is a cell containing .txt mRUI files from JMRUI. Each file
% contains the phased data from one channel from the same experiment
%% 
% _noiseind_: is an array containing the start and end indices of parts of
% the FID files that contain noise. For example, for 1-pyruvate, the first
% 2000 measured points out of 4096 do not contain any signal and all the
% points after 2600 do not contain any signal; therfore, noiseind = [1 2000
% 2600 4096] indicating points 1-2000 are noise and points 2600-4096 of the
% FID inputs are noise
%% Output
% A file is written containing the summed data, where the name is given by
% the first element of the _dat_ cell with the word 'Final' added before
% the .txt extention
%% Child Functions
% _isint_: checks if an input is an integer
%%
% _numofMeasurements_: reads the number of points measured per signal and
% the number of signals in each element of _dat_
%%
% _readmatrixrig_: is a version of the readmatrix function less prone to
% throwing exceptions
%%
% _removeNaNs_: removes any rows within an array, where any element in the
% row is NaN (Not a Number)
%%
% _svdReconstructFrequencyDomain_: calculates the factors each set of data
% should be multiplied with before summing them together
%%
% _writeToFIDtxt_: writes the summed channel data into a new .txt mRUI
% file, which is outputted

function sumFIDs(dat,noiseind)

    %% Verifying the Validity of _dat_ Input

    datbool = 1;

    if nargin < 0
        datbool = 0;
    elseif string(class(dat)) ~= "cell"
        disp('Error: invalid input. Input must be a cell (use { })')
        datbool = 0;
    end
    
    %% Calling the User if _dat_ is Missing or Invalid
    % _dat_ must be a cell containing the FID .txt mRUI files. If _dat_ is
    % not a cell, the user will be called to enter how many FID files need
    % to be summed, before being prompted to enter the FID files one by one
    
    if datbool == 0
        
        prompt = 'Enter the number of FID files to be summed: ';
        
        numents = input(prompt,'s');
        nument = str2double(numents);
        
        cont = isint(nument);
        
        while cont == 0
            disp('Error: The number of FID files to be summed must be an integral number')
            numents = input(prompt,'s');
            nument = str2double(numents);
        
            cont = isint(nument);
        end
        
        dat = cell(nument,1);
        
        for el = 1:nument
            
            prompt1 = 'Enter a FID file to be summed: ';
            FIDh = input(prompt1,'s');
            cont = 0;
            
            while cont == 0
                try
                    readmatrix(FIDh);
                    cont = 1;
                catch
                    cont = 0;
                    disp('Error: File cannot be read')
                    FIDh = input(prompt1,'s');
                end
            end
            
            dat{el} = FIDh;
            
        end
        
    end
    
    %% Opening the .txt mRUI FID Files into an Array
    % The files are opened into an array individually. In the original
    % files, where there are lines stating when the next set of data
    % begins, upon being imported, they are read as 'NaN', so these lines
    % are then removed. Afterwards, the array is stored in an element in a
    % cell that contains all such matrices (one for each inputted file)

    numcoil = length(dat);
    FIDcell = cell(1,numcoil);
    [pointsPerSig,numSigs] = numofMeasurements(dat{1});
    
    for el = 1:numcoil
        FIDup = readmatrixrig(dat{el});
        len = pointsPerSig*numSigs;
        FIDp = removeNaNs(FIDup,len);
        FIDcell{el} = FIDp;
    end
    
    %% Defining the _rawSpectra_ Variable to be Passed into _svdReconstructFrequencyDomain_
    % The function that calculates the factors each spectrum should be
    % multiplied with before summation requires the phased frequency domain
    % data. Arbitrarily, the real frequency domain is chosen from each
    % inputted file and parsed into a column of the _rawSpectra_ array
    
    rawSpectra = zeros(len,numcoil);
    
    for el = 1:numcoil
        rawSpectra(:,el) = FIDcell{el}(:,3);
    end
    
    %% Defining the _noiseMask_ Variable to be Passed into _svdReconstructFrequencyDomain_
    % As stated above, to calculate the relative factor each inputted file
    % needs to multiplied with before summation, the
    % _svdReconstructFrequencyDomain_ function needs to know, which parts
    % of the function correspond to noise and which parts correspond to
    % signal. Odd indices in the _noiseind_ input define the index, where
    % noise begins in the data, while even indices in the _noiseind_ input
    % define the index in the inputted files, where noise ends and signal
    % begins. Where there is noise, those indices in noiseMask are set to
    % 1, and where there is signal, the indices are set to 0. Before being
    % passed into the weighting function, the array is converted into a
    % logical array
    
    noiseMask = zeros(pointsPerSig,1);
    
    noiseindbool = 0;
    
    if nargin == 2
        if isempty(noiseind) == 0
            if string(class(noiseind)) == "double"
                if isint(length(noiseind/2)) == 1
                    if sort(noiseind) == noiseind
                        noiseindbool = 1;
                    else
                        disp('Error: Invalid input. Default noise mask for 1-pyruvate will be used')
                    end
                else
                    disp('Error: Invalid input. Default noise mask for 1-pyruvate will be used')
                end
            else
                disp('Error: Invalid input. Default noise mask for 1-pyruvate will be used')
            end
        end
    end
    
    if noiseindbool == 0
        noiseind = [1 2000 2600 4096];
    end
    
    secs = length(noiseind)*0.5;
    sind = 1;
    eind = 2;
    
    for el = 1:secs
    
        for ele = noiseind(sind):noiseind(eind)
            noiseMask(ele) = 1;
        end
        
        sind = sind+2;
        eind = eind+2;
        
    end
    
    noiseMask = logical(noiseMask);
    noiseMask = repmat(noiseMask,numSigs);
    noiseMask = noiseMask(:,1);
    
    %% Calculating the Weighted Values of the Inputted Files and Summing the Multi-Channel Data
    % Every element within each .txt mRUI FID file is multiplied by the
    % weight factor calculated using WSVD. All of the FID files are then
    % summed together element by element
    
    [~,~,~,svdWeights] = svdReconstructFrequencyDomain(rawSpectra,noiseMask);
    
    for el = 1:numcoil
        FIDcell{el} = FIDcell{el}.*svdWeights(el);
    end
    
    FID = FIDcell{1};
    
    if numcoil > 1
        for el = 2:numcoil
            FID = FID+FIDcell{el};
        end
    end
    
    %% Writing the Outputted Summed Fid File
    
    writeToFIDtxt(dat{1},FID)
    
end

%% Notes
% The input used in the example was:
%%
% _dat_: {'Decay_DissolutionFID_1Pyr_09_12_19_even.txt',
% 'Decay_DissolutionFID_1Pyr_09_12_19_odd.txt'}
%%
% The example was run by putting:
%% 
% sumFIDs({'Decay_DissolutionFID_1Pyr_09_12_19_even.txt',
% 'Decay_DissolutionFID_1Pyr_09_12_19_odd.txt'})
%%
% into the command window