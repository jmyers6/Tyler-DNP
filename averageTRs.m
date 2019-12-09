%% Finding the Average Repetition Time Over a Section of Data
%%
%% Inputs
% _x_: is a column vector containing the times when measurements were taken
% in an NMR experiment
%%
% _secinds_: is a column vector containing the first indices of where each
% section in the data begins
%% Output
% _avTRs_: is a column vector containing the average repetition time (TR)
% of each section

function avTRs = averageTRs(x,secinds)

    secs = length(secinds);
    avTRs = zeros(secs,1);
    
    %% Calculating the Average Repetition Time
    % The average repetition time is calculated by taking the difference
    % between the last time point in a section and the first time point in
    % a section and dividing that by the number of time points in the
    % section
    
    for el = 1:secs
        if el ~= secs
            eind = secinds(el+1)-1;
            sind = secinds(el);
            xend = x(eind);
            xstart = x(sind);
            nument = eind-sind;
            xdif = xend-xstart;
            avTRs(el) = xdif/nument;
        else
            eind = length(x);
            sind = secinds(el);
            xend = x(end);
            xstart = x(sind);
            nument = eind-sind;
            xdif = xend-xstart;
            avTRs(el) = xdif/nument;
        end
    end
    
end

%% Notes
% The inputs used in the example were:
%%
% _x_: [1; 2; 3; 5; 7; 9]
%%
% _secinds_: [1;4]
%%
% The example was run by putting:
%%
% avTRs = averageTRs([1; 2; 3; 5; 7; 9],[1;4])
%%
% into the command window