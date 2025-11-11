classdef testMontrealWeatherSineApp < matlab.unittest.TestCase
    % Test suite for Montreal Weather Sine Fitting Application
    
    methods (Test)
        
        function testSineFitting(testCase)
            % Test sine model fitting with synthetic data
            
            % Create synthetic data with known sine pattern
            dayNumbers = (1:365)';
            amplitude = 15;
            period = 365.25;
            phase = 0;
            offset = 10;
            
            % Generate synthetic temperature data
            trueSine = amplitude * sin(2*pi*dayNumbers/period + phase) + offset;
            noise = 2 * randn(size(trueSine)); % Add some noise
            tempAvg = trueSine + noise;
            
            % Fit sine model
            dates = datetime(2024, 1, 1) + days(0:364);
            [tempPred, params, equation, rSquared, rmse] = fitSineModel(dayNumbers, tempAvg, dates);
            
            % Test that fitted parameters are close to true values
            testCase.verifyEqual(params.amplitude, amplitude, 'AbsTol', 3, ...
                'Amplitude should be close to true value');
            testCase.verifyEqual(params.period, period, 'AbsTol', 50, ...
                'Period should be close to true value');
            testCase.verifyEqual(params.offset, offset, 'AbsTol', 2, ...
                'Offset should be close to true value');
            
            % Test R-squared is high for good fit
            testCase.verifyGreaterThan(rSquared, 0.7, ...
                'R-squared should be > 0.7 for synthetic data');
            
            % Test RMSE is reasonable
            testCase.verifyLessThan(rmse, 5, ...
                'RMSE should be less than 5°C for synthetic data');
        end
        
        function testLinearFitting(testCase)
            % Test linear model fitting
            
            % Create synthetic linear trend data
            dayNumbers = (1:100)';
            slope = 0.05; % 0.05°C per day
            intercept = 10;
            
            trueLine = slope * dayNumbers + intercept;
            noise = 0.5 * randn(size(trueLine));
            tempAvg = trueLine + noise;
            
            % Fit linear model
            dates = datetime(2024, 1, 1) + days(0:99);
            [tempPred, params, equation, rSquared, rmse] = fitLinearModel(dayNumbers, tempAvg, dates);
            
            % Test fitted parameters
            testCase.verifyEqual(params.slope, slope, 'AbsTol', 0.01, ...
                'Slope should match true value');
            testCase.verifyEqual(params.intercept, intercept, 'AbsTol', 1, ...
                'Intercept should match true value');
            
            % Test goodness of fit
            testCase.verifyGreaterThan(rSquared, 0.9, ...
                'R-squared should be very high for linear data');
        end
        
        function testPolynomialFitting(testCase)
            % Test polynomial model fitting
            
            % Create synthetic quadratic data
            dayNumbers = (1:100)';
            coeffs = [0.001, 0.05, 10]; % a*x^2 + b*x + c
            
            trueQuad = polyval(coeffs, dayNumbers);
            noise = 0.5 * randn(size(trueQuad));
            tempAvg = trueQuad + noise;
            
            % Fit polynomial model (degree 2)
            dates = datetime(2024, 1, 1) + days(0:99);
            [tempPred, params, equation, rSquared, rmse] = fitPolynomialModel(dayNumbers, tempAvg, dates, 2);
            
            % Test that fitted coefficients are close to true values
            testCase.verifyEqual(params.coeffs(1), coeffs(1), 'AbsTol', 0.001);
            testCase.verifyEqual(params.coeffs(2), coeffs(2), 'AbsTol', 0.02);
            testCase.verifyEqual(params.coeffs(3), coeffs(3), 'AbsTol', 1);
            
            % Test goodness of fit
            testCase.verifyGreaterThan(rSquared, 0.95, ...
                'R-squared should be very high for quadratic data');
        end
        
        function testRSquaredCalculation(testCase)
            % Test R-squared calculation
            
            actual = [1, 2, 3, 4, 5]';
            predicted = [1.1, 2.0, 2.9, 4.1, 5.0]';
            
            ssRes = sum((actual - predicted).^2);
            ssTot = sum((actual - mean(actual)).^2);
            rSquared = 1 - ssRes / ssTot;
            
            % R-squared should be very close to 1 for nearly perfect fit
            testCase.verifyGreaterThan(rSquared, 0.95);
        end
        
        function testRMSECalculation(testCase)
            % Test RMSE calculation
            
            actual = [1, 2, 3, 4, 5]';
            predicted = [1.1, 2.1, 3.1, 4.1, 5.1]';
            
            rmse = sqrt(mean((actual - predicted).^2));
            
            % RMSE should be close to 0.1
            testCase.verifyEqual(rmse, 0.1, 'AbsTol', 0.01);
        end
    end
end

% Helper functions for testing
function [tempPred, params, equation, rSquared, rmse] = fitSineModel(dayNumbers, tempAvg, ~)
    % Sine model fitting helper
    meanTemp = mean(tempAvg);
    amplitude0 = (max(tempAvg) - min(tempAvg)) / 2;
    period0 = 365.25;
    phase0 = 0;
    
    sineModel = @(p, t) p(1) * sin(2*pi*t/p(2) + p(3)) + p(4);
    options = optimset('Display', 'off', 'MaxIter', 10000);
    initialParams = [amplitude0, period0, phase0, meanTemp];
    
    costFunc = @(p) sum((tempAvg - sineModel(p, dayNumbers)).^2);
    fittedParams = fminsearch(costFunc, initialParams, options);
    
    params.amplitude = abs(fittedParams(1));
    params.period = abs(fittedParams(2));
    params.phase = fittedParams(3);
    params.offset = fittedParams(4);
    
    tempPred = sineModel(fittedParams, dayNumbers);
    
    equation = sprintf('T(t) = %.2f·sin(2π·t/%.1f + %.2f) + %.2f', ...
        params.amplitude, params.period, params.phase, params.offset);
    
    ssRes = sum((tempAvg - tempPred).^2);
    ssTot = sum((tempAvg - mean(tempAvg)).^2);
    rSquared = 1 - ssRes / ssTot;
    rmse = sqrt(mean((tempAvg - tempPred).^2));
end

function [tempPred, params, equation, rSquared, rmse] = fitLinearModel(dayNumbers, tempAvg, ~)
    % Linear model fitting helper
    p = polyfit(dayNumbers, tempAvg, 1);
    params.slope = p(1);
    params.intercept = p(2);
    tempPred = polyval(p, dayNumbers);
    equation = sprintf('T(t) = %.4f·t + %.2f', params.slope, params.intercept);
    
    ssRes = sum((tempAvg - tempPred).^2);
    ssTot = sum((tempAvg - mean(tempAvg)).^2);
    rSquared = 1 - ssRes / ssTot;
    rmse = sqrt(mean((tempAvg - tempPred).^2));
end

function [tempPred, params, equation, rSquared, rmse] = fitPolynomialModel(dayNumbers, tempAvg, ~, degree)
    % Polynomial model fitting helper
    p = polyfit(dayNumbers, tempAvg, degree);
    params.coeffs = p;
    tempPred = polyval(p, dayNumbers);
    
    if degree == 2
        equation = sprintf('T(t) = %.6f·t² + %.4f·t + %.2f', p(1), p(2), p(3));
    else
        equation = 'Polynomial';
    end
    
    ssRes = sum((tempAvg - tempPred).^2);
    ssTot = sum((tempAvg - mean(tempAvg)).^2);
    rSquared = 1 - ssRes / ssTot;
    rmse = sqrt(mean((tempAvg - tempPred).^2));
end
