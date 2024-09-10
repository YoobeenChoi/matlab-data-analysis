% Load the data from Excel
filename = 'control_analysis.xlsx';
data = readtable(filename);

% Extract relevant data columns
participant_id = data.participant_id;
age = data.Age;
gender = data.Sex;
mean_accuracy = data.all_accu;
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
figure;
hold on;
scatter(rt_male, accuracy_male, 'b', 'filled');  % Blue for males
scatter(rt_female, accuracy_female, 'r', 'filled');  % Red for females

% Add regression lines
p_male = polyfit(rt_male, accuracy_male, 1);  % Linear fit for males
p_female = polyfit(rt_female, accuracy_female, 1);  % Linear fit for females

% Plot regression lines
x_range = [min(reaction_time), max(reaction_time)];
y_male = polyval(p_male, x_range);
y_female = polyval(p_female, x_range);

plot(x_range, y_male, 'b-', 'LineWidth', 2);  % Regression line for males
plot(x_range, y_female, 'r-', 'LineWidth', 2);  % Regression line for females

% Plot Customization
xlabel('Reaction Time (sec)');
ylabel('Mean Accuracy (%)');
title('Scatterplot of Accuracy vs Reaction Time by Gender');
legend({'Males', 'Females', 'Male Regression', 'Female Regression'}, 'Location', 'best');
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