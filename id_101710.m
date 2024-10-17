% Import raw data file and check the variable names
raw_data = readtable('id_101710_unreal.xlsx');
raw_data.Properties.VariableNames
cleaned_data = table();

% Exclude unnecessary variables
excluded_events = {'time'};
filtered_data = raw_data(~ismember(raw_data.Var1, excluded_events), :);

% Lap 0-9
lap_column = [repmat(0, 15, 1); 
              repmat(1, 4, 1);   
              repmat(2, 4, 1);   
              repmat(3, 4, 1);    
              repmat(4, 4, 1); 
              repmat(5, 4, 1);   
              repmat(6, 4, 1);  
              repmat(7, 4, 1);   
              repmat(8, 4, 1);   
              repmat(9, 15, 1)]; 

% Add the column to a new table
new_table = table(lap_column, 'VariableNames', {'Lap'});

% ObjOn
ObjOn = NaN(height(new_table), 1); % new column with NaN values for now

ocp_on_idx = find(strcmp(raw_data.Var1, 'ODT_Start')); % Indices where 'OCP_on' appears in the first column of raw_data
preobjon_idx = find(strcmp(raw_data.Var1, 'PreObjOn'));
raw_data.Var1 = strrep(raw_data.Var1, 'Obj7_On', 'ObjOn');
raw_data.Var1 = strrep(raw_data.Var1, 'Obj4_On', 'ObjOn');
raw_data.Var1 = strrep(raw_data.Var1, 'Obj5_On', 'ObjOn');
raw_data.Var1 = strrep(raw_data.Var1, 'Obj6_On', 'ObjOn');
raw_data.Var1 = strrep(raw_data.Var1, 'Obj8_On', 'ObjOn');
objon_idx = find(strcmp(raw_data.Var1, 'ObjOn'));

ObjOn(1:15) = str2double(raw_data.Var2(preobjon_idx(1:15)));  % First 15 rows for Lap 0
for i = 1:8
    ObjOn(15 + (i-1)*4 + 1 : 15 + i*4) = str2double(raw_data.Var2(objon_idx((i-1)*4 + 1 : i*4)));
end
ObjOn(end-14:end) = str2double(raw_data.Var2(preobjon_idx(end-14:end)));  % Last 15 rows for Lap 9

new_table.ObjOn = ObjOn;

% NavStart
NavStart = NaN(height(new_table), 1); 

for i = 1:height(new_table)
    current_lap = new_table.Lap(i); % current lap number for the current row
    
    if current_lap == 0 || current_lap == 9
        NavStart(i) = ObjOn(i); % For Lap 0 and Lap 9, NavStart is the same as ObjOn
    else
        NavStart(i) = ObjOn(i) - 4; % For Lap 1 to 8, NavStart is ObjOn - 4 sec
    end
end

new_table.NavStart = NavStart;

% Trial
Trial = NaN(height(new_table), 1); 
Trial(new_table.Lap == 0) = -1:-1:-15; % For Lap 0, assign values from -1 to -15
Trial(new_table.Lap >= 1 & new_table.Lap <= 8) = 1:32; % For Laps 1 to 8, assign values from 1 to 32
Trial(new_table.Lap == 9) = -16:-1:-30;% For Lap 9, assign values from -16 to -30
new_table.Trial = Trial;

% Lap_Trial
Lap_Trial = strings(height(new_table), 1);  % empty strings
lap1_8_idx = find(new_table.Lap >= 1 & new_table.Lap <= 8); % Indices for rows where Lap is between 1 and 8
Lap_Trial(lap1_8_idx) = repmat(string([1, 2, 3, 4]), 1, length(lap1_8_idx) / 4)'; % For Laps 1 to 8, repeat the sequence [1, 2, 3, 4] for every 4 trials
new_table.Lap_Trial = Lap_Trial; 

