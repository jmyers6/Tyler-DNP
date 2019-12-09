%% Parsing a File Containing Comma Delimited Data
%%
%% Input
% _dat_: is a file containing comma delimited data
%% Output
% _data_: is an array, where each line has data that was formerly comma
% delimited in separate cells

function data = parsedat(dat)

    trut = 1;
    
    fid = fopen(dat);
    
    data = []; 
    
    %% Parsing the File
    % The file is read line by line using the 'fgetl' function. When the
    % file runs out of lines, 'fgetl' returns -1, which leads the loop
    % reading the file to terminate. Otherwise, the current line is checked
    % for the prescence of a ',' indicating the prescence of comma
    % delimited data. If a ',' is found, the line is converted to a number
    % and appended to the _data_ array.
    
    while trut == 1 
        
        line = fgetl(fid);
        
        if line == -1 
            
            trut = 0;
            
        else
            
            comfind = strfind(line, ','); 
            write = isempty(comfind);
            
            if write == 0 
                vals = str2num(line); 
                D = [data;vals]; 
                data = D; 
            end
            
        end
        
    end
    
    fclose(fid);
    
end

%% Notes
% The input used in the example is:
%%
% _dat_: '1Pyr_8_10.dat'
%%
% The example was run by putting:
%%
% data = parsedat('1Pyr_8_10.dat') 
%%
% into the command window