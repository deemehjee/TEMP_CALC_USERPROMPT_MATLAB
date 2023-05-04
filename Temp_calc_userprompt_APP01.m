classdef Temp_calc_userprompt_APP01 < matlab.apps.AppBase

    % Properties that correspond to app components
    properties (Access = public)
        UIFigure                      matlab.ui.Figure
        ENDButton                     matlab.ui.control.Button
        TEMP_VALUEEditField           matlab.ui.control.EditField
        TEMP_VALUEEditFieldLabel      matlab.ui.control.Label
        RESULTEditField               matlab.ui.control.EditField
        RESULTEditFieldLabel          matlab.ui.control.Label
        AvgTempButton                 matlab.ui.control.Button
        AvgMonthTempButton            matlab.ui.control.Button
        SelectMonthanddaysDatePicker  matlab.ui.control.DatePicker
        SelectMonthanddaysDatePickerLabel  matlab.ui.control.Label
        CancelButton                  matlab.ui.control.Button
        input_temp_fileButton         matlab.ui.control.Button
        Temp_fileEditField            matlab.ui.control.EditField
        Temp_fileEditFieldLabel       matlab.ui.control.Label
        OKButton                      matlab.ui.control.Button
        UIAxes                        matlab.ui.control.UIAxes
    end

    % Callbacks that handle component events
    methods (Access = private)

        % Button pushed function: input_temp_fileButton
        function input_temp_fileButtonPushed(app, event)
            [~, ~] = uigetfile({'*.csv', '*.txt'}, 'Select input file');
        end

        % Button pushed function: CancelButton
        function CancelButtonPushed(app, event)
            if isequal(filename, 0) || isequal(filepath, 0)
                fprintf("No file selected. Exiting.\n");
                return;
            end
        end

        % Button pushed function: OKButton
        function OKButtonPushed(app, event)
            try
                data = readtable(fullfile(filepath, filename));
            catch ME
                fprintf("Error reading file: %s\n", ME.message);
                return;
            end
        end

        % Button pushed function: AvgMonthTempButton
        function AvgMonthTempButtonPushed(app, event)
            % Convert the date/time string to a datetime object.
            datetime_data = datetime(data{:, 1}, 'InputFormat', 'MM/dd/yyyy hh:mm:ss a');

            % Extract the month and day from the datetime object.
            month = month(datetime_data);
            day = day(datetime_data);

            % Compute the average temperature for each month.
            unique_months = unique(month);
            average_monthly_temperature = splitapply(@mean, data{:, 2}, month);
        end

        % Value changed function: TEMP_VALUEEditField
        function TEMP_VALUEEditFieldValueChanged(app, event)
            value = app.TEMP_VALUEEditField.Value;
            fprintf("Average monthly temperatures:\n");
            for i = 1:length(unique_months)
                  fprintf("Month %d: %.1f degrees Celsius\n", unique_months(i), average_monthly_temperature(i));
            end
        end

        % Value changed function: SelectMonthanddaysDatePicker
        function SelectMonthanddaysDatePickerValueChanged(app, event)
            value = app.SelectMonthanddaysDatePicker.Value;
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
        end

        % Button pushed function: AvgTempButton
        function AvgTempButtonPushed(app, event)
            average_selected_temperature = mean(selected_data{:, 2});
        end

        % Value changed function: RESULTEditField
        function RESULTEditFieldValueChanged(app, event)
            value = app.RESULTEditField.Value;
            fprintf("Average temperature for selected days: %.1f degrees Celsius\n", average_selected_temperature);
        end

        % Button down function: UIAxes
        function UIAxesButtonDown(app, event)
            ax = app.UIAxes;
            plot(ax, datetime_data, data{:, 2});
            title(ax, "Temperature over time");
            xlabel(ax, "Date/time");
            ylabel(ax, "Temperature (degrees Celsius)");
        end

        % Button pushed function: ENDButton
        function ENDButtonPushed(app, event)
            fprintf("Program finished.\n");
        end
    end

    % Component initialization
    methods (Access = private)

        % Create UIFigure and components
        function createComponents(app)

            % Create UIFigure and hide until all components are created
            app.UIFigure = uifigure('Visible', 'off');
            app.UIFigure.Position = [100 100 640 480];
            app.UIFigure.Name = 'MATLAB App';

            % Create UIAxes
            app.UIAxes = uiaxes(app.UIFigure);
            title(app.UIAxes, 'Title')
            xlabel(app.UIAxes, 'X')
            ylabel(app.UIAxes, 'Y')
            zlabel(app.UIAxes, 'Z')
            app.UIAxes.ButtonDownFcn = createCallbackFcn(app, @UIAxesButtonDown, true);
            app.UIAxes.Position = [328 92 300 185];

            % Create OKButton
            app.OKButton = uibutton(app.UIFigure, 'push');
            app.OKButton.ButtonPushedFcn = createCallbackFcn(app, @OKButtonPushed, true);
            app.OKButton.Position = [271 370 100 23];
            app.OKButton.Text = 'OK';

            % Create Temp_fileEditFieldLabel
            app.Temp_fileEditFieldLabel = uilabel(app.UIFigure);
            app.Temp_fileEditFieldLabel.HorizontalAlignment = 'right';
            app.Temp_fileEditFieldLabel.Position = [199 402 56 22];
            app.Temp_fileEditFieldLabel.Text = 'Temp_file';

            % Create Temp_fileEditField
            app.Temp_fileEditField = uieditfield(app.UIFigure, 'text');
            app.Temp_fileEditField.Position = [270 402 200 22];

            % Create input_temp_fileButton
            app.input_temp_fileButton = uibutton(app.UIFigure, 'push');
            app.input_temp_fileButton.ButtonPushedFcn = createCallbackFcn(app, @input_temp_fileButtonPushed, true);
            app.input_temp_fileButton.Position = [168 445 100 23];
            app.input_temp_fileButton.Text = 'input_temp_file';

            % Create CancelButton
            app.CancelButton = uibutton(app.UIFigure, 'push');
            app.CancelButton.ButtonPushedFcn = createCallbackFcn(app, @CancelButtonPushed, true);
            app.CancelButton.Position = [370 370 100 23];
            app.CancelButton.Text = 'Cancel';

            % Create SelectMonthanddaysDatePickerLabel
            app.SelectMonthanddaysDatePickerLabel = uilabel(app.UIFigure);
            app.SelectMonthanddaysDatePickerLabel.HorizontalAlignment = 'right';
            app.SelectMonthanddaysDatePickerLabel.Position = [26 276 127 22];
            app.SelectMonthanddaysDatePickerLabel.Text = 'Select Month and days';

            % Create SelectMonthanddaysDatePicker
            app.SelectMonthanddaysDatePicker = uidatepicker(app.UIFigure);
            app.SelectMonthanddaysDatePicker.ValueChangedFcn = createCallbackFcn(app, @SelectMonthanddaysDatePickerValueChanged, true);
            app.SelectMonthanddaysDatePicker.Position = [168 276 150 22];

            % Create AvgMonthTempButton
            app.AvgMonthTempButton = uibutton(app.UIFigure, 'push');
            app.AvgMonthTempButton.ButtonPushedFcn = createCallbackFcn(app, @AvgMonthTempButtonPushed, true);
            app.AvgMonthTempButton.Position = [237 328 105 23];
            app.AvgMonthTempButton.Text = 'Avg Month Temp';

            % Create AvgTempButton
            app.AvgTempButton = uibutton(app.UIFigure, 'push');
            app.AvgTempButton.ButtonPushedFcn = createCallbackFcn(app, @AvgTempButtonPushed, true);
            app.AvgTempButton.Position = [10 196 100 23];
            app.AvgTempButton.Text = 'Avg Temp';

            % Create RESULTEditFieldLabel
            app.RESULTEditFieldLabel = uilabel(app.UIFigure);
            app.RESULTEditFieldLabel.HorizontalAlignment = 'right';
            app.RESULTEditFieldLabel.Position = [124 220 51 22];
            app.RESULTEditFieldLabel.Text = 'RESULT';

            % Create RESULTEditField
            app.RESULTEditField = uieditfield(app.UIFigure, 'text');
            app.RESULTEditField.ValueChangedFcn = createCallbackFcn(app, @RESULTEditFieldValueChanged, true);
            app.RESULTEditField.Position = [190 172 124 70];

            % Create TEMP_VALUEEditFieldLabel
            app.TEMP_VALUEEditFieldLabel = uilabel(app.UIFigure);
            app.TEMP_VALUEEditFieldLabel.HorizontalAlignment = 'right';
            app.TEMP_VALUEEditFieldLabel.Position = [386 328 83 22];
            app.TEMP_VALUEEditFieldLabel.Text = 'TEMP_VALUE';

            % Create TEMP_VALUEEditField
            app.TEMP_VALUEEditField = uieditfield(app.UIFigure, 'text');
            app.TEMP_VALUEEditField.ValueChangedFcn = createCallbackFcn(app, @TEMP_VALUEEditFieldValueChanged, true);
            app.TEMP_VALUEEditField.Position = [484 328 100 22];

            % Create ENDButton
            app.ENDButton = uibutton(app.UIFigure, 'push');
            app.ENDButton.ButtonPushedFcn = createCallbackFcn(app, @ENDButtonPushed, true);
            app.ENDButton.Position = [255 13 100 23];
            app.ENDButton.Text = 'END';

            % Show the figure after all components are created
            app.UIFigure.Visible = 'on';
        end
    end

    % App creation and deletion
    methods (Access = public)

        % Construct app
        function app = Temp_calc_userprompt_APP01

            % Create UIFigure and components
            createComponents(app)

            % Register the app with App Designer
            registerApp(app, app.UIFigure)

            if nargout == 0
                clear app
            end
        end

        % Code that executes before app deletion
        function delete(app)

            % Delete UIFigure when app is deleted
            delete(app.UIFigure)
        end
    end
end