% Obj_ID in ODT
Obj_ID = NaN(height(new_table), 1);  
ocp_on_idx = find(strcmp(raw_data.Var1, 'ODT_Start'));
preobjon_idx_0 = find(strcmp(raw_data.Var1(ocp_on_idx(1):end), 'PreObjOn')) + ocp_on_idx(1) - 1; % PreObjOn indices after the first OCP_on for Lap 0
Obj_ID(1:15) = raw_data.Var4(preobjon_idx_0(1:15));  % Assign Obj_ID values for Lap 0 using the first 15 rows of PreObjOn from raw_data
preobjon_idx_9 = find(strcmp(raw_data.Var1(ocp_on_idx(2):end), 'PreObjOn')) + ocp_on_idx(2) - 1; % PreObjOn indices after the second OCP_on for Lap 9
Obj_ID(end-14:end) = raw_data.Var4(preobjon_idx_9(1:15));  % Record values for Lap 9
new_table.Obj_ID = Obj_ID;

%Obj_ID in Lap 1-8
Obj_ID = new_table.Obj_ID;  % Use existing Obj_ID column
type_rows = strcmp(raw_data.Var3, 'Type');
five_digit_numbers = raw_data.Var4(type_rows); % Extract the five-digit numbers from the fourth column where 'Type' is present
lap1_8_idx = find(new_table.Lap >= 1 & new_table.Lap <= 8);  % Find the indices in new_table where Lap is between 1 and 8

for i = 1:length(lap1_8_idx)
    five_digit_number = num2str(five_digit_numbers(i));  % Convert the five-digit number to a string to extract the last digit
    if length(five_digit_number) == 5
        Obj_ID(lap1_8_idx(i)) = str2double(five_digit_number(end));  % Assign the last digit to Obj_ID
    end
end

new_table.Obj_ID = Obj_ID;

% ChoiceOn
choiceon_rows = strcmp(raw_data.Var1, 'Choice_On'); % Find rows in raw_data where the first column is 'ChoiceOn'
ChoiceOn = raw_data.Var2(choiceon_rows); % Extract the times (from the second column) for the 'ChoiceOn' events
new_table.ChoiceOn = NaN(height(new_table), 1); % Assign the extracted 'ChoiceOn' times to rows 16 to 47 in new_table (which corresponds to Lap 1 to 8)
new_table.ChoiceOn(16:47) = str2double(ChoiceOn);

% Separating 4 digits into columns
Context_Num = NaN(height(new_table), 1); 
Direction = NaN(height(new_table), 1);    
Location = NaN(height(new_table), 1);     
Association = NaN(height(new_table), 1);  

type_rows = strcmp(raw_data.Var3, 'Type'); % Find rows in raw data where the third column contains 'Type'

five_digit_numbers = raw_data.Var4(type_rows); % Extract the five-digit numbers from the fourth column for the filtered rows

lap1_8_idx = find(new_table.Lap >= 1 & new_table.Lap <= 8);  % Find rows for Lap 1 to 8
for i = 1:length(lap1_8_idx)
    % Get the corresponding Obj_ID
    current_Obj_ID = Obj_ID(lap1_8_idx(i));
    
    if current_Obj_ID ~= 12  % If Obj_ID is not 12, process the five-digit number
        five_digit_number = num2str(five_digit_numbers(i));  % Convert to string to extract digits
        if length(five_digit_number) == 5
            % Assign the first 4 digits to the respective columns
            Context_Num(lap1_8_idx(i)) = str2double(five_digit_number(1));  
            Direction(lap1_8_idx(i)) = str2double(five_digit_number(2));    
            Location(lap1_8_idx(i)) = str2double(five_digit_number(3));     
            Association(lap1_8_idx(i)) = str2double(five_digit_number(4));  
        end
    end
end

new_table.Context_Num = Context_Num;
new_table.Direction = Direction;
new_table.Location = Location;
new_table.Association = Association;

% Correct_Num
Correct_Num = NaN(height(new_table), 1);
decision_rows = strcmp(raw_data.Var1, 'Decision');
decision_values = raw_data.Var2(decision_rows);
lap1_8_idx = find(new_table.Lap >= 1 & new_table.Lap <= 8); 
Correct_Num(lap1_8_idx) = str2double(decision_values(1:length(lap1_8_idx))); 
new_table.Correct_Num = Correct_Num;

