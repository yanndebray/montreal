function prompts = extract_chat_prompts(jsonPath)
%EXTRACT_CHAT_PROMPTS Parse a Copilot/agent chat JSON and return prompt texts.
%   PROMPTS = EXTRACT_CHAT_PROMPTS(JSONPATH) reads the JSON file produced
%   by an AI agent session (e.g. GitHub Copilot chat export) and extracts
%   all user request message texts. It falls back to collecting any 'text'
%   fields inside message.parts if message.text is absent.
%
%   The JSON is expected to have a top-level struct with a field 'requests'
%   which is an array of structs each containing a 'message'.
%
%   Returns a cell array of unique, non-empty prompt strings preserving
%   original order of first appearance.
%
%   Robustness: Large JSON files are read fully; if jsondecode fails due
%   to size, an informative error is thrown. Non‑standard structures are
%   skipped gracefully.
%
%   Example:
%       prompts = extract_chat_prompts('chats/chat_weather_app.json');
%       disp(prompts(1:5));
%
%   See also: jsondecode, fileread

arguments
    jsonPath (1,:) char
end

if ~isfile(jsonPath)
    error('extract_chat_prompts:FileNotFound','File not found: %s', jsonPath);
end
raw = fileread(jsonPath);
try
    data = jsondecode(raw);
catch decodeErr
    error('extract_chat_prompts:DecodeFailed', ...
        'Failed to decode JSON: %s\nOriginal message: %s', jsonPath, decodeErr.message);
end

prompts = {};
seen = containers.Map('KeyType','char','ValueType','logical');

if isstruct(data) && isfield(data,'requests')
    reqs = data.requests;

    % Unified iteration over requests whether struct array or cell array
    if isstruct(reqs)
        getReq = @(i) reqs(i);
        nReq = numel(reqs);
    elseif iscell(reqs)
        getReq = @(i) reqs{i};
        nReq = numel(reqs);
    else
        nReq = 0;
    end

    for i = 1:nReq
        req = getReq(i);
        txts = {};

        if isstruct(req) && isfield(req,'message')
            msg = req.message;
            % Handle message possibly as struct or cell
            if iscell(msg) && ~isempty(msg)
                msg = msg{1};
            end
            if isstruct(msg)
                if isfield(msg,'text') && (ischar(msg.text) || (isstring(msg.text) && isscalar(msg.text)))
                    txts{end+1} = char(msg.text); %#ok<AGROW>
                end
                if isfield(msg,'parts')
                    parts = msg.parts;
                    if isstruct(parts)
                        partsIter = arrayfun(@(k) parts(k), 1:numel(parts), 'UniformOutput', false);
                    elseif iscell(parts)
                        partsIter = parts;
                    else
                        partsIter = {};
                    end
                    for p = 1:numel(partsIter)
                        part = partsIter{p};
                        if isstruct(part) && isfield(part,'text') && (ischar(part.text) || (isstring(part.text) && isscalar(part.text)))
                            txts{end+1} = char(part.text); %#ok<AGROW>
                        end
                    end
                end
            end
        end

        for t = 1:numel(txts)
            candidate = strtrim(txts{t});
            if ~isempty(candidate) && ~isKey(seen,candidate)
                seen(candidate) = true;
                prompts{end+1} = candidate; %#ok<AGROW>
            end
        end
    end
else
    warning('extract_chat_prompts:NoRequests','JSON does not have expected struct or cell array field ''requests''.');
end

if isempty(prompts)
    warning('extract_chat_prompts:Empty','No prompts discovered in %s.', jsonPath);
end
end