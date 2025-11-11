%% Montreal Weather Sine Fitting - Example Usage
% This script demonstrates how to launch and use the Montreal Weather Sine App
% For GUI-based analysis, simply run: montreal_weather_sine_app

%% Example 1: Launch the Application
% Simply run the main function to open the GUI
fprintf('Example 1: Launching the Montreal Weather Sine App...\n');
fprintf('Run: montreal_weather_sine_app\n\n');

% Uncomment to launch:
% montreal_weather_sine_app

%% Example 2: Programmatic Sine Fitting (without GUI)
% This example shows how to perform sine fitting on weather data programmatically

clear; clc;
fprintf('Example 2: Programmatic Sine Fitting on Montreal Weather Data\n');
fprintf('=============================================================\n\n');

% Parameters
latitude = 45.5017;  % Montreal
longitude = -73.5673;
cityName = 'Montreal, Canada';

% Date range (1 year for good seasonal cycle)
end_date = datetime('today');
start_date = end_date - days(365);
start_str = datestr(start_date, 'yyyy-mm-dd');
end_str = datestr(end_date, 'yyyy-mm-dd');

fprintf('Fetching weather data for %s...\n', cityName);
fprintf('Date range: %s to %s\n\n', start_str, end_str);

% Fetch data from Open-Meteo API
url = sprintf(['https://archive-api.open-meteo.com/v1/archive?' ...
    'latitude=%.4f&longitude=%.4f&start_date=%s&end_date=%s&' ...
    'daily=temperature_2m_max,temperature_2m_min,precipitation_sum&timezone=auto'], ...
    latitude, longitude, start_str, end_str);

try
    opts = weboptions('Timeout', 30);
    data = webread(url, opts);
    fprintf('✓ Data fetched successfully!\n\n');
catch ME
    error('Failed to fetch data: %s', ME.message);
end

% Extract data
dates = datetime(string(data.daily.time), 'InputFormat', 'yyyy-MM-dd');
tempMax = double(data.daily.temperature_2m_max(:));
tempMin = double(data.daily.temperature_2m_min(:));
tempAvg = (tempMax + tempMin) / 2;
dayNumbers = (1:numel(dates))';

%% Sine Model Fitting
fprintf('Fitting Sine Model...\n');

% Initial parameter estimates
meanTemp = mean(tempAvg);
amplitude0 = (max(tempAvg) - min(tempAvg)) / 2;
period0 = 365.25;
phase0 = 0;

% Define sine model
sineModel = @(p, t) p(1) * sin(2*pi*t/p(2) + p(3)) + p(4);

% Optimization
options = optimset('Display', 'off', 'MaxIter', 10000);
initialParams = [amplitude0, period0, phase0, meanTemp];
costFunc = @(p) sum((tempAvg - sineModel(p, dayNumbers)).^2);
fittedParams = fminsearch(costFunc, initialParams, options);

% Extract parameters
amplitude = abs(fittedParams(1));
period = abs(fittedParams(2));
phase = fittedParams(3);
offset = fittedParams(4);

% Predictions
tempPred = sineModel(fittedParams, dayNumbers);

% Calculate metrics
ssRes = sum((tempAvg - tempPred).^2);
ssTot = sum((tempAvg - mean(tempAvg)).^2);
rSquared = 1 - ssRes / ssTot;
rmse = sqrt(mean((tempAvg - tempPred).^2));

%% Display Results
fprintf('\n═══ SINE MODEL RESULTS ═══\n\n');
fprintf('Model Equation:\n');
fprintf('T(t) = %.2f·sin(2π·t/%.1f + %.2f) + %.2f\n\n', ...
    amplitude, period, phase, offset);

fprintf('Model Parameters:\n');
fprintf('  Amplitude: %.2f °C\n', amplitude);
fprintf('  Period: %.1f days (%.2f years)\n', period, period/365.25);
fprintf('  Phase: %.2f radians\n', phase);
fprintf('  Offset: %.2f °C\n\n', offset);

fprintf('Goodness of Fit:\n');
fprintf('  R²: %.4f (%.1f%% variance explained)\n', rSquared, rSquared*100);
fprintf('  RMSE: %.2f °C\n\n', rmse);

fprintf('Interpretation:\n');
fprintf('  • Temperature varies by ±%.2f°C around %.2f°C\n', amplitude, offset);
fprintf('  • Warmest period: %.0f days after start of year\n', ...
    mod(-phase * period / (2*pi), period));
fprintf('  • Seasonal cycle repeats every %.1f days\n\n', period);

%% Visualization
fprintf('Creating visualizations...\n');

figure('Position', [100, 100, 1400, 900], 'Name', 'Montreal Weather Sine Fitting Analysis');

% Subplot 1: Fitted Model
subplot(2, 2, 1);
scatter(dayNumbers, tempAvg, 20, 'filled', 'MarkerFaceAlpha', 0.5);
hold on;
plot(dayNumbers, tempPred, 'r-', 'LineWidth', 2.5);
xlabel('Day Number');
ylabel('Average Temperature (°C)');
title(sprintf('Sine Model Fit for %s (R² = %.4f)', cityName, rSquared));
legend('Actual Temperature', 'Sine Fit', 'Location', 'best');
grid on;
hold off;

