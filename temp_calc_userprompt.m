% Prompt the user to select an input file.
[filename, filepath] = uigetfile({'*.csv', '*.txt'}, 'Select input file');

% Check if the user cancelled the dialog.
if isequal(filename, 0) || isequal(filepath, 0)
    fprintf("No file selected. Exiting.\n");
    return;
end

% Read the data from the file.
try
    data = readtable(fullfile(filepath, filename));
catch ME
    fprintf("Error reading file: %s\n", ME.message);
    return;
end

% Convert the date/time string to a datetime object.
datetime_data = datetime(data{:, 1}, 'InputFormat', 'MM/dd/yyyy hh:mm:ss a');

% Extract the month and day from the datetime object.
month = month(datetime_data);
day = day(datetime_data);

% Compute the average temperature for each month.
unique_months = unique(month);
average_monthly_temperature = splitapply(@mean, data{:, 2}, month);

% Display the average monthly temperatures.
fprintf("Average monthly temperatures:\n");
for i = 1:length(unique_months)
    fprintf("Month %d: %.1f degrees Celsius\n", unique_months(i), average_monthly_temperature(i));
end

% Prompt the user to select a month and days.
selected_month = input("Enter a month (1-12): ");
selected_days = input("Enter one or more days (e.g., 3, 5-7): ");

% Validate the user input.
if selected_month < 1 || selected_month > 12
    fprintf("Error: Invalid month selected.\n");
    return;
end

if any(selected_days < 1 | selected_days > 31)
    fprintf("Error: Invalid days selected.\n");
    return;
end

if ~ismember(selected_month, unique_months)
    fprintf("Error: Selected month has no data.\n");
    return;
end

% Filter the data by the selected month and days.
selected_data = data(month == selected_month & ismember(day, selected_days), :);

% Compute the average temperature for the selected days.
average_selected_temperature = mean(selected_data{:, 2});

% Display the average temperature for the selected days.
fprintf("Average temperature for selected days: %.1f degrees Celsius\n", average_selected_temperature);

% Plot the temperature data.
figure;
plot(datetime_data, data{:, 2});
title("Temperature over time");
xlabel("Date/time");
ylabel("Temperature (degrees Celsius)");

% Save the plot to a file.
saveas(gcf, "temperature_plot.png");

fprintf("Program finished.\n");
