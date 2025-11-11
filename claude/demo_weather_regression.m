% Demo script to test weather data fetching and regression
% This demonstrates the functionality without the GUI

clear; clc;

fprintf('=== Montreal Weather Data Linear Regression Demo ===\n\n');

% Set date range (last 30 days)
endDate = datetime('today');
startDate = endDate - days(30);

fprintf('Fetching weather data for Montreal...\n');
fprintf('Date range: %s to %s\n', datestr(startDate), datestr(endDate));

% Format dates for API
startDateStr = datestr(startDate, 'yyyy-mm-dd');
endDateStr = datestr(endDate, 'yyyy-mm-dd');

% Montreal coordinates
lat = 45.5017;
lon = -73.5673;

% Build API URL for Open-Meteo (free, no API key needed)
apiUrl = sprintf(['https://archive-api.open-meteo.com/v1/archive?' ...
                 'latitude=%.4f&longitude=%.4f&' ...
                 'start_date=%s&end_date=%s&' ...
                 'daily=temperature_2m_max,temperature_2m_min,precipitation_sum&' ...
                 'timezone=America/Toronto'], ...
                 lat, lon, startDateStr, endDateStr);

fprintf('Downloading from Open-Meteo API...\n');

try
    % Fetch data
    options = weboptions('Timeout', 30);
    data = webread(apiUrl, options);
    
    % Extract data
    dates = datetime(data.daily.time, 'InputFormat', 'yyyy-MM-dd');
    tempMax = data.daily.temperature_2m_max;
    tempMin = data.daily.temperature_2m_min;
    precip = data.daily.precipitation_sum;
    
    fprintf('Successfully downloaded %d days of weather data!\n\n', length(dates));
    
    % Display sample data
    fprintf('Sample Data (first 5 days):\n');
    fprintf('Date\t\t\tMax Temp(°C)\tMin Temp(°C)\tPrecip(mm)\n');
    fprintf('-----------------------------------------------------------\n');
    for i = 1:min(5, length(dates))
        fprintf('%s\t%.1f\t\t%.1f\t\t%.2f\n', ...
                datestr(dates(i)), tempMax(i), tempMin(i), precip(i));
    end
    fprintf('\n');
    
    % Perform linear regression: Temperature trend over time
    dayNum = (1:length(dates))';
    
    % Remove any NaN values
    validIdx = ~isnan(tempMax);
    xData = dayNum(validIdx);
    yData = tempMax(validIdx);
    
    fprintf('=== Linear Regression Analysis ===\n');
    fprintf('Analyzing: Max Temperature vs Day Number\n\n');
    
    % Fit linear model
    p = polyfit(xData, yData, 1);
    slope = p(1);
    intercept = p(2);
    
    % Calculate R-squared
    yPred = polyval(p, xData);
    ssRes = sum((yData - yPred).^2);
    ssTot = sum((yData - mean(yData)).^2);
    rSquared = 1 - (ssRes / ssTot);
    
    % Display results
    fprintf('Regression equation: y = %.4f * x + %.4f\n', slope, intercept);
    fprintf('R-squared: %.4f\n', rSquared);
    fprintf('Correlation: %.4f\n', corr(xData, yData));
    fprintf('\nInterpretation:\n');
    if slope > 0
        fprintf('Temperature is increasing by %.4f°C per day on average\n', slope);
    else
        fprintf('Temperature is decreasing by %.4f°C per day on average\n', abs(slope));
    end
    fprintf('\n');
    
    % Create visualization
    figure('Position', [100, 100, 1000, 500]);
    
    % Plot 1: Temperature trend
    subplot(1, 2, 1);
    scatter(xData, yData, 50, 'b', 'filled');
    hold on;
    xLine = linspace(min(xData), max(xData), 100);
    yLine = polyval(p, xLine);
    plot(xLine, yLine, 'r-', 'LineWidth', 2);
    xlabel('Day Number');
    ylabel('Max Temperature (°C)');
    title(sprintf('Temperature Trend (R² = %.4f)', rSquared));
    legend('Data', 'Regression Line', 'Location', 'best');
    grid on;
    
    % Plot 2: All weather variables over time
    subplot(1, 2, 2);
    yyaxis left;
    plot(dates, tempMax, 'r-', 'LineWidth', 1.5, 'DisplayName', 'Max Temp');
    hold on;
    plot(dates, tempMin, 'b-', 'LineWidth', 1.5, 'DisplayName', 'Min Temp');
    ylabel('Temperature (°C)');
    
    yyaxis right;
    bar(dates, precip, 'FaceColor', [0.3, 0.7, 1], 'DisplayName', 'Precipitation');
    ylabel('Precipitation (mm)');
    
    xlabel('Date');
    title('Montreal Weather Data');
    legend('Location', 'best');
    grid on;
    
    fprintf('Plots created successfully!\n');
    fprintf('\nTo use the interactive GUI, run: weather_regression_gui\n');
    
catch ME
    fprintf('Error fetching data: %s\n', ME.message);
    fprintf('Make sure you have internet connection.\n');
end
