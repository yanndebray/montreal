% Weather Data Linear Regression Analysis
% This script fetches historical weather data from Open-Meteo API
% and performs linear regression to analyze temperature trends

clear; clc;

%% 1. Fetch Weather Data from Open-Meteo API
fprintf('Fetching weather data from Open-Meteo API...\n');

% Define location (Paris, France as example)
latitude = 48.8566;
longitude = 2.3522;

% Define date range (last 90 days)
end_date = datetime('today');
start_date = end_date - days(90);

% Format dates for API
start_str = datestr(start_date, 'yyyy-mm-dd');
end_str = datestr(end_date, 'yyyy-mm-dd');

% Build API URL
url = sprintf(['https://archive-api.open-meteo.com/v1/archive?' ...
    'latitude=%.4f&longitude=%.4f&start_date=%s&end_date=%s&' ...
    'daily=temperature_2m_max,temperature_2m_min,precipitation_sum&' ...
    'timezone=auto'], latitude, longitude, start_str, end_str);

% Fetch data using webread
try
    data = webread(url);
    fprintf('Data fetched successfully!\n\n');
catch ME
    error('Failed to fetch data: %s', ME.message);
end

%% 2. Extract and Process Data
% Extract dates and temperatures
dates = datetime(data.daily.time, 'InputFormat', 'yyyy-MM-dd');
temp_max = data.daily.temperature_2m_max;
temp_min = data.daily.temperature_2m_min;
precipitation = data.daily.precipitation_sum;

% Calculate average daily temperature
temp_avg = (temp_max + temp_min) / 2;

% Create day numbers for regression (1, 2, 3, ...)
day_numbers = (1:length(dates))';

%% 3. Perform Linear Regression
fprintf('=== LINEAR REGRESSION ANALYSIS ===\n\n');

% Regression: Average Temperature vs Day Number
X = day_numbers;
Y = temp_avg;

% Calculate regression coefficients
p = polyfit(X, Y, 1); % Linear fit (degree 1)
slope = p(1);
intercept = p(2);

% Calculate predicted values
Y_pred = polyval(p, X);

% Calculate R-squared
SS_res = sum((Y - Y_pred).^2);
SS_tot = sum((Y - mean(Y)).^2);
R_squared = 1 - (SS_res / SS_tot);

% Display results
fprintf('Regression Equation: Temperature = %.4f * Day + %.4f\n', slope, intercept);
fprintf('Slope: %.4f °C/day\n', slope);
fprintf('Intercept: %.4f °C\n', intercept);
fprintf('R-squared: %.4f\n', R_squared);
fprintf('Temperature change over period: %.2f °C\n\n', slope * length(dates));

%% 4. Statistical Analysis
fprintf('=== STATISTICAL SUMMARY ===\n\n');
fprintf('Number of observations: %d days\n', length(dates));
fprintf('Average temperature: %.2f °C\n', mean(temp_avg));
fprintf('Min temperature: %.2f °C on %s\n', min(temp_avg), datestr(dates(temp_avg == min(temp_avg))));
fprintf('Max temperature: %.2f °C on %s\n', max(temp_avg), datestr(dates(temp_avg == max(temp_avg))));
fprintf('Standard deviation: %.2f °C\n', std(temp_avg));
fprintf('Total precipitation: %.2f mm\n\n', sum(precipitation));

%% 5. Create Visualization
figure('Position', [100, 100, 1200, 800]);

% Subplot 1: Temperature trend with regression line
subplot(2, 2, 1);
scatter(day_numbers, temp_avg, 30, 'filled', 'MarkerFaceAlpha', 0.6);
hold on;
plot(day_numbers, Y_pred, 'r-', 'LineWidth', 2);
xlabel('Day Number');
ylabel('Average Temperature (°C)');
title('Temperature Trend with Linear Regression');
legend('Actual Temperature', sprintf('Linear Fit (R² = %.3f)', R_squared), 'Location', 'best');
grid on;
hold off;

% Subplot 2: Temperature over time
subplot(2, 2, 2);
plot(dates, temp_max, 'r-', 'LineWidth', 1.5);
hold on;
plot(dates, temp_min, 'b-', 'LineWidth', 1.5);
plot(dates, temp_avg, 'k-', 'LineWidth', 2);
xlabel('Date');
ylabel('Temperature (°C)');
title('Daily Temperature Variations');
legend('Max Temp', 'Min Temp', 'Avg Temp', 'Location', 'best');
grid on;
hold off;

% Subplot 3: Residuals plot
subplot(2, 2, 3);
residuals = Y - Y_pred;
scatter(Y_pred, residuals, 30, 'filled');
hold on;
yline(0, 'r--', 'LineWidth', 2);
xlabel('Predicted Temperature (°C)');
ylabel('Residuals (°C)');
title('Residual Plot');
grid on;
hold off;

% Subplot 4: Precipitation
subplot(2, 2, 4);
bar(dates, precipitation, 'FaceColor', [0.2, 0.6, 0.8]);
xlabel('Date');
ylabel('Precipitation (mm)');
title('Daily Precipitation');
grid on;

% Adjust layout
sgtitle(sprintf('Weather Analysis: %s to %s (Paris, France)', ...
    datestr(start_date, 'dd-mmm-yyyy'), datestr(end_date, 'dd-mmm-yyyy')), ...
    'FontSize', 14, 'FontWeight', 'bold');

fprintf('Visualization created successfully!\n');
fprintf('\nAnalysis complete.\n');
