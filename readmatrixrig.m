%% Reading a .csv File into an Array
%%
% MATLAB's _readmatrix_ function is very prone to throwing exceptions. For
% functions that require reading a .csv file, this function is able to
% prevent parent functions from throwing an exception.
%% Input
% _csv_: is the .csv file to be processed into an array
%% Output
% _array_: is the array created by _readmatrix_

function array = readmatrixrig(csv)

    %% Verifying that _csv_ Exists and is Readable by _readmatrix_

    bool = 0;
    csvbool = 1;

    if nargin ~= 1
        csvbool = 0;
    end
    
    while bool == 0
        
        bool = 1;
        
        prompt = 'Enter a .csv file containing the data to be arrayed: ';
        
        if csvbool == 0
            csv = input(prompt,'s');
        end

        try 
            readmatrix(csv);
        catch
            disp('Invalid file entered')
            csvbool = 0;
            bool = 0;
        end
        
    end
    
    array = readmatrix(csv);
    
end

%% Notes
% The input used in the example is:
%%
% _csv_: 'micval21_11_19.csv'
%%
% The example was run by putting:
%%
% array = readmatrixrig('micval27_11_19.csv')
%%
% into the command window.