% ObjOff
ObjOff = NaN(height(new_table), 1); 
ocp_on_idx = find(strcmp(raw_data.Var1, 'ODT_Start'));
preobjoff_idx_0 = find(strcmp(raw_data.Var1(ocp_on_idx(1):end), 'PreObjOff')) + ocp_on_idx(1) - 1;
ObjOff(1:15) = str2double(raw_data.Var2(preobjoff_idx_0(1:15)));  % 문자열을 숫자로 변환
preobjoff_idx_9 = find(strcmp(raw_data.Var1(ocp_on_idx(2):end), 'PreObjOff')) + ocp_on_idx(2) - 1;
ObjOff(end-14:end) = str2double(raw_data.Var2(preobjoff_idx_9(1:15)));
raw_data.Var1 = strrep(raw_data.Var1, 'Obj7_Off', 'ObjOff');
raw_data.Var1 = strrep(raw_data.Var1, 'Obj4_Off', 'ObjOff');
raw_data.Var1 = strrep(raw_data.Var1, 'Obj5_Off', 'ObjOff');
raw_data.Var1 = strrep(raw_data.Var1, 'Obj6_Off', 'ObjOff');
objoff_idx = find(strcmp(raw_data.Var1, 'ObjOff'));
lap1_8_idx = find(new_table.Lap >= 1 & new_table.Lap <= 8);  % Find rows for Lap 1 to 8
ObjOff(lap1_8_idx) = str2double(raw_data.Var2(objoff_idx(1:length(lap1_8_idx))));  % Record ObjOff values for Lap 1 to 8
new_table.ObjOff = ObjOff;

% RT
RT = NaN(height(new_table), 1);
duration_rows = strcmp(raw_data.Var3, 'Duration');
rt_values = raw_data.Var4(duration_rows);
lap1_8_idx = find(new_table.Lap >= 1 & new_table.Lap <= 8); 
RT(lap1_8_idx) = rt_values(1:length(lap1_8_idx));
new_table.RT = RT;

% NavEnd
NavEnd = NaN(height(new_table), 1);
lap_end_rows = strcmp(raw_data.Var1, 'Lap_End');
nav_end_values = raw_data.Var2(lap_end_rows);
lap_trial_4_idx = find(new_table.Lap_Trial == "4");
NavEnd(lap_trial_4_idx) = str2double(nav_end_values(1:length(lap_trial_4_idx)));
new_table.NavEnd = NavEnd;

% isTimeout
isTimeout = NaN(height(new_table), 1);

for i = 1:height(new_table)
    if ~isnan(new_table.RT(i))  % Only process non-NaN RT values
        if new_table.RT(i) > 1.49
            isTimeout(i) = 1;
        else
            isTimeout(i) = 0;
        end
    end
end

new_table.isTimeout = isTimeout;

% Correct_txt
Correct_txt = strings(height(new_table), 1);

for i = 1:height(new_table)
    if new_table.Correct_Num(i) == 2
        Correct_txt(i) = "TimeOut";
    elseif new_table.Correct_Num(i) == 1
        Correct_txt(i) = "Correct";
    elseif new_table.Correct_Num(i) == 0
        Correct_txt(i) = "Incorrect";
    else
        Correct_txt(i) = "";  % Leave blank if the value is NaN or unexpected
    end
end

new_table.Correct_txt = Correct_txt;

% Choice_txt - missing
Choice_txt = strings(height(new_table), 1);  

for i = 1:height(new_table)
    if new_table.Correct_Num(i) == 2
        Choice_txt(i) = "missing";
    else
        Choice_txt(i) = "";  % Leave blank for other values
    end
end


new_table.Choice_txt = Choice_txt;

% Choice_txt - A or B
Choice_txt = new_table.Choice_txt;

lap_start_idx = find(strcmp(raw_data.Var1, 'LapStart'), 1, 'first');
lap_end_idx = find(strcmp(raw_data.Var1, 'Lap_End'), 1, 'last');

choice_a_idx = find(strcmp(raw_data.Var1(lap_start_idx:lap_end_idx), 'Button_1')) + lap_start_idx - 1;
choice_b_idx = find(strcmp(raw_data.Var1(lap_start_idx:lap_end_idx), 'Button_2')) + lap_start_idx - 1;

