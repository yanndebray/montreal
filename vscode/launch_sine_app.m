%% Launch Montreal Weather Sine Fitting Application
% Simple launcher script for the Montreal Weather Sine Fitting App
%
% This script:
% 1. Adds the necessary paths
% 2. Launches the main application
% 3. Provides helpful information

% Display welcome message
fprintf('\n');
fprintf('╔════════════════════════════════════════════════════════════╗\n');
fprintf('║  MONTREAL WEATHER SINE FITTING APPLICATION                ║\n');
fprintf('╚════════════════════════════════════════════════════════════╝\n');
fprintf('\n');

% Get the directory of this script
scriptPath = fileparts(mfilename('fullpath'));

% Add to path if needed
if ~contains(path, scriptPath)
    addpath(scriptPath);
    fprintf('✓ Added %s to MATLAB path\n', scriptPath);
end

% Check if main app exists
appFile = fullfile(scriptPath, 'montreal_weather_sine_app.m');
if ~isfile(appFile)
    fprintf('✗ ERROR: Could not find montreal_weather_sine_app.m\n');
    fprintf('  Expected location: %s\n', appFile);
    return;
end

fprintf('✓ Found application file\n');
fprintf('\n');
fprintf('Features:\n');
fprintf('  • Sine fitting (default) for seasonal patterns\n');
fprintf('  • Linear regression for trend analysis\n');
fprintf('  • Polynomial regression (2-4 degree)\n');
fprintf('  • Montreal, Canada preset (+ 5 other cities)\n');
fprintf('  • Flexible date ranges (1-3 years)\n');
fprintf('  • Comprehensive statistics and visualizations\n');
fprintf('\n');
fprintf('Quick Start:\n');
fprintf('  1. Click "Montreal, Canada" (already selected)\n');
fprintf('  2. Click "1 year" for date range\n');
fprintf('  3. Keep "Sine" model selected\n');
fprintf('  4. Click "🔍 Analyze Weather with Sine Fitting"\n');
fprintf('\n');
fprintf('Documentation:\n');
fprintf('  • README_sine_app.md - Full documentation\n');
fprintf('  • QUICKSTART_sine_app.txt - Quick reference\n');
fprintf('  • example_montreal_sine_fitting.m - Code examples\n');
fprintf('\n');
fprintf('Launching application...\n');
fprintf('════════════════════════════════════════════════════════════\n');
fprintf('\n');

% Launch the main application
try
    montreal_weather_sine_app();
    fprintf('✓ Application launched successfully!\n');
catch ME
    fprintf('✗ ERROR launching application:\n');
    fprintf('  %s\n', ME.message);
    fprintf('\nStack trace:\n');
    for i = 1:length(ME.stack)
        fprintf('  In %s (line %d)\n', ME.stack(i).name, ME.stack(i).line);
    end
end
