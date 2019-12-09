%% Verifying if a .txt AMARES Output File can be Processed
%% 
%% Input
% _inp_: is a .txt AMARES output file
%% Output
% _bool_: is 1 if the file can be processed, or it is 0 if the file cannot
% be processed
%% Child Functions
% _isdatfile_: checks if an input is a readible file
%%
% _loadJmruiAmares_: parses the .txt output from AMARES in JMRUI into a
% structure array

function bool = validateAMARES(inp)

    bool = 1;
    
    if nargin == 0
        bool = 0;
        disp('Error: No input entered')
    end
    
    boolf = isdatfile(inp);
    
    if boolf == 0
        bool = 0;
    end

    if boolf == 1
        try
            loadJmruiAmares(inp);
        catch
            disp('Error: Invalid file entered');
            bool = 0;
        end
    end
    
end

%% Notes
% The input used in the example is:
%%
% _inp_: 'Decay_Dissolution_17_10_19_even'
%%
% The example was run by putting:
%%
% bool = validateAMARES('Decay_Dissolution_17_10_19_even')
%%
% into the command window