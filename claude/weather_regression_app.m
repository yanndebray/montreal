function weather_regression_app()
    % Weather Linear Regression App
    % Interactive GUI for analyzing weather trends with linear regression
    
    % Create main figure
    fig = uifigure('Name', 'Weather Trend Analyzer', ...
                   'Position', [100, 100, 1200, 800], ...
                   'Color', [0.95, 0.97, 0.99]);
    
    % Create grid layout
    mainGrid = uigridlayout(fig, [2, 1]);
    mainGrid.RowHeight = {220, '1x'};
    
    % Top panel for inputs
    topPanel = uipanel(mainGrid, 'Title', '', 'BackgroundColor', 'white');
    topPanel.Layout.Row = 1;
    topPanel.Layout.Column = 1;
    
    % Bottom panel for results
    bottomPanel = uipanel(mainGrid, 'Title', '', 'BackgroundColor', [0.95, 0.97, 0.99]);
    bottomPanel.Layout.Row = 2;
    bottomPanel.Layout.Column = 1;
    
    % Create input grid
    inputGrid = uigridlayout(topPanel, [6, 4]);
    inputGrid.RowHeight = {30, 30, 30, 30, 30, 40};
    inputGrid.ColumnWidth = {'1x', '1x', '1x', '1x'};
    inputGrid.Padding = [20 20 20 20];
    
    % Title
    titleLabel = uilabel(inputGrid, 'Text', '🌤️ Weather Trend Analyzer with Linear Regression', ...
                         'FontSize', 18, 'FontWeight', 'bold', 'FontColor', [0.2, 0.3, 0.6]);
    titleLabel.Layout.Row = 1;
    titleLabel.Layout.Column = [1, 4];
    titleLabel.HorizontalAlignment = 'center';
    
    % Quick city selection
    cityLabel = uilabel(inputGrid, 'Text', 'Quick Select City:', 'FontWeight', 'bold');
    cityLabel.Layout.Row = 2;
    cityLabel.Layout.Column = 1;
    
    % City buttons
    cities = {
        'Paris, France', 48.8566, 2.3522;
        'New York, USA', 40.7128, -74.0060;
        'London, UK', 51.5074, -0.1278;
        'Tokyo, Japan', 35.6762, 139.6503;
        'Sydney, Australia', -33.8688, 151.2093;
        'Berlin, Germany', 52.5200, 13.4050
    };
    
    cityButtons = {};
    for i = 1:6
        row = 2 + floor((i-1)/3);
        col = mod(i-1, 3) + 2;
        btn = uibutton(inputGrid, 'Text', cities{i,1}, ...
                       'ButtonPushedFcn', @(~,~) selectCity(cities{i,1}, cities{i,2}, cities{i,3}));
        btn.Layout.Row = row;
        btn.Layout.Column = col;
        btn.BackgroundColor = [0.9, 0.95, 1];
        cityButtons{i} = btn;
    end
    
    % Input fields
    cityNameLabel = uilabel(inputGrid, 'Text', 'City Name:');
    cityNameLabel.Layout.Row = 4;
    cityNameLabel.Layout.Column = 1;
    cityNameField = uieditfield(inputGrid, 'text', 'Value', '', 'Placeholder', 'e.g., Paris, France');
    cityNameField.Layout.Row = 4;
    cityNameField.Layout.Column = 2;
    
    latLabel = uilabel(inputGrid, 'Text', 'Latitude:');
    latLabel.Layout.Row = 4;
    latLabel.Layout.Column = 3;
    latField = uieditfield(inputGrid, 'numeric', 'Value', 0, 'Limits', [-90 90]);
    latField.Layout.Row = 4;
    latField.Layout.Column = 4;
    
    lonLabel = uilabel(inputGrid, 'Text', 'Longitude:');
    lonLabel.Layout.Row = 5;
    lonLabel.Layout.Column = 1;
    lonField = uieditfield(inputGrid, 'numeric', 'Value', 0, 'Limits', [-180 180]);
    lonField.Layout.Row = 5;
    lonField.Layout.Column = 2;
    
    % Date range quick buttons
    dateRangeLabel = uilabel(inputGrid, 'Text', 'Quick Date Range:');
    dateRangeLabel.Layout.Row = 5;
    dateRangeLabel.Layout.Column = 3;
    
    % Quick date range buttons
    btn30 = uibutton(inputGrid, 'Text', '30 days', ...
                     'ButtonPushedFcn', @(~,~) setQuickDateRange(30));
    btn30.Layout.Row = 5;
    btn30.Layout.Column = 4;
    btn30.BackgroundColor = [1, 0.95, 1];
    
    % Date fields
    startDateLabel = uilabel(inputGrid, 'Text', 'Start Date:');
    startDateLabel.Layout.Row = 6;
    startDateLabel.Layout.Column = 1;
    startDateField = uieditfield(inputGrid, 'text', 'Value', '', 'Placeholder', 'YYYY-MM-DD');
    startDateField.Layout.Row = 6;
    startDateField.Layout.Column = 2;
    
    endDateLabel = uilabel(inputGrid, 'Text', 'End Date:');
    endDateLabel.Layout.Row = 6;
    endDateLabel.Layout.Column = 3;
    endDateField = uieditfield(inputGrid, 'text', 'Value', '', 'Placeholder', 'YYYY-MM-DD');
    endDateField.Layout.Row = 6;
    endDateField.Layout.Column = 4;
    
    % Create buttons at bottom of input panel
    btnGrid = uigridlayout(topPanel, [1, 3]);
    btnGrid.ColumnWidth = {'1x', 200, '1x'};
    btnGrid.Padding = [20 5 20 10];
    
    % Spacers
    uilabel(btnGrid);
    
    % Analyze button
    analyzeBtn = uibutton(btnGrid, 'Text', '🔍 Analyze Weather Trends', ...
                          'ButtonPushedFcn', @(~,~) analyzeWeather(), ...
                          'FontSize', 14, 'FontWeight', 'bold');
    analyzeBtn.BackgroundColor = [0.3, 0.5, 0.9];
    analyzeBtn.FontColor = 'white';
    
    uilabel(btnGrid);
    
    % Results area
    resultsTabGroup = uitabgroup(bottomPanel);
    resultsTabGroup.Position = [10, 10, bottomPanel.Position(3)-20, bottomPanel.Position(4)-20];
    
    % Tab 1: Statistics
    statsTab = uitab(resultsTabGroup, 'Title', 'Statistics & Regression');
    statsGrid = uigridlayout(statsTab, [3, 1]);
    statsGrid.RowHeight = {100, 80, '1x'};
    
    % Statistics cards
    statsCardPanel = uipanel(statsGrid, 'BackgroundColor', 'white');
    statsCardPanel.Layout.Row = 1;
    statsCardGrid = uigridlayout(statsCardPanel, [1, 4]);
    
    % Create stat cards
    statCard1 = uipanel(statsCardGrid, 'Title', 'R² Score', 'FontWeight', 'bold');
    statCard1Text = uilabel(statCard1, 'Text', '--', 'FontSize', 24, 'FontWeight', 'bold', ...
                            'HorizontalAlignment', 'center', 'Position', [10, 20, 120, 40]);
    
    statCard2 = uipanel(statsCardGrid, 'Title', 'Trend (°C/day)', 'FontWeight', 'bold');
    statCard2Text = uilabel(statCard2, 'Text', '--', 'FontSize', 24, 'FontWeight', 'bold', ...
                            'HorizontalAlignment', 'center', 'Position', [10, 20, 120, 40]);
    
    statCard3 = uipanel(statsCardGrid, 'Title', 'Average Temp (°C)', 'FontWeight', 'bold');
    statCard3Text = uilabel(statCard3, 'Text', '--', 'FontSize', 24, 'FontWeight', 'bold', ...
                            'HorizontalAlignment', 'center', 'Position', [10, 20, 120, 40]);
    
    statCard4 = uipanel(statsCardGrid, 'Title', 'Total Change (°C)', 'FontWeight', 'bold');
    statCard4Text = uilabel(statCard4, 'Text', '--', 'FontSize', 24, 'FontWeight', 'bold', ...
                            'HorizontalAlignment', 'center', 'Position', [10, 20, 120, 40]);
    
    % Regression equation
    regressionPanel = uipanel(statsGrid, 'BackgroundColor', [0.95, 0.97, 1]);
    regressionPanel.Layout.Row = 2;
    regressionText = uilabel(regressionPanel, 'Text', 'Regression Equation: Temperature = -- × Day + --', ...
                             'FontSize', 16, 'FontWeight', 'bold', ...
                             'HorizontalAlignment', 'center', 'Position', [20, 20, 800, 30]);
    
    % Detailed stats
    detailsPanel = uipanel(statsGrid, 'Title', 'Detailed Statistics', 'FontWeight', 'bold', ...
                           'BackgroundColor', 'white');
    detailsPanel.Layout.Row = 3;
    detailsTextArea = uitextarea(detailsPanel, 'Value', 'Run analysis to see results...', ...
                                 'Editable', 'off', 'FontSize', 11);
    detailsTextArea.Position = [10, 10, detailsPanel.Position(3)-20, detailsPanel.Position(4)-40];
    
    % Tab 2: Trend Plot
    trendTab = uitab(resultsTabGroup, 'Title', 'Temperature Trend');
    trendAxes = uiaxes(trendTab);
    trendAxes.Position = [40, 40, trendTab.Position(3)-80, trendTab.Position(4)-80];
    
    % Tab 3: Temperature Variations
    tempTab = uitab(resultsTabGroup, 'Title', 'Temperature Variations');
    tempAxes = uiaxes(tempTab);
    tempAxes.Position = [40, 40, tempTab.Position(3)-80, tempTab.Position(4)-80];
    
    % Tab 4: Residuals
    residTab = uitab(resultsTabGroup, 'Title', 'Residual Plot');
    residAxes = uiaxes(residTab);
    residAxes.Position = [40, 40, residTab.Position(3)-80, residTab.Position(4)-80];
    
    % Tab 5: Precipitation
    precipTab = uitab(resultsTabGroup, 'Title', 'Precipitation');
    precipAxes = uiaxes(precipTab);
    precipAxes.Position = [40, 40, precipTab.Position(3)-80, precipTab.Position(4)-80];
    
    % Callback functions
    function selectCity(name, lat, lon)
        cityNameField.Value = name;
        latField.Value = lat;
        lonField.Value = lon;
    end
    
    function setQuickDateRange(numDays)
        endDate = datetime('today');
        startDate = endDate - days(numDays);
        startDateField.Value = datestr(startDate, 'yyyy-mm-dd');
        endDateField.Value = datestr(endDate, 'yyyy-mm-dd');
    end
    
    function analyzeWeather()
        % Validate inputs
        if isempty(startDateField.Value) || isempty(endDateField.Value)
            uialert(fig, 'Please enter start and end dates', 'Missing Data');
            return;
        end
        
        if latField.Value == 0 && lonField.Value == 0
            uialert(fig, 'Please enter valid coordinates or select a city', 'Missing Data');
            return;
        end
        
        % Show progress dialog
        progressDlg = uiprogressdlg(fig, 'Title', 'Analyzing Weather Data', ...
                                    'Message', 'Fetching data from API...', ...
                                    'Indeterminate', 'on');
        
        try
            % Fetch weather data
            url = sprintf(['https://archive-api.open-meteo.com/v1/archive?' ...
                'latitude=%.4f&longitude=%.4f&start_date=%s&end_date=%s&' ...
                'daily=temperature_2m_max,temperature_2m_min,precipitation_sum&' ...
                'timezone=auto'], ...
                latField.Value, lonField.Value, startDateField.Value, endDateField.Value);
            
            data = webread(url);
            
            progressDlg.Message = 'Processing data...';
            
            % Extract data
            dates = datetime(data.daily.time, 'InputFormat', 'yyyy-MM-dd');
            tempMax = data.daily.temperature_2m_max;
            tempMin = data.daily.temperature_2m_min;
            precipitation = data.daily.precipitation_sum;
            tempAvg = (tempMax + tempMin) / 2;
            dayNumbers = (1:length(dates))';
            
            % Perform linear regression
            p = polyfit(dayNumbers, tempAvg, 1);
            slope = p(1);
            intercept = p(2);
            tempPred = polyval(p, dayNumbers);
            
            % Calculate R-squared
            ssRes = sum((tempAvg - tempPred).^2);
            ssTot = sum((tempAvg - mean(tempAvg)).^2);
            rSquared = 1 - (ssRes / ssTot);
            
            % Calculate statistics
            numDays = length(tempAvg);
            avgTemp = mean(tempAvg);
            minTemp = min(tempAvg);
            maxTemp = max(tempAvg);
            stdTemp = std(tempAvg);
            totalPrecip = sum(precipitation);
            tempChange = slope * numDays;
            
            progressDlg.Message = 'Creating visualizations...';
            
            % Update statistics cards
            statCard1Text.Text = sprintf('%.3f', rSquared);
            statCard2Text.Text = sprintf('%.4f', slope);
            statCard3Text.Text = sprintf('%.1f', avgTemp);
            statCard4Text.Text = sprintf('%.1f', tempChange);
            
            % Update regression equation
            cityName = cityNameField.Value;
            if isempty(cityName)
                cityName = sprintf('Location (%.2f, %.2f)', latField.Value, lonField.Value);
            end
            regressionText.Text = sprintf('Regression for %s:  Temperature = %.4f × Day + %.4f', ...
                                          cityName, slope, intercept);
            
            % Update detailed statistics
            detailsText = {
                sprintf('═══ Analysis Period ═══');
                sprintf('Number of days: %d', numDays);
                sprintf('Date range: %s to %s', datestr(dates(1)), datestr(dates(end)));
                sprintf('');
                sprintf('═══ Temperature Statistics ═══');
                sprintf('Average temperature: %.2f °C', avgTemp);
                sprintf('Minimum temperature: %.2f °C on %s', minTemp, datestr(dates(tempAvg == minTemp)));
                sprintf('Maximum temperature: %.2f °C on %s', maxTemp, datestr(dates(tempAvg == maxTemp)));
                sprintf('Temperature range: %.2f °C', maxTemp - minTemp);
                sprintf('Standard deviation: %.2f °C', stdTemp);
                sprintf('');
                sprintf('═══ Trend Analysis ═══');
                sprintf('Slope: %.4f °C per day', slope);
                sprintf('Total change: %.2f °C over %d days', tempChange, numDays);
                '';
                getTrendText(slope, tempChange);
                sprintf('R-squared: %.4f (%.1f%% variance explained)', rSquared, rSquared*100);
                sprintf('');
                sprintf('═══ Precipitation ═══');
                sprintf('Total precipitation: %.2f mm', totalPrecip);
                sprintf('Average daily precipitation: %.2f mm', totalPrecip/numDays);
            };
            detailsTextArea.Value = detailsText;
            
            % Plot 1: Temperature trend with regression
            cla(trendAxes);
            scatter(trendAxes, dayNumbers, tempAvg, 30, 'filled', 'MarkerFaceAlpha', 0.6);
            hold(trendAxes, 'on');
            plot(trendAxes, dayNumbers, tempPred, 'r-', 'LineWidth', 2);
            xlabel(trendAxes, 'Day Number');
            ylabel(trendAxes, 'Average Temperature (°C)');
            title(trendAxes, sprintf('Temperature Trend with Linear Regression (R² = %.3f)', rSquared));
            legend(trendAxes, 'Actual Temperature', 'Linear Fit', 'Location', 'best');
            grid(trendAxes, 'on');
            hold(trendAxes, 'off');
            
            % Plot 2: Temperature variations
            cla(tempAxes);
            plot(tempAxes, dates, tempMax, 'r-', 'LineWidth', 1.5);
            hold(tempAxes, 'on');
            plot(tempAxes, dates, tempMin, 'b-', 'LineWidth', 1.5);
            plot(tempAxes, dates, tempAvg, 'k-', 'LineWidth', 2);
            xlabel(tempAxes, 'Date');
            ylabel(tempAxes, 'Temperature (°C)');
            title(tempAxes, 'Daily Temperature Variations');
            legend(tempAxes, 'Max Temp', 'Min Temp', 'Avg Temp', 'Location', 'best');
            grid(tempAxes, 'on');
            hold(tempAxes, 'off');
            
            % Plot 3: Residuals
            cla(residAxes);
            residuals = tempAvg - tempPred;
            scatter(residAxes, tempPred, residuals, 30, 'filled');
            hold(residAxes, 'on');
            yline(residAxes, 0, 'r--', 'LineWidth', 2);
            xlabel(residAxes, 'Predicted Temperature (°C)');
            ylabel(residAxes, 'Residuals (°C)');
            title(residAxes, 'Residual Plot');
            grid(residAxes, 'on');
            hold(residAxes, 'off');
            
            % Plot 4: Precipitation
            cla(precipAxes);
            bar(precipAxes, dates, precipitation, 'FaceColor', [0.2, 0.6, 0.8]);
            xlabel(precipAxes, 'Date');
            ylabel(precipAxes, 'Precipitation (mm)');
            title(precipAxes, 'Daily Precipitation');
            grid(precipAxes, 'on');
            
            close(progressDlg);
            uialert(fig, 'Analysis completed successfully!', 'Success', 'Icon', 'success');
            
        catch ME
            close(progressDlg);
            uialert(fig, sprintf('Error: %s', ME.message), 'Analysis Failed');
        end
    end

    % Initialize with default values
    setQuickDateRange(90);
    selectCity('Paris, France', 48.8566, 2.3522);
    
    function trendText = getTrendText(slope, tempChange)
        if slope > 0
            trendText = sprintf('Trend: WARMING (%.2f °C increase)', tempChange);
        else
            trendText = sprintf('Trend: COOLING (%.2f °C decrease)', abs(tempChange));
        end
    end
end
