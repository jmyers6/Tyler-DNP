%% Generating a Scatter Plot from Comma Delimited Data
%%
% Generates a scatter plot from a .dat file (_dat_ variable)
% (works for any comma delimited data) from Oxford Hypersense to show 
% signal strength as a function of time
%% Inputs
% _dat_: is a file containing lines with comma delimited data
%%
% _xlab_: is the x-axis label on the outputted scatter plot (character
% vector)
%%
% _ylab_: is the y-axis label on the ouputted scatter plot (character
% vector)
%%
% _titl_: is the title on the outputted scatter plot (character vector)
%% Outputs
% _x_: is a column vector containing the x-values of the plotted data
%%
% _y_: is a column vector containing the y-values of the plotted data
%% Child Functions
% _isdatfil_: checks if an input is a readible file
%%
% _parsedat_: parses files containing data that is comma delimited
%%
% _ischarvec_: checks if an input is a character vector

function [x,y] = hyperscatter(dat,xlab,ylab,titl)

    %% Calling the User if There are Insufficient or Invalid Inputs
    % The function requires a file from which data will be plotted from, 
    % so it will call for user input if the input is invalid or not entered
    
    trut = 1;
    
    while trut == 1
        
        trut = 0;
    
        if nargin < 1
            
            prompt = 'Enter a comma delimited data file to plot: ';
            dat = input(prompt,'s');
            
            bool = isdatfile(dat);
            
            if bool == 0
                trut = 1;
            end
    
        elseif isempty(dat) == 1 
            
            prompt = 'Enter a comma delimited data file to plot: ';
            dat = input(prompt,'s');
            
            bool = isdatfile(dat);
            
            if bool == 0
                trut = 1;
            end
            
        else
            
            bool = isdatfile(dat);
            
            if bool == 0
                
                prompt = 'Enter a valid comma delimited data file to plot: ';
                dat = input(prompt,'s');
                
                booln = isdatfile(dat);
                
                if booln == 0
                    trut = 1;
                end
                
            end
            
        end
        
    end
    
    %% Parsing a File with Comma Delimited Data
    % _dat_ is parsed using the _parsedat_ function
    
    data = parsedat(dat);
    x = data(:,1); 
    y = data(:,2);
    
    %% Creating a Scatter Plot
    % Creates a scatter plot of the second column of data in the file vs. 
    % the first column. If valid values (character vectors) have been
    % assigned to _xlab_, _ylab_ and/or _titl_, they will appear on the 
    % plot as the x-axis label, y-axis label and title respectively.
        
    if nargin >= 2
        xlabbool = ischarvec(xlab);
    end
        
    if nargin >= 3
        ylabbool = ischarvec(ylab);
    end
        
    if nargin == 4
        titlbool = ischarvec(titl);
    end
        
    figure('Position',[0 0 600 450])
    scatter(x,y,'filled')
        
    if xlabbool == 1
        xlabel(xlab)
    end
        
    if ylabbool == 1
        ylabel(ylab)
    end
        
    if titlbool == 1
        title(titl)
    end
    
end

%% Notes
% The inputs used in the example are:
%%
% _dat_: '1Pyr_7_10_sweep.dat'
%%
% _xlab_: 'Frequency /GHz'
%%
% _ylab_: 'Signal Strength / Arbitrary Units'
%%
% _titl_: 'Frequency Sweep of ^{13}C 1-Pyruvate 7/10/19'
%%
% The above example was run by putting:
%%
% [x,y] = hyperscatter('1Pyr_7_10_sweep.dat','Frequency /GHz','Signal 
% Strength / Arbitrary Units',
% 'Frequency Sweep of ^{13}C 1-Pyruvate 7/10/19')
%%
% in the command window
