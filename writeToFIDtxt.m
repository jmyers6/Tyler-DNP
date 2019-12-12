%% Editing a .txt mRUI File that Can be Opened by JMRUI
%%
% In cases where only all of the data in a file needs to be replaced, but
% none of the words, such as when summing data from multiple channels, this
% function uses one of the files to be summed as a base and replaces all of
% the data in it using the information stored in an inputted array
%% Inputs
% _fid_: is a .txt mRUI file to be used as a base for building the new
% file. It must have the same number of signals as the file being made
%%
% _array_: is a numeric array where the columns from left to right store
% the: real data in the time domain, imaginary data in the time domain,
% real data in the frequency domain and imaginary data in the frequency
% domain that will be used to replace the data stored in the base file
% (_fid_)
%%
% _pointsPerSig: is the number of measurements per signal
%% Output
% A .txt mRUI file that is openable by JMRUI is made that contains the data
% from the _array_ input
%% Child Functions
% _numofMeasurements_: determines the number of measurements taken per
% signal and the number of signals in the inputted FID file

function writeToFIDtxt(fid,array)

    %% Verifying Sufficient and Valid Inputs
    % The _array_ input is nearly always large, so if it is not valid, the
    % function will terminate.

    fidbool = 1;
    
    if nargin < 2
        disp('Error: No replacement data entered in array. Terminating')
        return
    elseif string(class(array)) ~= "double"
        disp('Error: Invalid replacement array. Terminating')
        return
    elseif isdatfile(fid) == 0
        disp('Error: Invalid file entered')
        fidbool = 0;
    end
    
    if fidbool == 0
        cont = 0;
        while cont == 0
            fid = input('Input a valid .txt mRUI file to act as a base for the new data','s');
            try
                readmatrix(fid)
                cont = 1;
            catch
                disp('Error: Invalid file entered')
                cont = 0;
            end
        end
    end

    pointsPerSig = numofMeasurements(fid);

    fin = fopen(fid,'r');
    
    fidlen = length(fid);
    fidlooplen = fidlen-4;
    
    fidf = [];
    
    %% Writing the Name of the Output File
    % The output file is named the same as the input base file, _fid_,
    % except before the extension, the word 'Final' is added
    
    for el = 1:fidlooplen
        temstr = strcat(fidf,fid(el));
        fidf = temstr;
    end
    
    fidout = strcat(fidf,'Final.txt');
    
    fout = fopen(fidout,'w');
    
    %% Preventing Addition of a Return in the Outputted File
    % The outputted file is written line by line, so to prevent an extra
    % return at the end of the file, the file is read one line ahead of the
    % line to be written, so the function knows which line is the last line
    % before the last line is reached
    
    linestore = fgetl(fin);
    
    arrayind = 1;
    
    trut = 1;
    tr = 0;
    
    %% Ignoring the First Two Occurences of Signal
    % The data in _array_ is added to the output file the line after an
    % occurence of the word 'Signal'. However, the first two occurences of
    % the word are in the preamble, so they should be ignored
    
    while trut == 1
        
        line = fgetl(fin);
        
        if contains(linestore,'Signal') == 1
            if tr == 1
                trut = 0;
            else
                tr = 1;
            end
        end
        
        fprintf(fout,'%s\n',linestore);
        linestore = line;
        
    end
    
    %% Appending Data from the Input Array into the Output File
    % Data in the _array_ matrix is appended to the output file after lines
    % containing the word 'Signal'. When the word 'Signal' is found, the
    % function is primed to begin appending data by setting _readarray_ to
    % 1. This indicates that starting from the following line, data should
    % be read from _array_ into the output file. _arrayind_ indicates the
    % row in _array_ that should be written into the output file. _count_
    % keeps track of how many entries have been sent to be written into the
    % output file. When _count_ equals the number of measurements per
    % signal, _readarray_ is reset to 0 to prevent the array from
    % continuing to be written into the output file until the next
    % occurence of the word 'Signal'. When the end of the file is reached,
    % 'line' equals -1, which indicates that when 'linestore' is appended
    % to the output file, no return should be added.
    
    tru = 1;
    readarray = 0;
    count = 0;
    
    while tru == 1
        
        line = fgetl(fin);
        
        if contains(linestore,'Signal') == 1
            readarray = 1;
        end
        
        if readarray == 2
            
            linout = array(arrayind,:);
            linestore = num2str(linout,'%.4E\t');
            arrayind = arrayind+1;
            count = count+1;
            
            if count == pointsPerSig
                count = 0;
                readarray = 0;
            end
            
        end
        
        if line == -1
            tru = 0;
            fprintf(fout,'%s',linestore);
        else
            fprintf(fout,'%s\n',linestore);
            linestore = line;
        end
        
        if readarray == 1
            readarray = 2;
        end
        
    end
    
    fclose(fin);
    fclose(fout);
    
end

%% Notes
% The inputs used in the example were:
%%
% _fid_: 'Decay_DissolutionFID_1Pyr_09_12_19_even.txt'
%%
% _array_: The result of summing the above example for _fid_ with 
% 'Decay_DissolutionFID_1Pyr_09_12_19_odd.txt'
%%
% The example was run by putting
%%
% writeToFIDtxt('Decay_DissolutionFID_1Pyr_09_12_19_even.txt',array)
%% 
% into the command window
            