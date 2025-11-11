% Create a linear regression on small car sample dataset
load carsmall; % Load the car sample dataset
X = [Weight, Horsepower]; % Predictor variables
Y = MPG; % Response variable
mdl = fitlm(X, Y); % Fit linear regression model

% Display the coefficients of the fitted model
coefficients = mdl.Coefficients.Estimate;
disp('Coefficients of the linear regression model:');
disp(coefficients);

% Plot
figure;
scatter3(X(:,1), X(:,2), Y, 'filled'); % Scatter plot of the data
hold on;
% Create a grid for the regression plane
[x1Grid, x2Grid] = meshgrid(linspace(min(X(:,1)), max(X(:,1)), 20), linspace(min(X(:,2)), max(X(:,2)), 20));
% Predict response values for the grid
YGrid = predict(mdl, [x1Grid(:), x2Grid(:)]);
% Reshape the predicted values to match the grid
YGrid = reshape(YGrid, size(x1Grid));
% Plot the regression plane
surf(x1Grid, x2Grid, YGrid, 'FaceAlpha', 0.5);
xlabel('Horsepower'); % Flipped axis
ylabel('Weight');     % Flipped axis
zlabel('MPG');
title('Linear Regression Fit');
hold off;