choice_idx = sort([choice_a_idx; choice_b_idx]); % Combine ChoiceA and ChoiceB indices and sort them in ascending order

choice_counter = 1;
for i = 1:height(new_table)
    if new_table.Lap(i) >= 1 && new_table.Lap(i) <= 8  % Only for Lap 1 to 8
        if new_table.Correct_Num(i) ~= 2 && Choice_txt(i) == ""  % Skip 'missing' and already filled
            if choice_counter <= length(choice_idx)  % Ensure the counter doesn't exceed choice_idx length
                if strcmp(raw_data.Var1(choice_idx(choice_counter)), 'Button_1')
                    Choice_txt(i) = "A";
                elseif strcmp(raw_data.Var1(choice_idx(choice_counter)), 'Button_2')
                    Choice_txt(i) = "B";
                end
                choice_counter = choice_counter + 1;
            else
                break;  % Stop if there are no more choices left
            end
        end
    end
end

new_table.Choice_txt = Choice_txt;

% Choice_Num
Choice_Num = NaN(height(new_table), 1);

for i = 1:height(new_table)
    if new_table.Choice_txt(i) == "B"
        Choice_Num(i) = 2;
    elseif new_table.Choice_txt(i) == "A"
        Choice_Num(i) = 1;
    elseif new_table.Choice_txt(i) == "missing"
        Choice_Num(i) = NaN;  % Leave as NaN for missing
    end
end

new_table.Choice_Num = Choice_Num;

% ISI_On, ISI_Off에 대한 두 개의 새로운 컬럼을 생성
ISI_On = NaN(height(new_table), 1);  % Create ISI_On column filled with NaN
ISI_Off = NaN(height(new_table), 1);  % Create ISI_Off column filled with NaN

% raw_data에서 ISI_On과 ISI_Off 행을 각각 찾음
isi_on_rows = strcmp(raw_data.Var1, 'ISI_On');
isi_off_rows = strcmp(raw_data.Var1, 'ISI_Off');

% 해당하는 시간을 추출
isi_on_values = raw_data.Var2(isi_on_rows);
isi_off_values = raw_data.Var2(isi_off_rows);

% Lap 1부터 8까지의 인덱스를 찾음
lap1_8_idx = find(new_table.Lap >= 1 & new_table.Lap <= 8);

% ISI_On과 ISI_Off 값을 각각 Lap 1부터 8까지 할당
ISI_On(lap1_8_idx) = str2double(isi_on_values(1:length(lap1_8_idx)));  % Assign ISI_On values
ISI_Off(lap1_8_idx) = str2double(isi_off_values(1:length(lap1_8_idx)));  % Assign ISI_Off values

% 새로운 컬럼을 new_table에 추가
new_table.ISI_On = ISI_On;
new_table.ISI_Off = ISI_Off;


% Association in ODT
for i = 1:height(new_table)
    if (new_table.Lap(i) == 0 || new_table.Lap(i) == 9)  % Only process Lap 0 and Lap 9
        if new_table.Obj_ID(i) ~= 12  % If Obj_ID is not 12
            new_table.Association(i) = 1;  % Set Association to 1
        else
            new_table.Association(i) = NaN;  % Leave blank for Obj_ID == 12
        end
    end
end

% Context_Num in ODT
for i = 1:height(new_table)
    if (new_table.Lap(i) == 0 || new_table.Lap(i) == 9)  % Only process Lap 0 and Lap 9
        if new_table.Obj_ID(i) ~= 12  % If Obj_ID is not 12
            % Find corresponding Context_Num from Lap 1 to 8 where Association == 1
            corresponding_row = find(new_table.Lap >= 1 & new_table.Lap <= 8 & ...
                                     new_table.Obj_ID == new_table.Obj_ID(i) & ...
                                     new_table.Association == 1, 1, 'first');
            if ~isempty(corresponding_row)
                new_table.Context_Num(i) = new_table.Context_Num(corresponding_row);  % Copy Context_Num
            end
        else
            new_table.Context_Num(i) = NaN;  % Leave blank for Obj_ID == 12
        end
    end
