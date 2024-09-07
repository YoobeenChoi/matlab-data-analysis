filename = 'event_table_MR.xlsx'; % Specify the name of the file
sheets = sheetnames(filename); % Get the names of all the sheets (one for each subject)

% Arrays to store object IDs and accuracies across all subjects
obj_ids = [];
accuracies = [];

for subj = 1:38 % Loop through all 38 subjects
    sheetname = sheets{subj}; % Access the current sheet (subject data)
    data = readtable(filename, 'Sheet', sheetname); % Read the data from the sheet
    
    obj_data = data{:, 10};  % Object ID data (column J)
    accuracy_data = data{:, 15};  % Accuracy data (column O)
    
    for lap = 1:8 % Loop through each lap (1 to 8)
        lap_indices = data{:, 1} == lap; % Get the indices where the lap number matches the current lap
        lap_obj_ids = obj_data(lap_indices);  % Get object IDs for current lap
        lap_accuracy = accuracy_data(lap_indices);  % Get accuracies for current lap
        
        % Filter out only objects with ID 4, 5, 6, and 7
        valid_indices = ismember(lap_obj_ids, [4, 5, 6, 7]); % Find valid object IDs
        valid_obj_ids = lap_obj_ids(valid_indices); % Extract valid object IDs
        valid_accuracies = lap_accuracy(valid_indices); % Extract corresponding accuracy values
        
        % Append the valid object IDs and their corresponding accuracies to the arrays
        obj_ids = [obj_ids; valid_obj_ids];
        accuracies = [accuracies; valid_accuracies];
    end
end

% Convert accuracies to percentage of correctness (1 = correct, 0 = incorrect)
accuracies = (accuracies == 1) * 100;

% Arrays to store the mean and SEM (Standard Error of the Mean) for each object
mean_accuracies = [];
sem_accuracies = [];

% Calculate the mean accuracy and SEM for each object (IDs 4, 5, 6, and 7)
for obj = [4, 5, 6, 7] % Loop through each object ID
    mean_acc = mean(accuracies(obj_ids == obj)); % Calculate the mean accuracy for the current object
    sem_acc = std(accuracies(obj_ids == obj)) / sqrt(sum(obj_ids == obj));  % Calculate SEM for the current object
    mean_accuracies = [mean_accuracies; mean_acc]; % Store the mean accuracy
    sem_accuracies = [sem_accuracies; sem_acc]; % Store the SEM
end

% Bar graph with error bars
figure;
bar(1:4, mean_accuracies, 'FaceColor', [0.4, 0.6, 0.8]);
hold on;
errorbar(1:4, mean_accuracies, sem_accuracies, 'k', 'LineStyle', 'none', 'LineWidth', 2);

% Plot Customization
set(gca, 'XTickLabel', {'Object 4', 'Object 5', 'Object 6', 'Object 7'});
xlabel('Object ID');
ylabel('Mean Accuracy (%)');
title('Mean Accuracy for Different Objects');
ylim([0 100]);
grid on;