% Subplot 2: Time Series
subplot(2, 2, 2);
plot(dates, tempMax, 'r-', 'LineWidth', 1.5);
hold on;
plot(dates, tempMin, 'b-', 'LineWidth', 1.5);
plot(dates, tempAvg, 'k-', 'LineWidth', 2);
plot(dates, tempPred, 'm--', 'LineWidth', 2);
xlabel('Date');
ylabel('Temperature (°C)');
title('Temperature Time Series with Sine Fit');
legend('Max', 'Min', 'Avg', 'Sine Fit', 'Location', 'best');
grid on;
hold off;

% Subplot 3: Residuals
subplot(2, 2, 3);
residuals = tempAvg - tempPred;
scatter(tempPred, residuals, 30, 'filled', 'MarkerFaceAlpha', 0.6);
hold on;
yline(0, 'r--', 'LineWidth', 2);
xlabel('Predicted Temperature (°C)');
ylabel('Residuals (°C)');
title(sprintf('Residual Plot (RMSE = %.2f°C)', rmse));
grid on;
hold off;

% Subplot 4: Residual Histogram
subplot(2, 2, 4);
histogram(residuals, 20, 'FaceColor', [0.3, 0.6, 0.9]);
xlabel('Residuals (°C)');
ylabel('Frequency');
title('Residual Distribution');
grid on;

fprintf('✓ Analysis complete!\n');

%% Example 3: Compare Multiple Models
fprintf('\n\nExample 3: Comparing Multiple Models\n');
fprintf('=====================================\n\n');

% Linear model
pLinear = polyfit(dayNumbers, tempAvg, 1);
tempPredLinear = polyval(pLinear, dayNumbers);
rSquaredLinear = 1 - sum((tempAvg - tempPredLinear).^2) / sum((tempAvg - mean(tempAvg)).^2);
rmseLinear = sqrt(mean((tempAvg - tempPredLinear).^2));

% Polynomial (2nd degree)
pPoly2 = polyfit(dayNumbers, tempAvg, 2);
tempPredPoly2 = polyval(pPoly2, dayNumbers);
rSquaredPoly2 = 1 - sum((tempAvg - tempPredPoly2).^2) / sum((tempAvg - mean(tempAvg)).^2);
rmsePoly2 = sqrt(mean((tempAvg - tempPredPoly2).^2));

% Display comparison
fprintf('Model Comparison:\n');
fprintf('┌─────────────────┬──────────┬───────────┐\n');
fprintf('│ Model           │ R²       │ RMSE (°C) │\n');
fprintf('├─────────────────┼──────────┼───────────┤\n');
fprintf('│ Sine            │ %.4f   │ %.2f      │\n', rSquared, rmse);
fprintf('│ Linear          │ %.4f   │ %.2f      │\n', rSquaredLinear, rmseLinear);
fprintf('│ Polynomial (2°) │ %.4f   │ %.2f      │\n', rSquaredPoly2, rmsePoly2);
fprintf('└─────────────────┴──────────┴───────────┘\n\n');

% Determine best model
[bestRSquared, bestIdx] = max([rSquared, rSquaredLinear, rSquaredPoly2]);
modelNames = {'Sine', 'Linear', 'Polynomial (2nd degree)'};
fprintf('Best model: %s (R² = %.4f)\n', modelNames{bestIdx}, bestRSquared);

% Visualization comparing all models
figure('Position', [150, 150, 1200, 600], 'Name', 'Model Comparison');

subplot(1, 2, 1);
scatter(dayNumbers, tempAvg, 15, 'k', 'filled', 'MarkerFaceAlpha', 0.3);
hold on;
plot(dayNumbers, tempPred, 'r-', 'LineWidth', 2);
plot(dayNumbers, tempPredLinear, 'b-', 'LineWidth', 2);
plot(dayNumbers, tempPredPoly2, 'g-', 'LineWidth', 2);
xlabel('Day Number');
ylabel('Average Temperature (°C)');
title('Model Comparison');
legend('Data', sprintf('Sine (R²=%.3f)', rSquared), ...
    sprintf('Linear (R²=%.3f)', rSquaredLinear), ...
    sprintf('Poly2 (R²=%.3f)', rSquaredPoly2), 'Location', 'best');
grid on;
hold off;

subplot(1, 2, 2);
bar([rSquared, rSquaredLinear, rSquaredPoly2]);
set(gca, 'XTickLabel', modelNames);
ylabel('R² Score');
title('Model Fit Quality Comparison');
ylim([0, 1]);
grid on;

fprintf('\n✓ Model comparison complete!\n\n');

%% Summary
fprintf('═══ SUMMARY ═══\n\n');
fprintf('To use the interactive GUI application, run:\n');
fprintf('  montreal_weather_sine_app\n\n');
fprintf('Key Features:\n');
fprintf('  • Sine fitting (default) - best for seasonal patterns\n');
fprintf('  • Linear regression - for trend analysis\n');
fprintf('  • Polynomial fitting - for complex patterns\n');
fprintf('  • Interactive city selection\n');
fprintf('  • Flexible date ranges\n');
fprintf('  • Comprehensive visualizations\n\n');
fprintf('For more information, see README_sine_app.md\n');