end

% Context_txt
Context_txt = strings(height(new_table), 1);

for i = 1:height(new_table)
    if new_table.Context_Num(i) == 1
        Context_txt(i) = "F";
    elseif new_table.Context_Num(i) == 2
        Context_txt(i) = "C";
    else
        Context_txt(i) = "";  % Leave blank for other values
    end
end

new_table.Context_txt = Context_txt;

% RT in ODT!!!
RT = new_table.RT;

% Find indices for OCP_on and OCP_off in raw data
ocp_on_idx = find(strcmp(raw_data.Var1, 'ODT_Start'));
ocp_off_idx = find(strcmp(raw_data.Var1, 'ODT_End'));

% Process Lap 0 (first OCP_on to OCP_off) for Obj_ID == 12
start_idx_0 = ocp_on_idx(1);
end_idx_0 = ocp_off_idx(1);

% Process Lap 9 (second OCP_on to OCP_off) for Obj_ID == 12
start_idx_9 = ocp_on_idx(2);
end_idx_9 = ocp_off_idx(2);

% Find Button1 events between the first OCP_on and OCP_off for Lap 0
button_a_idx_0 = find(strcmp(raw_data.Var1(start_idx_0:end_idx_0), 'Button_1')) + start_idx_0 - 1;

% Find Button1 events between the second OCP_on and OCP_off for Lap 9
button_a_idx_9 = find(strcmp(raw_data.Var1(start_idx_9:end_idx_9), 'Button_1')) + start_idx_9 - 1;

% Filter the rows in new_table where Lap == 0 or Lap == 9 and Obj_ID == 12
filtered_rows = find((new_table.Lap == 0 | new_table.Lap == 9) & new_table.Obj_ID == 12);

% There should be 6 rows in total (3 for Lap 0 and 3 for Lap 9)
if length(filtered_rows) ~= 6
    error('There should be exactly 6 rows for Lap 0 and Lap 9 with Obj_ID == 12.');
end

% Assign RT values for Lap 0 (Obj_ID == 12)
for i = 1:length(button_a_idx_0)
    button_a_time = str2double(raw_data.Var2{button_a_idx_0(i)});  % Convert ButtonA time to number
    
    % Convert ObjOn value to number if it's a cell
    if iscell(new_table.ObjOn(filtered_rows(i)))
        new_table.ObjOn{filtered_rows(i)} = str2double(new_table.ObjOn{filtered_rows(i)});
    end
    
    % Assign RT for the corresponding Lap 0 row in new_table
    new_table.RT(filtered_rows(i)) = button_a_time - new_table.ObjOn(filtered_rows(i));
end

% Assign RT values for Lap 9 (Obj_ID == 12)
for i = 1:length(button_a_idx_9)
    button_a_time = str2double(raw_data.Var2{button_a_idx_9(i)});  % Convert ButtonA time to number
    
    % Convert ObjOn value to number if it's a cell
    if iscell(new_table.ObjOn(filtered_rows(3 + i)))
        new_table.ObjOn{filtered_rows(3 + i)} = str2double(new_table.ObjOn{filtered_rows(3 + i)});
    end
    
    % Assign RT for the corresponding Lap 9 row in new_table
    new_table.RT(filtered_rows(3 + i)) = button_a_time - new_table.ObjOn(filtered_rows(3 + i));
end


% Reorder the columns of new_table
new_table = new_table(:, {'Lap', 'NavStart', 'Trial', 'Lap_Trial', 'Context_txt', 'Context_Num', 'Direction', 'Location', 'Association', 'Obj_ID', 'ObjOn', 'ChoiceOn', 'Choice_Num', 'Choice_txt', 'Correct_Num', 'Correct_txt', 'isTimeout', 'RT', 'ObjOff', 'ISI_On','ISI_Off', 'NavEnd'});
new_table

% Specify the filename for the new Excel file
filename = 'id101710_output.xlsx';

% Write the new_table to the Excel file
writetable(new_table, filename);

% Confirmation message
disp(['new_table has been successfully written to ', filename]);