function T = fetch_bitcoin_data(source, varargin)
%FETCH_BITCOIN_DATA Load or fetch Bitcoin daily prices.
%   T = FETCH_BITCOIN_DATA('sample') loads the included sample CSV.
%   T = FETCH_BITCOIN_DATA('file', filePath) loads a CSV with Date, Close.
%   T = FETCH_BITCOIN_DATA('table', tbl) validates an input table/timetable.
%
%   Returns a timetable T with variables:
%     - Close: double, daily close price
%   and RowTimes as datetime dates (daily).
%
%   Note: Web/API fetching is intentionally omitted for offline robustness.

    arguments
        source (1,1) string {mustBeMember(source, ["sample","file","table"])}
    end
    arguments (Repeating)
        varargin
    end

    switch source
        case "sample"
            % bundled sample CSV
            thisFile = mfilename("fullpath");
            root = fileparts(fileparts(thisFile)); % up from vscode/
            csvPath = fullfile(root, "data", "bitcoin_sample_prices.csv");
            if ~isfile(csvPath)
                error("Sample CSV not found at %s", csvPath);
            end
            T = readCsvToTimetable(csvPath);

        case "file"
            if numel(varargin) < 1
                error("Provide a CSV file path: fetch_bitcoin_data('file', filePath)");
            end
            filePath = string(varargin{1});
            if ~isfile(filePath)
                error("File not found: %s", filePath);
            end
            T = readCsvToTimetable(filePath);

        case "table"
            if numel(varargin) < 1
                error("Provide a table/timetable: fetch_bitcoin_data('table', tbl)");
            end
            tbl = varargin{1};
            if istimetable(tbl)
                T = tbl;
            elseif istable(tbl)
                % Expect columns Date and Close
                req = ["Date","Close"];
                if ~all(ismember(req, string(tbl.Properties.VariableNames)))
                    error("Table must contain variables: Date, Close");
                end
                dates = tbl.Date;
                if ~isdatetime(dates)
                    dates = datetime(dates, 'InputFormat','yyyy-MM-dd');
                end
                T = timetable(dates, double(tbl.Close), 'VariableNames', {'Close'});
            else
                error("Unsupported input type. Provide table or timetable.");
            end
    end

    % Sort and de-duplicate
    T = sortrows(T);
    [~, ia] = unique(T.Properties.RowTimes);
    T = T(ia, :);

    % Ensure daily regularity if possible (fill missing days via forward fill)
    try
        TT = retime(T, 'daily', 'previous');
        % Remove leading NaNs if any
        firstValid = find(~isnan(TT.Close), 1, 'first');
        if ~isempty(firstValid) && firstValid > 1
            TT = TT(firstValid:end, :);
        end
        T = TT;
    catch
        % If retime fails (irregular), continue as-is
    end
end

function T = readCsvToTimetable(csvPath)
    opts = detectImportOptions(csvPath);
    % Try common column names
    dateCols = intersect({"Date","date","DATE"}, string(opts.VariableNames));
    closeCols = intersect({"Close","close","Adj Close","AdjClose"}, string(opts.VariableNames));
    if isempty(dateCols) || isempty(closeCols)
        % Fall back to first two columns
        if numel(opts.VariableNames) >= 2
            dateCols = string(opts.VariableNames(1));
            closeCols = string(opts.VariableNames(2));
        else
            error("CSV must have at least two columns: Date and Close");
        end
    end
    opts.SelectedVariableNames = [dateCols(1), closeCols(1)];
    tbl = readtable(csvPath, opts);
    dt = tbl.(dateCols(1));
    if ~isdatetime(dt)
        % Try multiple common formats
        try
            dt = datetime(string(dt), 'InputFormat','yyyy-MM-dd');
        catch
            try
                dt = datetime(string(dt));
            catch
                error('Unable to parse dates from the CSV file.');
            end
        end
    end
    closeVals = double(tbl.(closeCols(1)));
    T = timetable(dt, closeVals, 'VariableNames', {'Close'});
end
