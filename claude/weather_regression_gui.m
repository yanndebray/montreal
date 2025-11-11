function weather_regression_gui
    % Weather Data Linear Regression GUI for Montreal
    % Fetches weather data and performs linear regression analysis
    
    % Create main figure
    fig = uifigure('Name', 'Montreal Weather Linear Regression', ...
                   'Position', [100, 100, 900, 700]);
    
    % Title label
    uilabel(fig, 'Position', [20, 650, 860, 30], ...
            'Text', 'Montreal Weather Data - Linear Regression Analysis', ...
            'FontSize', 18, 'FontWeight', 'bold', ...
            'HorizontalAlignment', 'center');
    
    % Control panel
    panel = uipanel(fig, 'Position', [20, 480, 860, 160], ...
                    'Title', 'Data Selection');
    
    % Date range selection
    uilabel(panel, 'Position', [20, 100, 100, 22], ...
            'Text', 'Start Date:');
    startDatePicker = uidatepicker(panel, 'Position', [130, 100, 150, 22], ...
                                   'Value', datetime('today') - days(30));
    
    uilabel(panel, 'Position', [20, 60, 100, 22], ...
            'Text', 'End Date:');
    endDatePicker = uidatepicker(panel, 'Position', [130, 60, 150, 22], ...
                                 'Value', datetime('today'));
    
    % Variable selection
    uilabel(panel, 'Position', [320, 100, 120, 22], ...
            'Text', 'X Variable:');
    xVarDropdown = uidropdown(panel, 'Position', [450, 100, 180, 22], ...
                              'Items', {'Day Number', 'Max Temperature', 'Min Temperature', 'Precipitation'}, ...
                              'Value', 'Day Number');
    
    uilabel(panel, 'Position', [320, 60, 120, 22], ...
            'Text', 'Y Variable:');
    yVarDropdown = uidropdown(panel, 'Position', [450, 60, 180, 22], ...
                              'Items', {'Max Temperature', 'Min Temperature', 'Precipitation', 'Day Number'}, ...
                              'Value', 'Max Temperature');
    
    % Fetch and analyze button
    fetchBtn = uibutton(panel, 'Position', [680, 80, 150, 40], ...
                        'Text', 'Fetch & Analyze', ...
                        'FontSize', 14, ...
                        'ButtonPushedFcn', @(btn,event) fetchAndAnalyze());
    
    % Status label
    statusLabel = uilabel(panel, 'Position', [20, 15, 820, 30], ...
                          'Text', 'Ready to fetch data...', ...
                          'FontColor', [0, 0, 0.8]);
    
    % Results panel
    resultsPanel = uipanel(fig, 'Position', [20, 350, 860, 120], ...
                           'Title', 'Regression Results');
    
    % Results text area
    resultsText = uitextarea(resultsPanel, 'Position', [10, 10, 840, 80], ...
                             'Editable', 'off', ...
                             'Value', {'Click "Fetch & Analyze" to begin...'});
    
    % Plot axes
    ax = uiaxes(fig, 'Position', [50, 30, 800, 300]);
    title(ax, 'Weather Data Visualization');
    xlabel(ax, 'X Variable');
    ylabel(ax, 'Y Variable');
    grid(ax, 'on');
    
    % Main function to fetch and analyze data
    function fetchAndAnalyze()
        try
            % Update status
            statusLabel.Text = 'Fetching weather data from Open-Meteo API...';
            statusLabel.FontColor = [0, 0, 0.8];
            drawnow;
            
            % Get date range
            startDate = startDatePicker.Value;
            endDate = endDatePicker.Value;
            
            % Validate dates
            if endDate < startDate
                uialert(fig, 'End date must be after start date!', 'Invalid Date Range');
                statusLabel.Text = 'Error: Invalid date range';
                statusLabel.FontColor = [0.8, 0, 0];
                return;
            end
            
            % Format dates for API (YYYY-MM-DD)
            startDateStr = datestr(startDate, 'yyyy-mm-dd');
            endDateStr = datestr(endDate, 'yyyy-mm-dd');
            
            % Montreal coordinates
            lat = 45.5017;
            lon = -73.5673;
            
            % Build API URL
            apiUrl = sprintf(['https://archive-api.open-meteo.com/v1/archive?' ...
                             'latitude=%.4f&longitude=%.4f&' ...
                             'start_date=%s&end_date=%s&' ...
                             'daily=temperature_2m_max,temperature_2m_min,precipitation_sum&' ...
                             'timezone=America/Toronto'], ...
                             lat, lon, startDateStr, endDateStr);
            
            % Fetch data
            statusLabel.Text = 'Downloading data...';
            drawnow;
            
            options = weboptions('Timeout', 30);
            data = webread(apiUrl, options);
            
            % Extract data
            dates = datetime(data.daily.time, 'InputFormat', 'yyyy-MM-dd');
            tempMax = data.daily.temperature_2m_max;
            tempMin = data.daily.temperature_2m_min;
            precip = data.daily.precipitation_sum;
            dayNum = (1:length(dates))';
            
            statusLabel.Text = sprintf('Successfully fetched %d days of data', length(dates));
            statusLabel.FontColor = [0, 0.6, 0];
            drawnow;
            
            % Get selected variables
            xVarName = xVarDropdown.Value;
            yVarName = yVarDropdown.Value;
            
            % Map variable names to data
            varMap = containers.Map(...
                {'Day Number', 'Max Temperature', 'Min Temperature', 'Precipitation'}, ...
                {dayNum, tempMax, tempMin, precip});
            
            xData = varMap(xVarName);
            yData = varMap(yVarName);
            
            % Remove any NaN values
            validIdx = ~isnan(xData) & ~isnan(yData);
            xData = xData(validIdx);
            yData = yData(validIdx);
            
            if length(xData) < 2
                uialert(fig, 'Not enough valid data points!', 'Data Error');
                return;
            end
            
            % Perform linear regression
            statusLabel.Text = 'Performing linear regression...';
            drawnow;
            
            p = polyfit(xData, yData, 1);
            slope = p(1);
            intercept = p(2);
            
            % Calculate statistics
            yPred = polyval(p, xData);
            ssRes = sum((yData - yPred).^2);
            ssTot = sum((yData - mean(yData)).^2);
            rSquared = 1 - (ssRes / ssTot);
            
            % Calculate correlation coefficient
            corrCoef = corr(xData, yData);
            
            % Update results
            resultsText.Value = {
                sprintf('Regression Equation: y = %.4f * x + %.4f', slope, intercept);
                sprintf('R-squared: %.4f', rSquared);
                sprintf('Correlation Coefficient: %.4f', corrCoef);
                sprintf('Number of data points: %d', length(xData));
                sprintf('Date range: %s to %s', datestr(startDate), datestr(endDate))
            };
            
            % Plot data
            cla(ax);
            scatter(ax, xData, yData, 50, 'b', 'filled', 'DisplayName', 'Data Points');
            hold(ax, 'on');
            
            % Plot regression line
            xLine = linspace(min(xData), max(xData), 100);
            yLine = polyval(p, xLine);
            plot(ax, xLine, yLine, 'r-', 'LineWidth', 2, 'DisplayName', 'Regression Line');
            
            % Update plot labels
            xlabel(ax, xVarName);
            ylabel(ax, yVarName);
            title(ax, sprintf('Montreal Weather: %s vs %s (R² = %.4f)', ...
                            yVarName, xVarName, rSquared));
            legend(ax, 'Location', 'best');
            grid(ax, 'on');
            hold(ax, 'off');
            
            statusLabel.Text = 'Analysis complete!';
            statusLabel.FontColor = [0, 0.6, 0];
            
        catch ME
            statusLabel.Text = sprintf('Error: %s', ME.message);
            statusLabel.FontColor = [0.8, 0, 0];
            uialert(fig, ME.message, 'Error');
        end
    end
end
