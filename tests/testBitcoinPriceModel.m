function tests = testBitcoinPriceModel
% Basic tests for bitcoin_price_model using sample data
    tests = functiontests(localfunctions);
end

function setupOnce(testCase)
    % Load sample data once
    thisFile = mfilename("fullpath");
    root = fileparts(fileparts(thisFile)); % up from tests/
    csvPath = fullfile(root, "data", "bitcoin_sample_prices.csv");
    T = readtable(csvPath);
    dt = datetime(T.Date,'InputFormat','yyyy-MM-dd');
    testCase.TestData.priceTT = timetable(dt, double(T.Close), 'VariableNames', {'Close'});
end

function testModelTrainsAndForecasts(testCase)
    T = testCase.TestData.priceTT;
    [mdl, metrics, out] = bitcoin_price_model(T, 'HorizonDays', 5, 'TrainRatio', 0.8);
    verifyClass(testCase, mdl, 'LinearModel');
    verifyGreaterThan(testCase, metrics.r2, -Inf);
    verifyGreaterThan(testCase, metrics.rmse, 0);
    verifyEqual(testCase, height(out.forecast), 5);
end
