function montreal_weather_sine_app()
    % Montreal Weather Sine Fitting Application
    % Interactive GUI for analyzing weather trends with sine, linear, and polynomial regression
    
    % Create main figure
    fig = uifigure('Name', 'Montreal Weather Sine Fitting App', ...
                   'Position', [100, 100, 1400, 900], ...
                   'Color', [0.95, 0.97, 0.99]);
    
    % Create grid layout
    mainGrid = uigridlayout(fig, [2, 1]);
    mainGrid.RowHeight = {260, '1x'};
    
    % Top panel for inputs
    topPanel = uipanel(mainGrid, 'Title', '', 'BackgroundColor', 'white');
    topPanel.Layout.Row = 1;
    topPanel.Layout.Column = 1;
    
    % Bottom panel for results
    bottomPanel = uipanel(mainGrid, 'Title', '', 'BackgroundColor', [0.95, 0.97, 0.99]);
    bottomPanel.Layout.Row = 2;
    bottomPanel.Layout.Column = 1;
    
    % Create input grid
    inputGrid = uigridlayout(topPanel, [7, 4]);
    inputGrid.RowHeight = {30, 30, 30, 30, 30, 30, 30};
    inputGrid.ColumnWidth = {'1x', '1x', '1x', '1x'};
    inputGrid.Padding = [20 20 20 20];
    
    % Title
    titleLabel = uilabel(inputGrid, 'Text', '🌤️ Weather Data Sine Fitting & Regression Analyzer', ...
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
        'Montreal, Canada', 45.5017, -73.5673;
        'Paris, France', 48.8566, 2.3522;
        'New York, USA', 40.7128, -74.0060;
        'London, UK', 51.5074, -0.1278;
        'Tokyo, Japan', 35.6762, 139.6503;
        'Sydney, Australia', -33.8688, 151.2093
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
    cityNameField = uieditfield(inputGrid, 'text', 'Value', '', 'Placeholder', 'e.g., Montreal, Canada');
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
    
    % Model selection dropdown
    modelLabel = uilabel(inputGrid, 'Text', 'Fitting Model:', 'FontWeight', 'bold');
    modelLabel.Layout.Row = 5;
    modelLabel.Layout.Column = 3;
    
    modelDropdown = uidropdown(inputGrid, 'Items', {'Sine', 'Linear', 'Polynomial (2nd)', 'Polynomial (3rd)', 'Polynomial (4th)'}, ...
                               'Value', 'Sine');
    modelDropdown.Layout.Row = 5;
    modelDropdown.Layout.Column = 4;
    modelDropdown.BackgroundColor = [1, 0.98, 0.85];
    
    % Date range quick buttons
    dateRangeLabel = uilabel(inputGrid, 'Text', 'Quick Date Range:');
    dateRangeLabel.Layout.Row = 6;
    dateRangeLabel.Layout.Column = 1;
    
    % Quick date range buttons
    btn365 = uibutton(inputGrid, 'Text', '1 year', ...
                     'ButtonPushedFcn', @(~,~) setQuickDateRange(365));
    btn365.Layout.Row = 6;
    btn365.Layout.Column = 2;
    btn365.BackgroundColor = [1, 0.95, 1];
    
    btn730 = uibutton(inputGrid, 'Text', '2 years', ...
                     'ButtonPushedFcn', @(~,~) setQuickDateRange(730));
    btn730.Layout.Row = 6;
    btn730.Layout.Column = 3;
    btn730.BackgroundColor = [1, 0.95, 1];
    
    btn1095 = uibutton(inputGrid, 'Text', '3 years', ...
                     'ButtonPushedFcn', @(~,~) setQuickDateRange(1095));
    btn1095.Layout.Row = 6;
    btn1095.Layout.Column = 4;
    btn1095.BackgroundColor = [1, 0.95, 1];
    
    % Date fields
    startDateLabel = uilabel(inputGrid, 'Text', 'Start Date:');
    startDateLabel.Layout.Row = 7;
    startDateLabel.Layout.Column = 1;
    startDateField = uieditfield(inputGrid, 'text', 'Value', '', 'Placeholder', 'YYYY-MM-DD');
    startDateField.Layout.Row = 7;
    startDateField.Layout.Column = 2;
    
    endDateLabel = uilabel(inputGrid, 'Text', 'End Date:');
    endDateLabel.Layout.Row = 7;
    endDateLabel.Layout.Column = 3;
    endDateField = uieditfield(inputGrid, 'text', 'Value', '', 'Placeholder', 'YYYY-MM-DD');
    endDateField.Layout.Row = 7;
    endDateField.Layout.Column = 4;
    
    % Create analyze button centered in input panel
    btnGrid = uigridlayout(topPanel, [1, 3]);
    btnGrid.RowHeight = {35};
    btnGrid.ColumnWidth = {'1x', 240, '1x'};
    btnGrid.Padding = [20 5 20 10];
    
    % Spacers
    uilabel(btnGrid, 'Text', '');
    
    % Analyze button
    analyzeBtn = uibutton(btnGrid, 'Text', '🔍 Analyze Weather with Sine Fitting', ...
                          'ButtonPushedFcn', @(~,~) analyzeWeather(), ...
                          'FontSize', 14, 'FontWeight', 'bold');
    analyzeBtn.Layout.Row = 1;
    analyzeBtn.Layout.Column = 2;
    analyzeBtn.BackgroundColor = [0.3, 0.5, 0.9];
    analyzeBtn.FontColor = 'white';
    
    uilabel(btnGrid, 'Text', '');
    
    % Results area (responsive layout)
    bottomGrid = uigridlayout(bottomPanel, [1,1]);
    bottomGrid.RowHeight = {'1x'};
    bottomGrid.ColumnWidth = {'1x'};
    resultsTabGroup = uitabgroup(bottomGrid);
    resultsTabGroup.Layout.Row = 1;
    resultsTabGroup.Layout.Column = 1;
    
    % Tab 1: Statistics
    statsTab = uitab(resultsTabGroup, 'Title', 'Statistics & Fitting');
    statsGrid = uigridlayout(statsTab, [3, 1]);
    statsGrid.RowHeight = {100, 80, '1x'};
    
    % Statistics cards
    statsCardPanel = uipanel(statsGrid, 'BackgroundColor', 'white');
    statsCardPanel.Layout.Row = 1;
    statsCardGrid = uigridlayout(statsCardPanel, [1, 5]);
    
    % Create stat cards
    statCard1 = uipanel(statsCardGrid, 'Title', 'R² Score', 'FontWeight', 'bold');
    statCard1Text = uilabel(statCard1, 'Text', '--', 'FontSize', 20, 'FontWeight', 'bold', ...
                            'HorizontalAlignment', 'center', 'Position', [10, 20, 120, 40]);
    
    statCard2 = uipanel(statsCardGrid, 'Title', 'Model Type', 'FontWeight', 'bold');
    statCard2Text = uilabel(statCard2, 'Text', '--', 'FontSize', 16, 'FontWeight', 'bold', ...
                            'HorizontalAlignment', 'center', 'Position', [10, 20, 120, 40]);
    
    statCard3 = uipanel(statsCardGrid, 'Title', 'Average Temp (°C)', 'FontWeight', 'bold');
    statCard3Text = uilabel(statCard3, 'Text', '--', 'FontSize', 20, 'FontWeight', 'bold', ...
                            'HorizontalAlignment', 'center', 'Position', [10, 20, 120, 40]);
    
    statCard4 = uipanel(statsCardGrid, 'Title', 'Amplitude (°C)', 'FontWeight', 'bold');
    statCard4Text = uilabel(statCard4, 'Text', '--', 'FontSize', 20, 'FontWeight', 'bold', ...
                            'HorizontalAlignment', 'center', 'Position', [10, 20, 120, 40]);
    
    statCard5 = uipanel(statsCardGrid, 'Title', 'RMSE (°C)', 'FontWeight', 'bold');
    statCard5Text = uilabel(statCard5, 'Text', '--', 'FontSize', 20, 'FontWeight', 'bold', ...
                            'HorizontalAlignment', 'center', 'Position', [10, 20, 120, 40]);
    
    % Model equation
    modelPanel = uipanel(statsGrid, 'BackgroundColor', [0.95, 0.97, 1]);
    modelPanel.Layout.Row = 2;
    modelText = uilabel(modelPanel, 'Text', 'Model Equation: Select model and run analysis', ...
                             'FontSize', 14, 'FontWeight', 'bold', ...
                             'HorizontalAlignment', 'center', 'Position', [20, 20, 1200, 30]);
    
    % Detailed stats
    detailsPanel = uipanel(statsGrid, 'Title', 'Detailed Statistics', 'FontWeight', 'bold', ...
                           'BackgroundColor', 'white');
    detailsPanel.Layout.Row = 3;
    detailsGrid = uigridlayout(detailsPanel, [1,1]);
    detailsGrid.RowHeight = {'1x'};
    detailsGrid.ColumnWidth = {'1x'};
    detailsTextArea = uitextarea(detailsGrid, 'Value', 'Run analysis to see results...', ...
                                 'Editable', 'off', 'FontSize', 11);
    detailsTextArea.Layout.Row = 1;
    detailsTextArea.Layout.Column = 1;
    
    % Tab 2: Fitted Model Plot
    fitTab = uitab(resultsTabGroup, 'Title', 'Fitted Model');
    fitGrid = uigridlayout(fitTab, [1,1]);
    fitGrid.RowHeight = {'1x'};
    fitGrid.ColumnWidth = {'1x'};
    fitAxes = uiaxes(fitGrid);
    fitAxes.Layout.Row = 1;
    fitAxes.Layout.Column = 1;
    
    % Tab 3: Temperature Variations
    tempTab = uitab(resultsTabGroup, 'Title', 'Temperature Variations');
    tempGrid = uigridlayout(tempTab, [1,1]);
    tempGrid.RowHeight = {'1x'};
    tempGrid.ColumnWidth = {'1x'};
    tempAxes = uiaxes(tempGrid);
    tempAxes.Layout.Row = 1;
    tempAxes.Layout.Column = 1;
    
    % Tab 4: Residuals
    residTab = uitab(resultsTabGroup, 'Title', 'Residual Plot');
    residGrid = uigridlayout(residTab, [1,1]);
    residGrid.RowHeight = {'1x'};
    residGrid.ColumnWidth = {'1x'};
    residAxes = uiaxes(residGrid);
    residAxes.Layout.Row = 1;
    residAxes.Layout.Column = 1;
    
    % Tab 5: Precipitation
    precipTab = uitab(resultsTabGroup, 'Title', 'Precipitation');
    precipGrid = uigridlayout(precipTab, [1,1]);
    precipGrid.RowHeight = {'1x'};
    precipGrid.ColumnWidth = {'1x'};
    precipAxes = uiaxes(precipGrid);
    precipAxes.Layout.Row = 1;
    precipAxes.Layout.Column = 1;
    
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
            uialert(fig, 'Please enter start and end dates', 'Missing Data');
            return;
        end
        
        [datesOK, startStr, endStr, dateErr] = validateDates(startDateField.Value, endDateField.Value);
        if ~datesOK
            uialert(fig, dateErr, 'Invalid Dates');
            return;
        end
        
        if latField.Value == 0 && lonField.Value == 0
            uialert(fig, 'Please enter valid coordinates or select a city', 'Missing Data');
            return;
        end

        % Progress dialog
        progressDlg = uiprogressdlg(fig, 'Title', 'Analyzing Weather Data', ...
            'Message', 'Fetching data from API...', 'Indeterminate', 'on');

        try
            % Fetch data
            url = sprintf(['https://archive-api.open-meteo.com/v1/archive?' ...
                'latitude=%.4f&longitude=%.4f&start_date=%s&end_date=%s&' ...
                'daily=temperature_2m_max,temperature_2m_min,precipitation_sum&timezone=auto'], ...
                latField.Value, lonField.Value, startStr, endStr);
            opts = weboptions('Timeout', 30);
            data = webread(url, opts);
            progressDlg.Message = 'Processing data...';

            if ~isfield(data,'daily') || ~all(isfield(data.daily,{'time','temperature_2m_max','temperature_2m_min','precipitation_sum'}))
                error('Unexpected API response structure. Try a shorter date range.');
            end

            % Extract data
            dates = datetime(string(data.daily.time),'InputFormat','yyyy-MM-dd');
            tempMax = double(data.daily.temperature_2m_max(:));
            tempMin = double(data.daily.temperature_2m_min(:));
            precipitation = double(data.daily.precipitation_sum(:));
            tempAvg = (tempMax + tempMin) / 2;
            dayNumbers = (1:numel(dates))';
            
            if numel(dayNumbers) < 10
                close(progressDlg);
                uialert(fig, 'Need at least 10 days of data for reliable fitting.', 'Not Enough Data');
                return;
            end

            % Perform fitting based on selected model
            modelType = modelDropdown.Value;
            progressDlg.Message = sprintf('Fitting %s model...', modelType);
            
            [tempPred, modelParams, modelEquation, rSquared, rmse] = fitModel(dayNumbers, tempAvg, dates, modelType);
            
            % Calculate statistics
            numDays = numel(tempAvg);
            avgTemp = mean(tempAvg);
            [minTemp, minIdx] = min(tempAvg);
            [maxTemp, maxIdx] = max(tempAvg);
            stdTemp = std(tempAvg);
            totalPrecip = sum(precipitation);
            tempRange = maxTemp - minTemp;
            
            progressDlg.Message = 'Creating visualizations...';

            % Update stat cards
            statCard1Text.Text = sprintf('%.4f', rSquared);
            statCard2Text.Text = modelType;
            statCard3Text.Text = sprintf('%.1f', avgTemp);
            
            % Calculate amplitude based on model type
            if strcmp(modelType, 'Sine')
                amplitude = modelParams.amplitude;
                statCard4Text.Text = sprintf('%.2f', amplitude);
            else
                statCard4Text.Text = 'N/A';
            end
            
            statCard5Text.Text = sprintf('%.2f', rmse);

            % Update model equation
            cityName = cityNameField.Value;
            if isempty(cityName)
                cityName = sprintf('Location (%.2f, %.2f)', latField.Value, lonField.Value);
            end
            modelText.Text = sprintf('Model for %s:  %s', cityName, modelEquation);

            % Create detailed stats text
            detailsText = createDetailedStats(modelType, modelParams, numDays, dates, ...
                avgTemp, minTemp, maxTemp, minIdx, maxIdx, tempRange, stdTemp, ...
                totalPrecip, rSquared, rmse);
            detailsTextArea.Value = detailsText;

            % Plot 1: Fitted model
            cla(fitAxes);
            scatter(fitAxes, dayNumbers, tempAvg, 20, 'filled', 'MarkerFaceAlpha', 0.5);
            hold(fitAxes, 'on');
            plot(fitAxes, dayNumbers, tempPred, 'r-', 'LineWidth', 2.5);
            xlabel(fitAxes, 'Day Number');
            ylabel(fitAxes, 'Average Temperature (°C)');
            title(fitAxes, sprintf('%s Model Fit (R² = %.4f, RMSE = %.2f°C)', modelType, rSquared, rmse));
            legend(fitAxes, 'Actual Temperature', sprintf('%s Fit', modelType), 'Location', 'best');
            grid(fitAxes, 'on');
            hold(fitAxes, 'off');

            % Plot 2: Temperature variations
            cla(tempAxes);
            plot(tempAxes, dates, tempMax, 'r-', 'LineWidth', 1.5);
            hold(tempAxes, 'on');
            plot(tempAxes, dates, tempMin, 'b-', 'LineWidth', 1.5);
            plot(tempAxes, dates, tempAvg, 'k-', 'LineWidth', 2);
            plot(tempAxes, dates, tempPred, 'm--', 'LineWidth', 2);
            xlabel(tempAxes, 'Date');
            ylabel(tempAxes, 'Temperature (°C)');
            title(tempAxes, 'Daily Temperature Variations');
            legend(tempAxes, 'Max', 'Min', 'Avg', sprintf('%s Fit', modelType), 'Location', 'best');
            grid(tempAxes, 'on');
            hold(tempAxes, 'off');

            % Plot 3: Residuals
            cla(residAxes);
            residuals = tempAvg - tempPred(:);
            scatter(residAxes, tempPred, residuals, 30, 'filled', 'MarkerFaceAlpha', 0.6);
            hold(residAxes, 'on');
            yline(residAxes, 0, 'r--', 'LineWidth', 2);
            xlabel(residAxes, 'Predicted Temperature (°C)');
            ylabel(residAxes, 'Residuals (°C)');
            title(residAxes, sprintf('Residual Plot (RMSE = %.2f°C)', rmse));
            grid(residAxes, 'on');
            hold(residAxes, 'off');

            % Plot 4: Precipitation
            cla(precipAxes);
            bar(precipAxes, dates, precipitation, 'FaceColor', [0.2 0.6 0.8]);
            xlabel(precipAxes, 'Date');
            ylabel(precipAxes, 'Precipitation (mm)');
            title(precipAxes, 'Daily Precipitation');
            grid(precipAxes, 'on');

            close(progressDlg);
            uialert(fig, 'Analysis completed successfully!', 'Success', 'Icon', 'success');
            
        catch ME
            if exist('progressDlg', 'var') && isvalid(progressDlg)
                close(progressDlg);
            end
            uialert(fig, sprintf('Error: %s', ME.message), 'Analysis Failed');
        end
    end

    function [tempPred, params, equation, rSquared, rmse] = fitModel(dayNumbers, tempAvg, ~, modelType)
        % Fit the selected model to the temperature data
        % dates parameter reserved for future use
        
        switch modelType
            case 'Sine'
                % Sine model: T(t) = A*sin(2π*t/P + φ) + C
                % where A = amplitude, P = period, φ = phase, C = vertical offset
                
                % Initial guess for parameters
                meanTemp = mean(tempAvg);
                amplitude0 = (max(tempAvg) - min(tempAvg)) / 2;
                period0 = 365.25; % Assume annual cycle
                phase0 = 0;
                
                % Define sine model function
                sineModel = @(p, t) p(1) * sin(2*pi*t/p(2) + p(3)) + p(4);
                
                % Fit using lsqcurvefit or fminsearch
                options = optimset('Display', 'off', 'MaxIter', 10000);
                initialParams = [amplitude0, period0, phase0, meanTemp];
                
                % Use fminsearch to minimize sum of squared errors
                costFunc = @(p) sum((tempAvg - sineModel(p, dayNumbers)).^2);
                fittedParams = fminsearch(costFunc, initialParams, options);
                
                % Extract parameters
                params.amplitude = abs(fittedParams(1));
                params.period = abs(fittedParams(2));
                params.phase = fittedParams(3);
                params.offset = fittedParams(4);
                
                % Predict
                tempPred = sineModel(fittedParams, dayNumbers);
                
                % Create equation string
                equation = sprintf('T(t) = %.2f·sin(2π·t/%.1f + %.2f) + %.2f', ...
                    params.amplitude, params.period, params.phase, params.offset);
                
            case 'Linear'
                % Linear regression
                p = polyfit(dayNumbers, tempAvg, 1);
                params.slope = p(1);
                params.intercept = p(2);
                tempPred = polyval(p, dayNumbers);
                equation = sprintf('T(t) = %.4f·t + %.2f', params.slope, params.intercept);
                
            case 'Polynomial (2nd)'
                % Quadratic polynomial
                p = polyfit(dayNumbers, tempAvg, 2);
                params.coeffs = p;
                tempPred = polyval(p, dayNumbers);
                equation = sprintf('T(t) = %.6f·t² + %.4f·t + %.2f', p(1), p(2), p(3));
                
            case 'Polynomial (3rd)'
                % Cubic polynomial
                p = polyfit(dayNumbers, tempAvg, 3);
                params.coeffs = p;
                tempPred = polyval(p, dayNumbers);
                equation = sprintf('T(t) = %.8f·t³ + %.6f·t² + %.4f·t + %.2f', p(1), p(2), p(3), p(4));
                
            case 'Polynomial (4th)'
                % Quartic polynomial
                p = polyfit(dayNumbers, tempAvg, 4);
                params.coeffs = p;
                tempPred = polyval(p, dayNumbers);
                equation = sprintf('T(t) = %.10f·t⁴ + %.8f·t³ + %.6f·t² + %.4f·t + %.2f', ...
                    p(1), p(2), p(3), p(4), p(5));
                
            otherwise
                error('Unknown model type: %s', modelType);
        end
        
        % Calculate R-squared
        ssRes = sum((tempAvg - tempPred).^2);
        ssTot = sum((tempAvg - mean(tempAvg)).^2);
        rSquared = 1 - ssRes / ssTot;
        
        % Calculate RMSE
        rmse = sqrt(mean((tempAvg - tempPred).^2));
    end

    function detailsText = createDetailedStats(modelType, params, numDays, dates, ...
            avgTemp, minTemp, maxTemp, minIdx, maxIdx, tempRange, stdTemp, ...
            totalPrecip, rSquared, rmse)
        
        detailsText = {
            sprintf('═══ Analysis Period ═══');
            sprintf('Number of days: %d', numDays);
            sprintf('Date range: %s to %s', datestr(dates(1)), datestr(dates(end)));
            '';
            sprintf('═══ Temperature Statistics ═══');
            sprintf('Average temperature: %.2f °C', avgTemp);
            sprintf('Minimum temperature: %.2f °C on %s', minTemp, datestr(dates(minIdx)));
            sprintf('Maximum temperature: %.2f °C on %s', maxTemp, datestr(dates(maxIdx)));
            sprintf('Temperature range: %.2f °C', tempRange);
            sprintf('Standard deviation: %.2f °C', stdTemp);
            '';
            sprintf('═══ Model Fitting Results (%s) ═══', modelType);
        };
        
        % Add model-specific parameters
        switch modelType
            case 'Sine'
                detailsText = [detailsText; {
                    sprintf('Amplitude: %.2f °C', params.amplitude);
                    sprintf('Period: %.1f days (%.2f years)', params.period, params.period/365.25);
                    sprintf('Phase shift: %.2f radians', params.phase);
                    sprintf('Vertical offset: %.2f °C', params.offset);
                    '';
                    sprintf('Interpretation:');
                    sprintf('  • Temperature varies by ±%.2f°C around %.2f°C', params.amplitude, params.offset);
                    sprintf('  • Seasonal cycle repeats every %.1f days', params.period);
                }];
                
            case 'Linear'
                tempChange = params.slope * numDays;
                detailsText = [detailsText; {
                    sprintf('Slope: %.4f °C per day', params.slope);
                    sprintf('Intercept: %.2f °C', params.intercept);
                    sprintf('Total temperature change: %.2f °C over %d days', tempChange, numDays);
                    '';
                    getTrendText(params.slope, tempChange);
                }];
                
            otherwise % Polynomial
                detailsText = [detailsText; {
                    sprintf('Polynomial coefficients:');
                    sprintf('  %s', mat2str(params.coeffs, 6));
                }];
        end
        
        % Add goodness of fit metrics
        detailsText = [detailsText; {
            '';
            sprintf('═══ Goodness of Fit ═══');
            sprintf('R-squared: %.4f (%.1f%% variance explained)', rSquared, rSquared*100);
            sprintf('RMSE: %.2f °C', rmse);
            '';
            getGoodnessText(rSquared);
            '';
            sprintf('═══ Precipitation ═══');
            sprintf('Total precipitation: %.2f mm', totalPrecip);
            sprintf('Average daily precipitation: %.2f mm', totalPrecip/numDays);
        }];
    end

    function trendText = getTrendText(slope, tempChange)
        if slope > 0.01
            trendText = sprintf('Trend: WARMING (%.2f °C increase)', tempChange);
        elseif slope < -0.01
            trendText = sprintf('Trend: COOLING (%.2f °C decrease)', abs(tempChange));
        else
            trendText = 'Trend: STABLE (no significant change)';
        end
    end

    function goodnessText = getGoodnessText(rSquared)
        if rSquared > 0.9
            goodnessText = 'Fit quality: EXCELLENT (>0.9) - Model captures data very well';
        elseif rSquared > 0.7
            goodnessText = 'Fit quality: GOOD (0.7-0.9) - Model explains most variation';
        elseif rSquared > 0.5
            goodnessText = 'Fit quality: MODERATE (0.5-0.7) - Model captures general trend';
        else
            goodnessText = 'Fit quality: POOR (<0.5) - Consider different model or more data';
        end
    end

    function [ok, startStr, endStr, errMsg] = validateDates(startVal, endVal)
        ok = false;
        startStr = '';
        endStr = '';
        errMsg = '';
        
        try
            sd = datetime(startVal, 'InputFormat', 'yyyy-MM-dd');
        catch
            errMsg = 'Start Date must be in YYYY-MM-DD format.';
            return;
        end
        
        try
            ed = datetime(endVal, 'InputFormat', 'yyyy-MM-dd');
        catch
            errMsg = 'End Date must be in YYYY-MM-DD format.';
            return;
        end
        
        if ed < sd
            errMsg = 'End Date must be on or after Start Date.';
            return;
        end
        
        startStr = datestr(sd, 'yyyy-mm-dd');
        endStr = datestr(ed, 'yyyy-mm-dd');
        ok = true;
    end

    % Initialize with default values for Montreal
    setQuickDateRange(365);
    selectCity('Montreal, Canada', 45.5017, -73.5673);
end
