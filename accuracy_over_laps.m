filename = 'event_table_MR.xlsx'; % Specify the name of the file
sheets = sheetnames(filename); % Get the names of all the sheets inside the file (one for each subject)

all_accuracies = zeros(38, 8); % An array to store accuracy for all subjects (38 subjects, 8 laps)

for subj = 1:38 % Loop though each subject 
    sheetname = sheets{subj}; % Access the current sheet 
    data = readtable(filename, 'Sheet', sheetname); % Read the data from the sheet
    
    lap_data = data{:, 1}; % The first column (Column A in the file) contains lap numbers (1 to 8)
    answer_data = data{:, 15}; % The 15th column (Column O in the file) contains the answer data (1 = correct, 0 = incorrect)
    
    subject_accuracies = zeros(1, 8); % An array to store accuracy for each lap (just for one subject)
    
    for lap = 1:8 % Loop though each lap (1 to 8)
        lap_indices = lap_data == lap; % Get the indices where the lap number matches the current lap
        lap_answers = answer_data(lap_indices); % Get the answers corresponding to the current lap
        
        correct_answers = sum(lap_answers == 1); % Count the number of correct answers (where answer = 1)
        total_trials = 4; % There are 4 trials per lap
        
        accuracy = (correct_answers / total_trials) * 100; % Calculate the accuracy as a percentage
        subject_accuracies(lap) = accuracy; % Store the accuracy for the current lap
    end
    
    all_accuracies(subj, :) = subject_accuracies; % Store the accuracies for this subject
end

% Convert the accuracies for all subjects into a table with variable names for each lap
anova_data = array2table(all_accuracies, 'VariableNames', ...
    {'Lap1', 'Lap2', 'Lap3', 'Lap4', 'Lap5', 'Lap6', 'Lap7', 'Lap8'});

% Define the design for repeated measures with lap numbers as the factor
WithinDesign = table((1:8)', 'VariableNames', {'Lap'});

% Fit a repeated measures model using the accuracies across laps
rm_model = fitrm(anova_data, 'Lap1-Lap8 ~ 1');

% Perform repeated measures ANOVA and display the results
ranova_result = ranova(rm_model);
disp(ranova_result);

% Calculate the mean accuracy and standard error of the mean (SEM) for each lap
mean_accuracy = mean(all_accuracies);
sem_accuracy = std(all_accuracies) / sqrt(38);

% Plot the mean accuracy across laps with error bars
figure;
errorbar(1:8, mean_accuracy, sem_accuracy, '-o', 'LineWidth', 2);
xlabel('Lap Number');
ylabel('Mean Accuracy (%)');
title('Mean Accuracy Across Laps');
xticks(1:8);
ylim([0 100]);
grid on;

% Display the mean accuracy for each lap in the command window
disp('Mean Accuracy for Each Lap:');
disp(mean_accuracy);