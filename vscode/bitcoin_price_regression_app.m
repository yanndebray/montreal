function bitcoin_price_regression_app()
%BITCOIN_PRICE_REGRESSION_APP Interactive UI for Bitcoin price trend & forecast.
%  Provides:
%    - Load sample or user CSV
%    - Display price chart with moving averages
%    - Train linear regression next-day prediction model
%    - Show validation metrics & residuals
%    - Forecast next N days and plot
%    - Export forecast to CSV
%  DISCLAIMER: Educational demo only. Not financial advice.

    % FIGURE
    fig = uifigure('Name','📈 Bitcoin Price Forecaster', 'Position',[120 120 1280 820], 'Color',[0.96 0.97 0.985]);
    gl = uigridlayout(fig, [3,1]); gl.RowHeight = {220, 30, '1x'}; gl.ColumnWidth = {'1x'};

    % TOP PANEL
    top = uipanel(gl, 'BackgroundColor','white'); top.Layout.Row = 1; top.Layout.Column = 1;
    topGrid = uigridlayout(top, [7,6]); topGrid.RowHeight = {34,34,34,34,34,34,'1x'}; topGrid.ColumnWidth = {120,140,140,140,140,'1x'}; topGrid.Padding = [16 16 16 16];

    titleLbl = uilabel(topGrid, 'Text','📈 Bitcoin Price Forecaster (Linear Regression)', 'FontSize',18,'FontWeight','bold','FontColor',[0.2 0.3 0.55]);
    titleLbl.Layout.Row = 1; titleLbl.Layout.Column = [1 6]; titleLbl.HorizontalAlignment = 'center';

    % Data load section
    dsLbl = uilabel(topGrid,'Text','Data Source:','FontWeight','bold'); dsLbl.Layout.Row = 2; dsLbl.Layout.Column = 1;
    sourceDD = uidropdown(topGrid, 'Items',{'Sample','CSV File'}, 'Value','Sample'); sourceDD.Layout.Row = 2; sourceDD.Layout.Column = 2;
    fileField = uieditfield(topGrid,'text','Placeholder','Path to CSV...'); fileField.Layout.Row = 2; fileField.Layout.Column = [3 4];
    browseBtn = uibutton(topGrid,'Text','Browse','ButtonPushedFcn',@(~,~)browseFile()); browseBtn.Layout.Row = 2; browseBtn.Layout.Column = 5;

    % Horizon and export
    fdLbl = uilabel(topGrid,'Text','Forecast Days:','FontWeight','bold'); fdLbl.Layout.Row = 3; fdLbl.Layout.Column = 1;
    forecastSpinner = uispinner(topGrid,'Value',5,'Limits',[1 30]); forecastSpinner.Layout.Row = 3; forecastSpinner.Layout.Column = 2;
    trLbl = uilabel(topGrid,'Text','Train Ratio:','FontWeight','bold'); trLbl.Layout.Row = 3; trLbl.Layout.Column = 3;
    trainRatioSlider = uislider(topGrid,'Limits',[0.6 0.95],'Value',0.8); trainRatioSlider.Layout.Row = 3; trainRatioSlider.Layout.Column = [4 5];

    % Actions
    loadBtn = uibutton(topGrid,'Text','📂 Load Data','ButtonPushedFcn',@(~,~)loadData(),'FontWeight','bold'); loadBtn.Layout.Row = 4; loadBtn.Layout.Column = 2; loadBtn.BackgroundColor = [0.85 0.92 1];
    trainBtn = uibutton(topGrid,'Text','🧠 Train Model','ButtonPushedFcn',@(~,~)trainModel(),'FontWeight','bold'); trainBtn.Layout.Row = 4; trainBtn.Layout.Column = 3; trainBtn.BackgroundColor = [0.8 0.9 0.8];
    forecastBtn = uibutton(topGrid,'Text','🔮 Forecast','ButtonPushedFcn',@(~,~)doForecast(),'FontWeight','bold'); forecastBtn.Layout.Row = 4; forecastBtn.Layout.Column = 4; forecastBtn.BackgroundColor = [0.95 0.85 0.85];
    exportBtn = uibutton(topGrid,'Text','💾 Export CSV','ButtonPushedFcn',@(~,~)exportForecast(),'FontWeight','bold'); exportBtn.Layout.Row = 4; exportBtn.Layout.Column = 5; exportBtn.BackgroundColor = [0.9 0.85 0.95];

    % Status / disclaimer
    statusArea = uitextarea(topGrid,'Value',{'Status: Ready','Disclaimer: Educational demo only.'},'Editable','off'); statusArea.Layout.Row = [6 7]; statusArea.Layout.Column = [1 6]; statusArea.FontSize = 11;

    % MINI BAR (SECOND ROW)
    barPanel = uipanel(gl,'BackgroundColor',[0.94 0.96 0.99]); barPanel.Layout.Row = 2; barPanel.Layout.Column = 1; barGrid = uigridlayout(barPanel,[1,6]); barGrid.ColumnWidth = {200,200,200,200,200,'1x'};
    metricRMSE = uilabel(barGrid,'Text','RMSE: --','FontWeight','bold');
    metricMAE  = uilabel(barGrid,'Text','MAE: --','FontWeight','bold');
    metricR2   = uilabel(barGrid,'Text','R²: --','FontWeight','bold');
    metricTrain = uilabel(barGrid,'Text','Train: --','FontWeight','bold');
    metricVal   = uilabel(barGrid,'Text','Val: --','FontWeight','bold');

    % MAIN TABS
    mainPanel = uipanel(gl,'BackgroundColor',[0.96 0.97 0.985]); mainPanel.Layout.Row = 3; mainPanel.Layout.Column = 1; mpGrid = uigridlayout(mainPanel,[1,1]);
    tabs = uitabgroup(mpGrid); tabs.Layout.Row = 1; tabs.Layout.Column = 1;
    tabPrices = uitab(tabs,'Title','Price & Averages');
    tabResiduals = uitab(tabs,'Title','Residuals');
    tabForecast = uitab(tabs,'Title','Forecast');
    tabFeatures = uitab(tabs,'Title','Feature Importance');

    priceAxes = uiaxes(uigridlayout(tabPrices,[1,1])); priceAxes.Layout.Row = 1; priceAxes.Layout.Column = 1; title(priceAxes,'BTC Close Price'); xlabel(priceAxes,'Date'); ylabel(priceAxes,'USD'); grid(priceAxes,'on');
    residAxes = uiaxes(uigridlayout(tabResiduals,[1,1])); residAxes.Layout.Row = 1; residAxes.Layout.Column = 1; title(residAxes,'Validation Residuals'); xlabel(residAxes,'Date'); ylabel(residAxes,'Error'); grid(residAxes,'on');
    forecastAxes = uiaxes(uigridlayout(tabForecast,[1,1])); forecastAxes.Layout.Row = 1; forecastAxes.Layout.Column = 1; title(forecastAxes,'Forecast'); xlabel(forecastAxes,'Date'); ylabel(forecastAxes,'USD'); grid(forecastAxes,'on');
    featAxes = uiaxes(uigridlayout(tabFeatures,[1,1])); featAxes.Layout.Row = 1; featAxes.Layout.Column = 1; title(featAxes,'Feature Coefficients (Absolute)'); grid(featAxes,'on');

    % STATE
    dataTT = []; model = []; modelOut = []; lastForecastTT = []; lastMetrics = [];

    %% Callbacks
    function browseFile()
        [f,p] = uigetfile('*.csv','Select Bitcoin CSV');
        if isequal(f,0); return; end
        fileField.Value = fullfile(p,f); sourceDD.Value = 'CSV File';
    end

    function loadData()
        try
            if strcmp(sourceDD.Value,'Sample')
                dataTT = fetch_bitcoin_data("sample");
                status('Loaded sample data.');
            else
                fp = strtrim(fileField.Value);
                if isempty(fp); uialert(fig,'Enter a CSV path.','Missing'); return; end
                dataTT = fetch_bitcoin_data("file", fp);
                status(sprintf('Loaded %d rows from file.', height(dataTT)));
            end
            plotPrices();
        catch ME
            uialert(fig, ME.message,'Load Error');
        end
    end

    function plotPrices()
        if isempty(dataTT); return; end
        cla(priceAxes);
        plot(priceAxes, dataTT.Time, dataTT.Close,'Color',[0.1 0.35 0.6],'LineWidth',1.3); hold(priceAxes,'on');
        % Overlays moving averages
        sma7 = movmean(dataTT.Close,[6 0]); sma30 = movmean(dataTT.Close,[29 0]);
        plot(priceAxes, dataTT.Time, sma7,'Color',[0.85 0.2 0.2],'LineWidth',1.2);
        plot(priceAxes, dataTT.Time, sma30,'Color',[0.2 0.6 0.2],'LineWidth',1.2);
        legend(priceAxes,{'Close','SMA7','SMA30'},'Location','best'); hold(priceAxes,'off');
    end

    function trainModel()
        if isempty(dataTT); uialert(fig,'Load data first.','No Data'); return; end
        try
            H = forecastSpinner.Value;
            tr = trainRatioSlider.Value;
            [model, lastMetrics, modelOut] = bitcoin_price_model(dataTT, 'HorizonDays', H, 'TrainRatio', tr);
            metricRMSE.Text = sprintf('RMSE: %.2f', lastMetrics.rmse);
            metricMAE.Text  = sprintf('MAE: %.2f', lastMetrics.mae);
            metricR2.Text   = sprintf('R²: %.3f', lastMetrics.r2);
            metricTrain.Text= sprintf('Train: %d', lastMetrics.nTrain);
            metricVal.Text  = sprintf('Val: %d', lastMetrics.nVal);
            status('Model trained successfully.');
            plotResiduals(); plotFeatures();
        catch ME
            uialert(fig, ME.message,'Training Error');
        end
    end

    function plotResiduals()
        if isempty(modelOut); return; end
        yTrue = modelOut.yTrue; yPred = modelOut.yPred; dt = modelOut.valDates;
        cla(residAxes); stem(residAxes, dt, yTrue - yPred,'filled'); hold(residAxes,'on'); yline(residAxes,0,'r--','LineWidth',1.5); hold(residAxes,'off');
        if ~isempty(lastMetrics)
            title(residAxes, sprintf('Residuals (RMSE %.2f, MAE %.2f)', lastMetrics.rmse, lastMetrics.mae));
        end
    end

    function plotFeatures()
        if isempty(model); return; end
        coeffs = model.Coefficients.Estimate(2:end); % exclude intercept
        names  = model.PredictorNames;
        [~, idx] = sort(abs(coeffs), 'descend');
        cla(featAxes); bar(featAxes, abs(coeffs(idx)), 'FaceColor',[0.3 0.5 0.8]); xticks(featAxes,1:numel(idx)); xticklabels(featAxes, names(idx)); xtickangle(featAxes,30);
        ylabel(featAxes,'|Coefficient|');
    end

    function doForecast()
        if isempty(modelOut) || isempty(model); uialert(fig,'Train model first.','No Model'); return; end
        lastForecastTT = modelOut.forecast; % Already produced forecast horizon
        cla(forecastAxes);
        plot(forecastAxes, dataTT.Time, dataTT.Close,'Color',[0.1 0.35 0.6]); hold(forecastAxes,'on');
        plot(forecastAxes, lastForecastTT.Time, lastForecastTT.Forecast,'r--o','LineWidth',1.4,'MarkerSize',5,'MarkerFaceColor','r');
        legend(forecastAxes,{'Historical','Forecast'},'Location','best'); hold(forecastAxes,'off');
        status(sprintf('Forecast generated for %d days.', height(lastForecastTT)));
    end

    function exportForecast()
        if isempty(lastForecastTT); uialert(fig,'Generate a forecast first.','No Forecast'); return; end
        [f,p] = uiputfile('forecast.csv','Save Forecast CSV'); if isequal(f,0); return; end
        outTbl = timetable2table(lastForecastTT); writetable(outTbl, fullfile(p,f));
        status('Forecast exported.');
    end

    function status(msg)
        statusArea.Value = {['Status: ' msg], 'Disclaimer: Educational demo only.'};
    end

    % Auto-load sample on start
    loadData();
end
