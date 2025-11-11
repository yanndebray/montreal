function chat_prompts_app(jsonPath)
%CHAT_PROMPTS_APP Small MATLAB UI to display prompts from a chat JSON.
%   CHAT_PROMPTS_APP(JSONPATH) opens a simple app showing all extracted
%   prompts from the given chat JSON file in a list. Selecting a prompt
%   displays the full text on the right and copies it to clipboard on
%   double-click for convenience.
%
%   If JSONPATH is omitted, defaults to the project's chat export at
%   'chats/chat_weather_app.json' relative to the current folder.
%
%   Example:
%       chat_prompts_app('chats/chat_weather_app.json');
%
%   See also: extract_chat_prompts

if nargin < 1 || isempty(jsonPath)
    defaultPath = fullfile(pwd,'chats','chat_weather_app.json');
    if isfile(defaultPath)
        jsonPath = defaultPath;
    else
        [f,p] = uigetfile('*.json','Select chat JSON');
        if isequal(f,0)
            return;
        end
        jsonPath = fullfile(p,f);
    end
end

prompts = extract_chat_prompts(jsonPath);

% UI Figure
fig = uifigure('Name','Chat Prompts','Position',[100 100 1000 600]);

% Layout: 1x2 grid
mainGrid = uigridlayout(fig,[1 2]);
mainGrid.ColumnWidth = {320,'1x'};
mainGrid.RowHeight = {'1x'};
mainGrid.Padding = [10 10 10 10];
mainGrid.ColumnSpacing = 10;
mainGrid.RowSpacing = 10;

% Left panel: search + list
leftGrid = uigridlayout(mainGrid,[3 1]);
leftGrid.RowHeight = {22,22,'1x'};
leftGrid.ColumnWidth = {'1x'};

lbl = uilabel(leftGrid,'Text','Prompts','FontWeight','bold'); %#ok<NASGU>

searchField = uieditfield(leftGrid,'text','Placeholder','Filter (substring)...');

list = uilistbox(leftGrid, ...
    'Items',prompts, ...
    'Multiselect','off');

% Right panel: title + text area
rightGrid = uigridlayout(mainGrid,[2 1]);
rightGrid.RowHeight = {22,'1x'};
rightGrid.ColumnWidth = {'1x'};

selLabel = uilabel(rightGrid,'Text','Selected prompt','FontWeight','bold'); %#ok<NASGU>

textArea = uitextarea(rightGrid, ...
    'Value','', ...
    'Editable','off', ...
    'FontName','Consolas');

% Toolbar: open file, copy, refresh
tb = uitoolbar(fig); %#ok<NASGU>
openIcon = uipushtool(tb, 'Tooltip','Open JSON...', 'ClickedCallback', @(~,~)openJson()); %#ok<NASGU>
copyIcon = uipushtool(tb, 'Tooltip','Copy selected', 'ClickedCallback', @(~,~)copySelected()); %#ok<NASGU>
refreshIcon = uipushtool(tb, 'Tooltip','Reload', 'ClickedCallback', @(~,~)reload()); %#ok<NASGU>

% State
filtered = prompts;

% Callbacks
searchField.ValueChangedFcn = @(src,~)applyFilter(src.Value);
list.ValueChangedFcn = @(src,~)showSelection(src.Value);
list.DoubleClickedFcn = @(src,~)copySelected();

if ~isempty(prompts)
    list.Value = prompts{1};
    showSelection(list.Value);
end

% Nested helpers
    function applyFilter(q)
        if strlength(strtrim(q)) == 0
            filtered = prompts;
        else
            mask = false(size(prompts));
            ql = lower(q);
            for i = 1:numel(prompts)
                mask(i) = contains(lower(prompts{i}), ql);
            end
            filtered = prompts(mask);
        end
        list.Items = filtered;
        if ~isempty(filtered)
            list.Value = filtered{1};
            showSelection(list.Value);
        else
            textArea.Value = "";
        end
    end

    function showSelection(val)
        if isempty(val)
            textArea.Value = "";
            return
        end
        textArea.Value = string(val);
    end

    function copySelected()
        val = list.Value;
        if isempty(val), return; end
        try
            clipboard('copy', val);
            uialert(fig,'Copied to clipboard.','Copied','Icon','success','CloseFcn',@(varargin)[]);
        catch
            % ignore clipboard issues
        end
    end

    function reload()
        try
            newPrompts = extract_chat_prompts(jsonPath);
            prompts = newPrompts; %#ok<NASGU>
            applyFilter(searchField.Value);
        catch err
            uialert(fig,err.message,'Reload failed','Icon','error');
        end
    end

    function openJson()
        [f,p] = uigetfile('*.json','Open chat JSON', jsonPath);
        if isequal(f,0)
            return;
        end
        jsonPath = fullfile(p,f); %#ok<NASGU>
        reload();
    end
end