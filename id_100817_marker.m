% Load the .vmrk file
vmrk_file = '100817.vmrk';  % Path to your .vmrk file
fid = fopen(vmrk_file);

markers = {};
tline = fgetl(fid);  % Read the first line

% Loop through the file and extract markers
while ischar(tline)
    % Look for lines that start with 'Mk'
    if startsWith(tline, 'Mk')
        % Split the line by commas
        splitLine = strsplit(tline, ',');
        % Extract the marker (e.g., 'M13' from 'Mk13, M13, timestamp...')
        markers{end+1} = splitLine{2};  % Marker is the second element
    end
    tline = fgetl(fid);  % Read the next line
end

% Close the file after reading
fclose(fid);

% Initialize arrays for row numbers, marker numbers, and event labels
row_numbers = [];  % Store only valid row numbers
marker_numbers = [];  % Placeholder for marker numbers
event_labels = {};  % Placeholder for event labels

% Extract marker numbers and assign event labels
for i = 1:length(markers)
    % Remove 'M' from marker and convert to number
    marker_num_str = markers{i}(2:end);  % Extract everything after 'M'
    
    % Attempt to convert to number, handle errors if conversion fails
    marker_num = str2double(marker_num_str);  
    
    % If the conversion fails (NaN), skip this marker
    if isnan(marker_num)
        continue;
    end

    % Exclude markers greater than 200
    if marker_num > 200
        continue;  % Skip markers like M202 or higher
    end
    
    % Add valid row number and marker number
    row_numbers(end+1) = i;
    marker_numbers(end+1) = marker_num;
    
    % Assign event labels based on the marker number
    switch marker_num
        case 2
            event_labels{end+1} = 'ODT_Start';
        case 3
            event_labels{end+1} = 'ODT_End';
        case 4
            event_labels{end+1} = 'OCAT_Start';
        case 5
            event_labels{end+1} = 'OCAT_End';
        case 7
            event_labels{end+1} = 'Lap_End';
        case 8
            event_labels{end+1} = 'Navi_Start';
        case 9
            event_labels{end+1} = 'Choice_On';
        case 10
            event_labels{end+1} = 'Answer_Reveal';
        case 11
            event_labels{end+1} = 'Turn_Start';
        case 12
            event_labels{end+1} = 'Turn_End';
        case 13
            event_labels{end+1} = 'Button_1';
        case 23
            event_labels{end+1} = 'Button_2';
        case 14
            event_labels{end+1} = 'Obj4_On';
        case 24
            event_labels{end+1} = 'Obj4_Off';
        case 15
            event_labels{end+1} = 'Obj5_On';
        case 25
            event_labels{end+1} = 'Obj5_Off';
        case 16
            event_labels{end+1} = 'Obj6_On';
        case 26
            event_labels{end+1} = 'Obj6_Off';
        case 17
            event_labels{end+1} = 'Obj7_On';
        case 27
            event_labels{end+1} = 'Obj7_Off';
        case 18
            event_labels{end+1} = 'Obj12_On';
        case 28
            event_labels{end+1} = 'Obj12_Off';
        case 19
            event_labels{end+1} = 'ISI_On';
        case 29 
            event_labels{end+1} = 'ISI_Off';
        otherwise
            event_labels{end+1} = 'Unknown';
    end
end

% Create a table with row numbers, marker numbers, and event labels
T = table(row_numbers', marker_numbers', event_labels', ...
    'VariableNames', {'Row_Number', 'Marker', 'Event_Label'});

% Write the table to an Excel file
output_filename = 'id_100817_markers_output.xlsx';
writetable(T, output_filename);

disp(['Data successfully written to ', output_filename]);
