%% Verifying if an Input is a File that Contains Lines
%%
%% Inputs
% _dat_: is a file, represented using a character vector
%% Outputs
% _bool_: is a boolean that is '1' if _dat_ is a file that contains lines.
% Otherwise, _bool_ is '0'.

function bool = isdatfile(dat)

    bool = 1;
    
    %% Checking if a File was Inputted
    % If no file was entered to set _dat_, the function will return _bool_
    % = 0 and state no file was inputted.
    
    if nargin < 1
        bool = 0;
        disp('Error: No file was inputted')
    end
    
    %% Checking if the Inputted File can be Opened
    % The functions checks if 'fopen' can open _dat_. If it cannot, the
    % function returns _bool_ = 0 and states the file cannot be opened.
    
    if nargin == 1

        try 
            fopen(dat);
        catch
            bool = 0;
            disp('Error: File cannot be opened')
        end
    
        %% Checking if the Inputted File Contains Lines
        % The function checks if 'fgetl' can read the inputted file. If 
        % 'fgetl' fails, _bool_ is set to 0, and the function states the 
        % file is either invalid or does not contain lines.
    
        try
            fid = fopen(dat);
            fgetl(fid);
        catch
            bool = 0;
            disp('Error: File is invalid and/or does not contain lines')
        end
    
    end
    
end

%% Notes
% The input used in the example is:
%%
% _dat_: 'Example'
%%
% The example was run by putting:
%%
% bool = isdatfile('Example')
%%
% into the command window