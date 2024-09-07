filename = 'event_table_MR.xlsx'; % Name of the file
sheets = sheetnames(filename); % Get the names of all the sheets (one for each subject)

all_rt = zeros(38, 8); % An array to store reaction times for all subjects (38 subjects, 8 laps)

for subj = 1:38 % Loop through all 38 subjects
    sheetname = sheets{subj}; % Access the current sheet
    data = readtable(filename, 'Sheet', sheetname); % Read the data from the sheet
    
    lap_data = data{:, 1}; The first column (Column A) contains the lap numbers (1 to 8)
    rt_data = data{:, 18}; % The 18th column (Column R) contains the reaction time (RT) data
    
    subject_rt = zeros(1, 8); % An array to store the mean RT for each lap (for one subject)
    
    for lap = 1:8 % Loop through each lap (1 to 8)
        lap_indices = lap_data == lap; % Get the indices where the lap number matches the current lap
        lap_rts = rt_data(lap_indices); % Get the RTs corresponding to the current lap
        
        mean_rt = mean(lap_rts); % Calculate the mean RT for the current lap
        subject_rt(lap) = mean_rt; % Store the mean RT for the current lap
    end
    
    all_rt(subj, :) = subject_rt; % Store the RTs for this subject in the all_rt array
end

% Convert the RTs for all subjects into a table with variable names for each lap
anova_data = array2table(all_rt, 'VariableNames', ...
    {'Lap1', 'Lap2', 'Lap3', 'Lap4', 'Lap5', 'Lap6', 'Lap7', 'Lap8'});

% Define the design for repeated measures with lap numbers as the factor
WithinDesign = table((1:8)', 'VariableNames', {'Lap'});

% Fit a repeated measures model using the RTs across laps
rm_model = fitrm(anova_data, 'Lap1-Lap8 ~ 1');

% Perform repeated measures ANOVA and display the results
ranova_result = ranova(rm_model);
disp(ranova_result);

% Calculate the mean reaction time and standard error of the mean (SEM) for each lap
mean_rt = mean(all_rt);
sem_rt = std(all_rt) / sqrt(38);

% Plot the mean reaction time across laps with error bars
figure;
errorbar(1:8, mean_rt, sem_rt, '-o', 'LineWidth', 2);
xlabel('Lap Number');
ylabel('Mean Reaction Time (sec)');
title('Mean Reaction Time Across Laps');
xticks(1:8);
grid on;

% Display the mean reaction time for each lap in the command window
disp('Mean Reaction Time for Each Lap:');
disp(mean_rt);
