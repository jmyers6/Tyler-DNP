%% Parsing the _flip1_ Parameter from a Procpar File into an Array
%%
%% Input
% _proc_: is a procpar file from an NMR experiment
%% Output
% _flip1_: is an array that contains the contents of the _flip1_ parameter
% in the procpar file
%% Child Function
% _readprocpar_: parses the contents of a procpar file into a structure
% array

function flip1 = flipAnglesFromProcpar(proc)

    %% Checking the Number of Inputs

    procbool = 1;
    
    if nargin < 1
        procbool = 0;
    end
    
    %% Parsing the Procpar File
    
    if procbool == 0
        procpar = readprocpar;
    else
        procpar = readprocpar(proc);
    end
    
    %% Extracting the _flip1_ Parameter
    
    flip1a = procpar.flip1;
    flip1 = transpose(flip1a);
    
end

%% Notes
% The input used in the example was:
% _proc_: 'procpar28_11_19_Dissolution'
% The example was run by putting:
%%
% flip1 = flipAnglesFromProcpar('procpar28_11_19_Dissolution')
%%
% into the command window