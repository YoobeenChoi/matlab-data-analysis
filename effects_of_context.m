filename = 'event_table_MR.xlsx';  % Specify the name of the file
sheets = sheetnames(filename);     % Get the names of all the sheets (one for each subject)

% Arrays to store accuracies for contexts across all subjects
forest_accuracies = [];
city_accuracies = [];

for subj = 1:38  % Loop through all 38 subjects
    sheetname = sheets{subj};  % Access the current sheet (subject data)
    data = readtable(filename, 'Sheet', sheetname);  % Read the data from the sheet
    
    context_data = data{:, 5};  % Column 5 contains context data (F = forest, C = city)
    accuracy_data = data{:, 15};  % Column 15 contains accuracy data (1 = correct, 0 = incorrect)
    
    for lap = 1:8  % Loop through each lap (1 to 8)
        lap_indices = data{:, 1} == lap;  % Get the indices where the lap number matches the current lap
        lap_contexts = context_data(lap_indices);  % Get the contexts for the current lap
        lap_accuracy = accuracy_data(lap_indices);  % Get the accuracy data for the current lap
        
        % Separate forest and city trials based on context
        forest_indices = strcmp(lap_contexts, 'F');  % Find indices where context is 'Forest'
        city_indices = strcmp(lap_contexts, 'C');    % Find indices where context is 'City'
        
        % Count correct answers for forest and city contexts
        forest_correct = sum(lap_accuracy(forest_indices) == 1);  % Number of correct answers in the forest context
        city_correct = sum(lap_accuracy(city_indices) == 1);  % Number of correct answers in the city context
        
        % Count total trials for forest and city contexts
        forest_trials = sum(forest_indices);  % Total number of forest trials
        city_trials = sum(city_indices);  % Total number of city trials
        
        % Calculate accuracy for forest trials and add to the array
        if forest_trials > 0
            forest_accuracies = [forest_accuracies; (forest_correct / forest_trials) * 100];
        end
        
        % Calculate accuracy for city trials and add to the array
        if city_trials > 0
            city_accuracies = [city_accuracies; (city_correct / city_trials) * 100];
        end
    end
end

% Calculate mean accuracy for forest and city contexts
mean_forest_accuracy = mean(forest_accuracies);
mean_city_accuracy = mean(city_accuracies);

% Perform a two-sample t-test between forest and city accuracies
[h, p] = ttest2(forest_accuracies, city_accuracies);

% Display the mean accuracy and p-value from the t-test
disp(['Mean Accuracy (Forest): ', num2str(mean_forest_accuracy), '%']);
disp(['Mean Accuracy (City): ', num2str(mean_city_accuracy), '%']);
disp(['p-value: ', num2str(p)]);

% Calculate standard error of the mean (SEM) for both contexts
sem_forest = std(forest_accuracies) / sqrt(length(forest_accuracies)); 
sem_city = std(city_accuracies) / sqrt(length(city_accuracies)); 

% Plot the mean accuracy for forest and city contexts with error bars
figure;
hold on;
bar(1, mean_forest_accuracy, 'FaceColor', [0.2, 0.6, 0.4]);  % Bar for forest accuracy
bar(2, mean_city_accuracy, 'FaceColor', [0.4, 0.6, 0.8]);  % Bar for city accuracy

% Error bars for both forest and city accuracies
errorbar(1, mean_forest_accuracy, sem_forest, 'k', 'LineWidth', 2);  
errorbar(2, mean_city_accuracy, sem_city, 'k', 'LineWidth', 2);  

% Plot Customization
set(gca, 'XTick', [1 2], 'XTickLabel', {'Forest', 'City'});  % Set x-axis labels for forest and city
ylabel('Accuracy (%)');  % Label for y-axis
title('Mean Accuracy for Forest and City Contexts');  % Title for the plot
ylim([0 100]);  % Set y-axis limit to 0-100%
grid on;  % Enable grid for better readability

% Add text labels above the bars showing the mean accuracy percentages
text(1, mean_forest_accuracy + 3, sprintf('%.2f%%', mean_forest_accuracy), 'HorizontalAlignment', 'center');
text(2, mean_city_accuracy + 3, sprintf('%.2f%%', mean_city_accuracy), 'HorizontalAlignment', 'center');

hold off;  % Release the hold on the figure