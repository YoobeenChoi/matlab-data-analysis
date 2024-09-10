% Load the data from Excel
filename = 'control_analysis.xlsx';
data = readtable(filename);

% Extract relevant columns
gender = data.Sex;            
accuracy_first_half = data.first_h_accu;
accuracy_second_half = data.second_h_accu;

% Separate data by gender
male_indices = strcmp(gender, 'M');
female_indices = strcmp(gender, 'F');

% Two-way repeated measures ANOVA
subjects = (1:length(gender))';  
accuracy = [accuracy_first_half, accuracy_second_half]; 

anova_data = table(subjects, gender, accuracy_first_half, accuracy_second_half, ...
                   'VariableNames', {'Subject', 'Gender', 'FirstHalf', 'SecondHalf'});

% Define the repeated measures factor (Half: first vs second half)
WithinDesign = table([1; 2], 'VariableNames', {'Half'});  % 1 = First Half, 2 = Second Half

% Run the repeated measures ANOVA with Gender as a between-subjects factor
rm_model = fitrm(anova_data, 'FirstHalf-SecondHalf ~ Gender', 'WithinDesign', WithinDesign);

ranova_result = ranova(rm_model, 'WithinModel', 'Half');
disp(ranova_result);

% Interaction effect
mean_accuracy_male = [mean(accuracy_first_half(male_indices)), mean(accuracy_second_half(male_indices))];
mean_accuracy_female = [mean(accuracy_first_half(female_indices)), mean(accuracy_second_half(female_indices))];

figure;
hold on;
plot([1 2], mean_accuracy_male, '-o', 'Color', [0.13 0.55 0.13], 'LineWidth', 2, 'DisplayName', 'Males');
plot([1 2], mean_accuracy_female, '-o', 'Color', [1 0.75 0.8], 'LineWidth', 2, 'DisplayName', 'Females');

% Plot Customization
xticks([1 2]);
xticklabels({'First Half', 'Second Half'});
xlabel('Task Half');
ylabel('Mean Accuracy (%)');
title('Accuracy Comparison Between First and Second Half by Gender');
legend('Location', 'best');
grid on;
hold off;
