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
    inputGrid.RowHeight = {30, 30, 30, 30, 30, 30};
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
    
    % Create analyze button centered in input panel
    btnGrid = uigridlayout(topPanel, [1, 3]);
    btnGrid.RowHeight = {35};
    btnGrid.ColumnWidth = {'1x', 220, '1x'};
    btnGrid.Padding = [20 5 20 10];
    
    % Spacers
    uilabel(btnGrid, 'Text', '');
    
    % Analyze button
    analyzeBtn = uibutton(btnGrid, 'Text', '🔍 Analyze Weather Trends', ...
                          'ButtonPushedFcn', @(~,~) analyzeWeather(), ...
                          'FontSize', 14, 'FontWeight', 'bold');
    analyzeBtn.Layout.Row = 1;
    analyzeBtn.Layout.Column = 2;
    analyzeBtn.BackgroundColor = [0.3, 0.5, 0.9];
    analyzeBtn.FontColor = 'white';
    
    uilabel(btnGrid, 'Text', '');
    
    % Results area (responsive layout: avoid manual Position calculations)
    bottomGrid = uigridlayout(bottomPanel, [1,1]);
    bottomGrid.RowHeight = {'1x'}; bottomGrid.ColumnWidth = {'1x'};
    resultsTabGroup = uitabgroup(bottomGrid);
    resultsTabGroup.Layout.Row = 1; resultsTabGroup.Layout.Column = 1;
    
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
    detailsGrid = uigridlayout(detailsPanel, [1,1]);
    detailsGrid.RowHeight = {'1x'}; detailsGrid.ColumnWidth = {'1x'};
    detailsTextArea = uitextarea(detailsGrid, 'Value', 'Run analysis to see results...', ...
                                 'Editable', 'off', 'FontSize', 11);
    detailsTextArea.Layout.Row = 1; detailsTextArea.Layout.Column = 1;
    
    % Tab 2: Trend Plot (responsive)
    trendTab = uitab(resultsTabGroup, 'Title', 'Temperature Trend');
    trendGrid = uigridlayout(trendTab, [1,1]); trendGrid.RowHeight = {'1x'}; trendGrid.ColumnWidth = {'1x'};
    trendAxes = uiaxes(trendGrid); trendAxes.Layout.Row = 1; trendAxes.Layout.Column = 1;
    
    % Tab 3: Temperature Variations
    tempTab = uitab(resultsTabGroup, 'Title', 'Temperature Variations');
    tempGrid = uigridlayout(tempTab, [1,1]); tempGrid.RowHeight = {'1x'}; tempGrid.ColumnWidth = {'1x'};
    tempAxes = uiaxes(tempGrid); tempAxes.Layout.Row = 1; tempAxes.Layout.Column = 1;
    
    % Tab 4: Residuals
    residTab = uitab(resultsTabGroup, 'Title', 'Residual Plot');
    residGrid = uigridlayout(residTab, [1,1]); residGrid.RowHeight = {'1x'}; residGrid.ColumnWidth = {'1x'};
    residAxes = uiaxes(residGrid); residAxes.Layout.Row = 1; residAxes.Layout.Column = 1;
    
    % Tab 5: Precipitation
    precipTab = uitab(resultsTabGroup, 'Title', 'Precipitation');
    precipGrid = uigridlayout(precipTab, [1,1]); precipGrid.RowHeight = {'1x'}; precipGrid.ColumnWidth = {'1x'};
    precipAxes = uiaxes(precipGrid); precipAxes.Layout.Row = 1; precipAxes.Layout.Column = 1;
    
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
        % Validate presence of inputs
        if isempty(startDateField.Value) || isempty(endDateField.Value)
            uialert(fig, 'Please enter start and end dates', 'Missing Data'); return; end
        [datesOK, startStr, endStr, dateErr] = validateDates(startDateField.Value, endDateField.Value);
        if ~datesOK
            uialert(fig, dateErr, 'Invalid Dates'); return; end
        if latField.Value == 0 && lonField.Value == 0
            uialert(fig, 'Please enter valid coordinates or select a city', 'Missing Data'); return; end

        % Progress dialog
        progressDlg = uiprogressdlg(fig, 'Title', 'Analyzing Weather Data', ...
            'Message', 'Fetching data from API...', 'Indeterminate', 'on');

        try
            url = sprintf(['https://archive-api.open-meteo.com/v1/archive?' ...
                'latitude=%.4f&longitude=%.4f&start_date=%s&end_date=%s&' ...
                'daily=temperature_2m_max,temperature_2m_min,precipitation_sum&timezone=auto'], ...
                latField.Value, lonField.Value, startStr, endStr);
            opts = weboptions('Timeout', 30);
            data = webread(url, opts);
            progressDlg.Message = 'Processing data...';

            if ~isfield(data,'daily') || ~all(isfield(data.daily,{ 'time','temperature_2m_max','temperature_2m_min','precipitation_sum'}))
                error('Unexpected API response structure. Try a shorter date range.');
            end

            dates = datetime(string(data.daily.time),'InputFormat','yyyy-MM-dd');
            tempMax = double(data.daily.temperature_2m_max(:));
            tempMin = double(data.daily.temperature_2m_min(:));
            precipitation = double(data.daily.precipitation_sum(:));
            tempAvg = (tempMax + tempMin)/2;
            dayNumbers = (1:numel(dates))';
            if numel(dayNumbers) < 2
                close(progressDlg);
                uialert(fig, 'Need at least 2 days of data to compute a trend.', 'Not Enough Data');
                return;
            end

            % Regression
            p = polyfit(dayNumbers, tempAvg, 1); slope = p(1); intercept = p(2); tempPred = polyval(p, dayNumbers);
            ssRes = sum((tempAvg - tempPred).^2); ssTot = sum((tempAvg - mean(tempAvg)).^2); rSquared = 1 - ssRes/ssTot;
            numDays = numel(tempAvg); avgTemp = mean(tempAvg); [minTemp,minIdx] = min(tempAvg); [maxTemp,maxIdx] = max(tempAvg);
            stdTemp = std(tempAvg); totalPrecip = sum(precipitation); tempChange = slope * numDays;
            progressDlg.Message = 'Creating visualizations...';

            % Stat cards
            statCard1Text.Text = sprintf('%.3f', rSquared);
            statCard2Text.Text = sprintf('%.4f', slope);
            statCard3Text.Text = sprintf('%.1f', avgTemp);
            statCard4Text.Text = sprintf('%.1f', tempChange);

            cityName = cityNameField.Value; if isempty(cityName), cityName = sprintf('Location (%.2f, %.2f)', latField.Value, lonField.Value); end
            regressionText.Text = sprintf('Regression for %s:  Temperature = %.4f × Day + %.4f', cityName, slope, intercept);

            % Detailed stats
            detailsText = {sprintf('═══ Analysis Period ═══'); sprintf('Number of days: %d', numDays); ...
                sprintf('Date range: %s to %s', datestr(dates(1)), datestr(dates(end))); ''; ...
                sprintf('═══ Temperature Statistics ═══'); sprintf('Average temperature: %.2f °C', avgTemp); ...
                sprintf('Minimum temperature: %.2f °C on %s', minTemp, datestr(dates(minIdx))); ...
                sprintf('Maximum temperature: %.2f °C on %s', maxTemp, datestr(dates(maxIdx))); ...
                sprintf('Temperature range: %.2f °C', maxTemp - minTemp); sprintf('Standard deviation: %.2f °C', stdTemp); ''; ...
                sprintf('═══ Trend Analysis ═══'); sprintf('Slope: %.4f °C per day', slope); ...
                sprintf('Total change: %.2f °C over %d days', tempChange, numDays); ''; getTrendText(slope, tempChange); ...
                sprintf('R-squared: %.4f (%.1f%% variance explained)', rSquared, rSquared*100); ''; ...
                sprintf('═══ Precipitation ═══'); sprintf('Total precipitation: %.2f mm', totalPrecip); ...
                sprintf('Average daily precipitation: %.2f mm', totalPrecip/numDays)}; detailsTextArea.Value = detailsText;

            % Plot 1
            cla(trendAxes); scatter(trendAxes, dayNumbers, tempAvg, 30, 'filled', 'MarkerFaceAlpha', 0.6); hold(trendAxes,'on');
            plot(trendAxes, dayNumbers, tempPred, 'r-', 'LineWidth',2); xlabel(trendAxes,'Day Number'); ylabel(trendAxes,'Average Temperature (°C)');
            title(trendAxes, sprintf('Temperature Trend (R² = %.3f)', rSquared)); legend(trendAxes,'Actual','Linear Fit','Location','best'); grid(trendAxes,'on'); hold(trendAxes,'off');

            % Plot 2
            cla(tempAxes); plot(tempAxes, dates, tempMax,'r-','LineWidth',1.5); hold(tempAxes,'on'); plot(tempAxes, dates, tempMin,'b-','LineWidth',1.5); plot(tempAxes, dates, tempAvg,'k-','LineWidth',2);
            xlabel(tempAxes,'Date'); ylabel(tempAxes,'Temperature (°C)'); title(tempAxes,'Daily Temperature Variations'); legend(tempAxes,'Max','Min','Avg','Location','best'); grid(tempAxes,'on'); hold(tempAxes,'off');

            % Plot 3
            cla(residAxes); residuals = tempAvg - tempPred(:); scatter(residAxes, tempPred, residuals, 30,'filled'); hold(residAxes,'on'); yline(residAxes,0,'r--','LineWidth',2);
            xlabel(residAxes,'Predicted Temperature (°C)'); ylabel(residAxes,'Residuals (°C)'); title(residAxes,'Residual Plot'); grid(residAxes,'on'); hold(residAxes,'off');

            % Plot 4
            cla(precipAxes); bar(precipAxes, dates, precipitation,'FaceColor',[0.2 0.6 0.8]); xlabel(precipAxes,'Date'); ylabel(precipAxes,'Precipitation (mm)'); title(precipAxes,'Daily Precipitation'); grid(precipAxes,'on');

            close(progressDlg); uialert(fig, 'Analysis completed successfully!', 'Success', 'Icon','success');
        catch ME
            if isvalid(progressDlg); close(progressDlg); end
            uialert(fig, sprintf('Error: %s', ME.message), 'Analysis Failed');
        end
    end

    % Initialize with default values
    setQuickDateRange(90);
    selectCity('Paris, France', 48.8566, 2.3522);
    
    function trendText = getTrendText(slope, tempChange)
        if slope > 0
            trendText = sprintf('Trend: WARMING (%.2f °C increase)', tempChange);
        elseif slope < 0
            trendText = sprintf('Trend: COOLING (%.2f °C decrease)', abs(tempChange));
        else
            trendText = 'Trend: STABLE (no significant change)';
        end
    end

    function [ok, startStr, endStr, errMsg] = validateDates(startVal, endVal)
        ok = false; startStr = ''; endStr = ''; errMsg = '';
        try
            sd = datetime(startVal,'InputFormat','yyyy-MM-dd');
        catch
            errMsg = 'Start Date must be in YYYY-MM-DD format.'; return;
        end
        try
            ed = datetime(endVal,'InputFormat','yyyy-MM-dd');
        catch
            errMsg = 'End Date must be in YYYY-MM-DD format.'; return;
        end
        if ed < sd
            errMsg = 'End Date must be on or after Start Date.'; return;
        end
        startStr = datestr(sd,'yyyy-mm-dd'); endStr = datestr(ed,'yyyy-mm-dd'); ok = true;
    end
end
