% Reconstruct optimum spectrum from a phased array
%
% [svdRecombination, svdQuality, svdCoilAmplitudes, svdWeights] = svdReconstructFrequencyDomain(rawSpectra, noiseMask, ...)
%
% rawSpectra must be an N x M matrix (N = frequency points, M = receive array elements)
% noiseMask must be an N x 1 logical matrix (N = frequency points).
%           true --> this point is baseline noise.
%           false --> this point contains signal.

% Copyright Chris Rodgers, University of Oxford, 2008.
% $Id: svdReconstructFrequencyDomain.m 8164 2014-12-16 10:31:48Z will $
%% Child Functions
% normalise: normalises an input
%% Example Input
% _rawSpectra_: are the real values from the frequency domains of the
% phased FID files from the 'Decay_DissolutionFID_1Pyr_09_12_19_even.txt'
% and 'Decay_DissolutionFID_1Pyr_09_12_19_odd.txt' files
%%
% _noiseMask_: is a (4096x60) x 1 logical array, where for every set of
% 4096 (which is the number of points measured per signal in the FID files)
% points 1-2000 and 2600-4096 are 1, since they are noise and the rest are
% 0, since they are signal.
%%
% The example was run by putting:
%%
% [~, svdQuality, svdCoilAmplitudes, svdWeights] = 
% svdReconstructFrequencyDomain(rawSpectra, noiseMask)
%%
% into the command window (the first variable was not ouputted in the
% example, since it is over 200 000 lines long)

function [svdRecombination, svdQuality, svdCoilAmplitudes, svdWeights] = svdReconstructFrequencyDomain(rawSpectra, noiseMask, varargin)

if nargin<3
    options = struct();
elseif nargin==3
    options = varargin{1};
else
    % Wrap any cell arrays before passing in to struct()
    for idx=2:2:numel(varargin)
        if iscell(varargin{idx})
            varargin{idx} = {varargin{idx}};
        end
    end
    
    options = struct(varargin{:});
end

if ~isfield(options,'debug')
    options.debug = 0;
end

if ~isfield(options,'phaseRefChannel')
    options.phaseRefChannel = 1;
end

if numel(size(rawSpectra))>2
    error('rawSpectra must be an N x M matrix (N = frequency points, M = receive array elements)')
end

%% Allocate storage for some results
%sizeSpectra = size(rawSpectra,1);
nCoils = size(rawSpectra,2);

%% Measure noise statistics from data (unless instructed otherwise)
if isfield(options,'noiseCov') && ~ischar(options.noiseCov)
  % Noise covariance matrix has been supplied
  noiseCov=options.noiseCov;
elseif isfield(options,'noiseCov') && strcmp(options.noiseCov,'disable')
    % Disable noise prewhitening
    noiseCov=eye(nCoils)*0.5;
elseif isfield(options,'noiseCov') && strcmp(options.noiseCov,'diag')
    % Use only the noise variances (not off diagonal elements)...
    noiseCov=diag(diag(cov(rawSpectra(noiseMask,:))));
elseif ~isfield(options,'noiseCov') || strcmp(options.noiseCov,'normal')
    % Estimate from data (DEFAULT)
    noiseCov=cov(rawSpectra(noiseMask,:));
else
    error('Option "noiseCov" has an unknown value.')
end

[noiseVec, noiseVal] = eig(noiseCov);

% (This formula is a simple adaptation of that in
% testNoiseUncorrelationNmrFft2.m, adding sim.imagingFrequency to the mix.)
scaleMatrixFft = noiseVec*diag(sqrt(0.5)./sqrt(diag(noiseVal)));
invScaleMatrixFft = inv(scaleMatrixFft);

scaledSpectra=rawSpectra*scaleMatrixFft;

if options.debug
    disp('DEBUG: Please confirm that this matrix is approximately 0.5*eye(nCoils)')
    cov(scaledSpectra(noiseMask,:))
    
    disp('Noise covariance matrix eigenvalues:')
    disp(noiseVal)

    figure(9);clf;mypcolor(1:nCoils,1:nCoils,abs(noiseCov));colorbar
    set(gca,'YTick',1:nCoils,'YTickLabel',options.coilNames,...
        'XTick',1:nCoils,'XTickLabel',options.elementNames)
end

%% Compute optimal reconstruction using SVD
[u,s,v]=svd(scaledSpectra,'econ');
% SVD quality indicator
svdQuality(1) = ((s(1,1)/norm(diag(s)))*sqrt(nCoils)-1)/(sqrt(nCoils)-1);

% Coil amplitudes
svdCoilAmplitudes=v(:,1)'*invScaleMatrixFft;
% There's an arbitrary scaling here such that the first coil weight is
% real and positive


 

% Option to set a arbitrary rescaling phase which overides that of the
% arbitrary choice of the first element.
if isfield(options,'overideRescalePhase')
    svdRescale = norm(svdCoilAmplitudes)*exp(1i*options.overideRescalePhase);
else
    svdRescale = norm(svdCoilAmplitudes)*normalise(svdCoilAmplitudes(options.phaseRefChannel));
end


svdCoilAmplitudes=svdCoilAmplitudes / svdRescale;

if options.debug
    fprintf('DEBUG: SVD quality indicator = %g\n',svdQuality);
    fprintf('SVD coil amplitudes:\n');
    disp(svdCoilAmplitudes)
end

svdRecombination = u(:,1)*s(1,1)*svdRescale;

%% Added 2 Feb 2014:
% svdWeights = 0.5*svdCoilAmplitudes'*inv(noiseCov) * conj(svdRephase) * svdRephase; % V4 version. Fails. Wrong matrix sizes.

svdWeights = 0.5*inv(noiseCov) * svdCoilAmplitudes' * conj(svdRescale) * svdRescale; % Try this. Not derived carefully. But tested numerically and it gives the same answer to within 1e-15.
