% Linear Regression Example
% This script demonstrates simple linear regression in MATLAB

% Clear workspace and command window
clear;
clc;

% Generate sample data
% Let's create data with a linear relationship: y = 2x + 3 + noise
fprintf('Generating sample data...\n');
x = (1:50)';  % Independent variable (column vector)
true_slope = 2;
true_intercept = 3;
noise = randn(50, 1) * 5;  % Add some random noise
y = true_slope * x + true_intercept + noise;  % Dependent variable

% Perform linear regression using polyfit (degree 1 for linear)
fprintf('Performing linear regression...\n');
p = polyfit(x, y, 1);  % Returns [slope, intercept]
slope = p(1);
intercept = p(2);

% Calculate R-squared value
y_pred = polyval(p, x);
ss_res = sum((y - y_pred).^2);
ss_tot = sum((y - mean(y)).^2);
r_squared = 1 - (ss_res / ss_tot);

% Display results
fprintf('\n--- Linear Regression Results ---\n');
fprintf('Equation: y = %.4f * x + %.4f\n', slope, intercept);
fprintf('R-squared: %.4f\n', r_squared);
fprintf('True slope: %.4f, Estimated slope: %.4f\n', true_slope, slope);
fprintf('True intercept: %.4f, Estimated intercept: %.4f\n', true_intercept, intercept);

% Create visualization
figure('Position', [100, 100, 800, 600]);

% Plot original data points
scatter(x, y, 50, 'b', 'filled', 'DisplayName', 'Data Points');
hold on;

% Plot regression line
x_line = linspace(min(x), max(x), 100);
y_line = polyval(p, x_line);
plot(x_line, y_line, 'r-', 'LineWidth', 2, 'DisplayName', 'Regression Line');

% Add labels and legend
xlabel('X');
ylabel('Y');
title(sprintf('Linear Regression (R^2 = %.4f)', r_squared));
legend('Location', 'northwest');
grid on;
hold off;

fprintf('\nPlot created successfully!\n');
