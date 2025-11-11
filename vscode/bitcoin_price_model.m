function [mdl, metrics, out] = bitcoin_price_model(priceTT, varargin)
%BITCOIN_PRICE_MODEL Train a simple regression model for BTC price.
%   [mdl, metrics, out] = bitcoin_price_model(T) where T is a timetable with
%   RowTimes as dates and variable Close, builds engineered features and
%   trains a linear model to predict next-day Close.
%
%   Name-Value:
%     HorizonDays (default 1)   - Predict Close t+HorizonDays
%     TrainRatio  (default 0.8) - Train/validation split ratio
%
%   Returns:
%     mdl     - Linear model (fitlm)
%     metrics - struct with rmse, mae, r2 on validation set
%     out     - struct with fields:
%                 .featuresTable  table of features and targets
%                 .yTrue, .yPred  validation actuals and predictions
%                 .forecast       timetable with Forecast for next N days

    p = inputParser;
    addParameter(p, 'HorizonDays', 1, @(x)isnumeric(x) && isscalar(x) && x>=1);
    addParameter(p, 'TrainRatio', 0.8, @(x)isnumeric(x) && x>0 && x<1);
    parse(p, varargin{:});
    H = round(p.Results.HorizonDays);
    trainRatio = p.Results.TrainRatio;

    % Validate input
    if ~istimetable(priceTT) || ~ismember('Close', string(priceTT.Properties.VariableNames))
        error('Input must be a timetable with variable Close.');
    end
    priceTT = sortrows(priceTT);
    closeVals = priceTT.Close(:);
    n = numel(closeVals);
    if n < max(60, H+20)
        error('Not enough observations. Need at least %d rows.', max(60, H+20));
    end

    % Feature engineering
    % - Log returns
    logP = log(closeVals);
    ret1 = [NaN; diff(logP)];
    % - Moving averages and momentum
    sma7  = movmean(closeVals, [6 0], 'omitnan');
    sma30 = movmean(closeVals, [29 0], 'omitnan');
    mom3  = [NaN(3,1); closeVals(4:end) - closeVals(1:end-3)];
    vol10 = movstd(ret1, [9 0], 'omitnan');
    % - Lagged returns
    lagRet1 = lagmatrix(ret1, 1);
    lagRet2 = lagmatrix(ret1, 2);
    lagRet3 = lagmatrix(ret1, 3);

    % Target: future close in H days
    yFuture = lagmatrix(closeVals, -H); % shift up by H to align features at t

    % Build table
    features = table(sma7, sma30, mom3, vol10, lagRet1, lagRet2, lagRet3, ret1, ...
        'VariableNames', {'SMA7','SMA30','Momentum3','Vol10','LagRet1','LagRet2','LagRet3','Ret1'});
    validIdx = all(isfinite([features.SMA7, features.SMA30, features.Momentum3, features.Vol10, ...
                             features.LagRet1, features.LagRet2, features.LagRet3, features.Ret1]), 2) & ...
               isfinite(yFuture);
    X = features(validIdx, :);
    y = yFuture(validIdx);
    % Access row times; timetable may have default time variable name different from 'Time'
    dates = priceTT.Properties.RowTimes(validIdx);

    % Train/validation split by time
    m = height(X);
    mTrain = max(10, floor(trainRatio * m));
    Xtr = X(1:mTrain, :); ytr = y(1:mTrain);
    Xva = X(mTrain+1:end, :); yva = y(mTrain+1:end);
    datesVa = dates(mTrain+1:end);

    % Train linear regression
    mdl = fitlm(Xtr, ytr, 'Intercept', true);

    % Validate
    yhat = predict(mdl, Xva);
    rmse = sqrt(mean((yva - yhat).^2));
    mae  = mean(abs(yva - yhat));
    r2   = 1 - sum((yva - yhat).^2) / sum((yva - mean(yva)).^2);

    metrics = struct('rmse', rmse, 'mae', mae, 'r2', r2, 'nTrain', mTrain, 'nVal', numel(yva));

    % Forecast next H days iteratively (one step per day using latest features)
    maxH = max(H, 1);
    % n retained for informational purposes; lastIdx no longer needed (removed to silence lint)
    simClose = closeVals; % copy we can extend
    simDates = priceTT.Properties.RowTimes;
    for k = 1:maxH
        % Compute features at last point
        logPsim = log(simClose);
        retsim = [NaN; diff(logPsim)];
        s7  = movmean(simClose, [6 0], 'omitnan'); s7 = s7(end);
        s30 = movmean(simClose, [29 0], 'omitnan'); s30 = s30(end);
        m3  = NaN;
        if numel(simClose) >= 4
            m3 = simClose(end) - simClose(end-3);
        end
        v10 = NaN; if numel(retsim) >= 10, v10 = std(retsim(end-9:end), 'omitnan'); end
        lr1 = NaN; lr2 = NaN; lr3 = NaN;
        if numel(retsim) >= 3
            lr1 = retsim(end);
            lr2 = retsim(end-1);
            lr3 = retsim(end-2);
        end
        r1 = retsim(end);
        featRow = table(s7, s30, m3, v10, lr1, lr2, lr3, r1, 'VariableNames', X.Properties.VariableNames);
        % Predict next close
        nextClose = predict(mdl, featRow);
        % Append
        simClose(end+1,1) = nextClose; %#ok<AGROW>
        simDates(end+1,1) = simDates(end) + days(1); %#ok<AGROW>
    end

    fcDates = simDates(end-maxH+1:end);
    fcVals  = simClose(end-maxH+1:end);
    forecastTT = timetable(fcDates, fcVals, 'VariableNames', {'Forecast'});

    out = struct();
    out.featuresTable = table(dates, X, y, 'VariableNames', {'Date','Features','Target'});
    out.yTrue = yva; out.yPred = yhat; out.valDates = datesVa;
    out.forecast = forecastTT;
end
