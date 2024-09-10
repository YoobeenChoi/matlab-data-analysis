% Load the data from Excel
filename = 'control_analysis.xlsx';
data = readtable(filename);

% Extract relevant data columns
age = data.Age;
reaction_time = data.rt_mean_overall;

% Scatterplot
figure;
scatter(age, reaction_time, 60, 'filled');  % Scatter plot with circular markers
hold on;

% Add a regression line
p = polyfit(age,reaction_time,1); % Linear fit
x_range = [min(age), max(age)];
y_fit = polyval(p, x_range); 

plot(x_range, y_fit, 'r-', 'LineWidth', 2);  % Plot the regression line in red

% Plot Customization
xlabel('Age (years)');
ylabel('Reaction Time (sec)');
title('Scatterplot of Reaction Time by Age');
grid on;
hold off;

% Pearson correlation coefficient and P-value
[r, p_value] = corr(age, reaction_time, 'Type', 'Pearson');

disp(['Pearson correlation coefficient: ', num2str(r)]);
disp(['p-value: ', num2str(p_value)]);