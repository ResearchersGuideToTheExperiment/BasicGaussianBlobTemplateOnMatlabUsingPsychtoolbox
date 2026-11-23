function results = main_gaussian_blob_template(screenSizeCm, distanceCm)
% MAIN_GAUSSIAN_BLOB_TEMPLATE Run a generic demonstration; results remain in memory.
% Supply measured active screen [width height] in cm and eye distance in cm.
% Example only: results = main_gaussian_blob_template([50 30], 60);
if nargin ~= 2
    error('Supply measured screen size [width height] cm and viewing distance cm.');
end
root = fileparts(mfilename('fullpath'));
oldPath = path;
pathGuard = onCleanup(@() path(oldPath)); %#ok<NASGU>
addpath(fullfile(root,'functions'));
% Validate calibration before opening the display.
create_geometry([1 1],screenSizeCm,distanceCm);
assert(exist('Screen','file') ~= 0, 'Install Psychtoolbox separately first.');
oldSync = Screen('Preference','SkipSyncTests',0);
displayGuard = onCleanup(@() cleanup_display(oldSync)); %#ok<NASGU>
[window,g,ifi] = open_display(screenSizeCm,distanceCm);
sigmaDeg = 0.35; % Gaussian standard deviation; support extends to +/-4 sigma.
seed = 1; % Reproducible demonstration, without modifying the caller's RNG state.
oldRng = rng; rngGuard = onCleanup(@() rng(oldRng)); %#ok<NASGU>
rng(seed,'twister');
results = struct('geometry',g,'refreshIntervalSec',ifi,'seed',seed,'sigmaDeg',sigmaDeg);
Screen('TextSize',window,24);
DrawFormattedText(window, 'Observe the Gaussian blobs.\n\nPress SPACE to start. ESC to stop.', ...
    'center','center',0);
Screen('Flip',window);
wait_for_space;
positions = [-4 2; 4 2; -4 -2; 4 -2];
positions = positions(randperm(size(positions,1)),:);
for trial = 1:size(positions,1)
    [im,rect] = gaussian_blob_image(g,positions(trial,:),sigmaDeg,1);
    texture = Screen('MakeTexture',window,im);
    timing = present_blob(window,texture,rect,g,0.6,ifi);
    results.trials(trial).positionDeg = positions(trial,:);
    results.trials(trial).timing = timing;
    Screen('Close',texture);
    wait_seconds(0.4);
end
end
