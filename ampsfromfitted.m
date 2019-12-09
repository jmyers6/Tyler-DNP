%% Determining the Amplitudes of a Peak from an AMARES Output
%%
% The output of processAMARES, loadJmruiAmares, processAMARESSweep and 
% summestrenova is a structure array that separates data by peak. In the 
% case of the first function, the structure array has dimensions 
% corresponding to how many AMARES .txt output files were used to construct 
% it. The ampsfromfitted function allows for pulling out the amplitudes 
% from a specific AMARES output file and from a specific peak in the 
% _fitted_ structure array.
%% Inputs
% _fitted_: is the structure array output of one of the following
% functions: loadJmruiAmares, processAMARES, processAMARESSweep or
% summestrenova
%%
% _numar_: is the index of the AMARES file to extract the amplitudes from
%%
% _peaknum_: is the index of the peak from which to extract the amplitudes
% from
%% Outputs
% _amps_: is a column vector of the amplitudes from an AMARES file and peak
% of interest
%%
% _peaknames_: are the names of the peaks in the _fitted_ structure array
% inside a cell
%%
% _numpeak_: is the number of peaks inside the _fitted_ structure array
%% Child Functions
% _isint_: checks if in input is an integer
%%
% _processAMARES_: parses multiple .txt outputs from AMARES in JMRUI into a
% structure array
%%
% _summestrenova_: parses a .csv custom integration file from MestReNova
% into a structure array

function [amps,peaknames,numpeak] = ampsfromfitted(fitted,numar,peaknum)

    %% Verifying if _fitted_ is Valid
    % If no _fitted_ input is given or the _fitted_ input is not a
    % structure array, _fitted_ must be generated. Likewise, if _fitted_ 
    % is a structure array but does not have the correct format, _fitted_
    % must be generated.

    fittedbool = 1;
    
    if nargin < 1
        fittedbool = 0;
    elseif string(class(fitted)) ~= "struct"
        fittedbool = 0;
    elseif string(class(fitted)) == "struct" 
        try
            peakst = fitted(1).dataByPeak;
            peaksct = struct2cell(peakst);
            ampst = peaksct{1}.Amplitudes;
        catch
            fittedbool = 0;
        end
    end
    
    %% Generating _fitted_ if Invalid or Insufficient Input
    % If no _fitted_ input was given, or if _fitted_ is not valid, either
    % processAMARES or summestrenova is run to generate _fitted_.
    
    if fittedbool == 0
        
        prompt = 'Is the data from an AMARES output or a MestReNova integration output? (A/M): ';
        inp = input(prompt,'s');
        inpbool = 0;
        
        while inpbool == 0
            
            inpbool = checkinp(inp);
            
            if inpbool == 0
                inp = input(prompt,'s');
            end
            
        end
        
        if inpbool == 1
            fitted = processAMARES;
        elseif inpbool == 2
            fitted = summestrenova;
        end
        
    end

    numara = length(fitted);
    
    %% Setting the File and Peak to Draw Amplitudes from
    % If no AMARES file and/or if no peak is specified, the outputted
    % amplitudes will be from the first AMARES file and the first peak in
    % _fitted_
    
    if nargin < 2
        numar = 0;
    end
    
    if nargin < 3
        peaknum = 1;
    end
    
    %% Notifying the User if _numar_ and/or _peaknum_ Inputs are Invalid
    % If _numar_ or _peaknum_ are outside of the size of _fitted_, the
    % default amplitudes will be outputted and a message displayed
    % notifying the user of this.
    
    if isint(numar) ~= 1
        numar = 0;
    elseif numar > numara
        numar = 0;
        disp('Requested set of amplitudes does not exist; the first set of amplitudes for the requested peak have been given instead')
    end  

    amps = 0;
    
    peaks = fitted(1).dataByPeak;
    peaknames = fieldnames(peaks); 
    peaksc = struct2cell(peaks);
    numpeak = length(peaksc); 
    
    if isint(peaknum) ~= 1
        peaknum = 1;
    elseif peaknum > numpeak
        peaknum = 1;
        disp('Requested peak does not exist; the amplitudes for the first peak have been given instead')
    end
    
    if numar == 0
        for el = 1:numara
            peaks = fitted(el).dataByPeak;
            peaksc = struct2cell(peaks);
            ampsn = peaksc{peaknum}.Amplitudes;
            amps = amps+ampsn;
        end
    else
        peaks = fitted(numar).dataByPeak;
        peaksc = struct2cell(peaks);
        amps = peaksc{peaknum}.Amplitudes;
    end
      
end

%% Notes
% The inputs used in the example are:
%%
% _fitted_: The output of using processAMARES on 
% 'Decay_Dissolution_17_10_19_even.txt' and 
% 'Decay_Dissolution_17_10_19_odd.txt'
%%
% _numar_: 2
%%
% _peaknum_: 1
%%
% The example was run by putting:
%%
% [amps,peaknames,numpeak] = ampsfromfitted(fitted,2,1)
%%
% into the command window.