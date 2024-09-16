% Load data
filename = '/Users/yoobeenchoi/Documents/SNU/Data/control_analysis.xlsx'; 
data = readtable(filename);

Age = data.Age;  % Column for Age
rt_odt = data.rt_odt;  % Column for ODT reaction time
rt_mean_overall = data.rt_mean_overall;  % Column for OCAT reaction time

% Remove rows where any data is NaN (for ODT)
valid_indices_odt = ~isnan(Age) & ~isnan(rt_odt);
Age_clean_odt = Age(valid_indices_odt);
rt_odt_clean = rt_odt(valid_indices_odt);

% Remove rows where any data is NaN (for OCAT)
valid_indices_ocat = ~isnan(Age) & ~isnan(rt_mean_overall);
Age_clean_ocat = Age(valid_indices_ocat);
rt_mean_overall_clean = rt_mean_overall(valid_indices_ocat);

% Correlation coefficient and p-value for ODT reaction time vs Age
[r_odt, p_odt] = corr(Age_clean_odt, rt_odt_clean);

% Correlation coefficient and p-value for OCAT reaction time vs Age
[r_ocat, p_ocat] = corr(Age_clean_ocat, rt_mean_overall_clean);

% Display the results
disp(['Correlation coefficient (ODT vs Age): ', num2str(r_odt)]);
disp(['p-value (ODT vs Age): ', num2str(p_odt)]);
disp(['Correlation coefficient (OCAT vs Age): ', num2str(r_ocat)]);
disp(['p-value (OCAT vs Age): ', num2str(p_ocat)]);

% Plotting the ODT reaction time and OCAT reaction time vs. Age
figure('Position', [100, 100, 800, 600]); 
hold on;

% Scatterplot for ODT reaction time
scatter(Age_clean_odt, rt_odt_clean, 'filled', 'MarkerEdgeColor', [0.5, 0, 0.5], 'MarkerFaceColor', [0.7, 0.3, 0.7]);

% Regression line for ODT
p1 = polyfit(Age_clean_odt, rt_odt_clean, 1); 
yfit1 = polyval(p1, Age_clean_odt);
plot(Age_clean_odt, yfit1, '-', 'Color', [0.5, 0, 0.5], 'LineWidth', 1.5);

% Scatterplot for OCAT reaction time
scatter(Age_clean_ocat, rt_mean_overall_clean, 'filled', 'MarkerEdgeColor', [0.3, 0.75, 0.93], 'MarkerFaceColor', [0.3, 0.75, 0.93]);  

% Fit and plot regression line for OCAT
p2 = polyfit(Age_clean_ocat, rt_mean_overall_clean, 1); 
yfit2 = polyval(p2, Age_clean_ocat);
plot(Age_clean_ocat, yfit2, '-', 'Color', [0.3, 0.75, 0.93], 'LineWidth', 1.5); 

% Plot customization
xlabel('Age', 'FontSize', 14);  % X-axis label
ylabel('Reaction Time (seconds)', 'FontSize', 14);   % Y-axis label
title('Relationship Between ODT and OCAT Reaction Times by Age', 'FontSize', 16);  % Title
ylim([0 1.5]);  % Set y-axis to scale 0-1.5
yticks(0:0.1:1.5);
grid on;

% Move the legend outside the plot and adjust its labels
legend({'ODT Reaction Time', 'ODT Regression', 'OCAT Reaction Time', 'OCAT Regression'}, 'Location', 'eastoutside', 'FontSize', 12);

% font size for labels
set(gca, 'FontSize', 12);

hold off;

% independent t-test to compare ODT and OCAT reaction times
[h, p_value, ci, stats] = ttest2(rt_odt_clean, rt_mean_overall_clean);

% Display the results
disp(['Independent t-test p-value: ', num2str(p_value)]);
disp(['T-statistic: ', num2str(stats.tstat)]);
disp(['Degrees of freedom: ', num2str(stats.df)]);
disp(['Confidence interval: [', num2str(ci(1)), ', ', num2str(ci(2)), ']']);