%% Determining the Repetition Time(s) from an NMR Procpar File
%%
%% Input
% _proc_: is a procpar file
%% Output
% _TR_: is the repetition time value(s) stored in the tr parameter in the
% _proc_ input
%% Child Functions
% _readprocpar_: parses the procpar file from an NMR experiment into a
% structure array

function TR = TRfromProcpar(proc)

    procbool = 0;
    
    %% Verifying There are Sufficient Inputs
    % In order to run TRfromProcpar, it requires one input

    if nargin == 1
        procbool = 1;
    end
    
    if procbool == 1
        procpar = readprocpar(proc);
    else
        procpar = readprocpar;
    end
    
    TR = procpar.tr;
    
end

%% Notes
% The input used in the example is:
%%
% _proc_: 'procpar17_10_19'
%%
% The example was run by putting:
%%
% TR = TRfromProcpar('procpar17_10_19') 
%%
% into the command window.