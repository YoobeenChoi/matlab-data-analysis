% Load the data from Excel
filename = 'sbj_perform.xlsx';
data = readtable(filename);

% Extract relevant data columns
participant_id = data.participant_id;
age = data.Age;
gender = data.Sex;
mean_accuracy = data.all_accu * 100;
reaction_time = data.rt_mean_overall;

% Separate data based on gender
male_indices = strcmp(gender, 'M');
female_indices = strcmp(gender, 'F');

% Extract accuracy and reaction time by gender
accuracy_male = mean_accuracy(male_indices);
rt_male = reaction_time(male_indices);
accuracy_female = mean_accuracy(female_indices);
rt_female = reaction_time(female_indices);

% Scatterplot
figure('Position', [100, 100, 800, 600]);
hold on;
scatter(rt_male, accuracy_male, 60, [0.2 0.6 0.8], 'filled');  % Light blue for males
scatter(rt_female, accuracy_female, 60, [0.9 0.4 0.6], 'filled');  % Pink for females

% Add regression lines
p_male = polyfit(rt_male, accuracy_male, 1);  % Linear fit for males
p_female = polyfit(rt_female, accuracy_female, 1);  % Linear fit for females

% Plot regression lines
x_range = [0,1];
y_male = polyval(p_male, x_range);
y_female = polyval(p_female, x_range);

plot(x_range, y_male, 'Color', [0.2 0.6 0.8], 'LineWidth', 2);  % regression line for males
plot(x_range, y_female, 'Color', [0.9 0.4 0.6], 'LineWidth', 2);  % regression line for females

% Plot Customization
xlabel('Reaction Time (sec)', 'FontSize', 14);
ylabel('Mean Accuracy (%)', 'FontSize', 14);
title('Scatterplot of Accuracy vs Reaction Time by Gender', 'FontSize', 16, ...
    'Units', 'normalized', 'Position', [0.5, 1.05, 0]);
legend({'Male', 'Female', 'Male Regression', 'Female Regression'}, 'Location', 'eastoutside','FontSize', 12);
set(gca, 'Position', [0.1, 0.1, 0.7, 0.8], 'FontSize', 12);  % Adjust axis to leave room for legend
xlim([0 1]); 
ylim([0 100]);
grid on;
hold off;

% Calculate Pearson correlation coefficient for males
[r_male, p_male] = corr(rt_male, accuracy_male, 'Type', 'Pearson');
disp(['Correlation coefficient for males: ', num2str(r_male)]);
disp(['p-value for males: ', num2str(p_male)]);

% Calculate Pearson correlation coefficient for females
[r_female, p_female] = corr(rt_female, accuracy_female, 'Type', 'Pearson');
disp(['Correlation coefficient for females: ', num2str(r_female)]);
disp(['p-value for females: ', num2str(p_female)]);