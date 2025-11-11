classdef testExtractChatPrompts < matlab.unittest.TestCase
    % Unit tests for extract_chat_prompts

    properties (Constant)
        RepoRoot = fileparts(fileparts(mfilename('fullpath')));
    end

    methods (TestClassSetup)
        function addRepoPaths(testCase)
            addpath(fullfile(testCase.RepoRoot, 'vscode'));
        end
    end

    methods (Test)
        function testExtractsFromMessageText(testCase)
            data.requests = struct('message', struct('text', 'hello world', 'parts', []));
            fp = writeJSON(testCase, data);
            prompts = extract_chat_prompts(fp);
            testCase.verifyEqual(prompts, {'hello world'});
        end

        function testExtractsFromPartsText(testCase)
            msg.text = '';
            msg.parts = struct('text', {'first', 'second'});
            data.requests = struct('message', msg);
            fp = writeJSON(testCase, data);
            prompts = extract_chat_prompts(fp);
            testCase.verifyEqual(prompts, {'first','second'});
        end

        function testDedupAndTrim(testCase)
            msg1.text = '  same  ';
            msg1.parts = struct('text', {'same','different'});
            msg2.text = 'same';
            msg2.parts = struct('text', {'different','more'});
            data.requests = [struct('message', msg1), struct('message', msg2)];
            fp = writeJSON(testCase, data);
            prompts = extract_chat_prompts(fp);
            % Expected order: 'same' (from trimmed text), 'different', 'more'
            testCase.verifyEqual(prompts, {'same','different','more'});
        end

        function testSkipsEmpty(testCase)
            msg.text = '   ';
            msg.parts = struct('text', {'', '   ', 'ok'});
            data.requests = struct('message', msg);
            fp = writeJSON(testCase, data);
            prompts = extract_chat_prompts(fp);
            testCase.verifyEqual(prompts, {'ok'});
        end

        function testWarnsNoRequestsAndEmpty(testCase)
            data = struct('foo', 123);
            fp = writeJSON(testCase, data);
            testCase.verifyWarning(@() extract_chat_prompts(fp), 'extract_chat_prompts:NoRequests');
            prompts = extract_chat_prompts(fp); %#ok<NASGU>
        end

        function testFileNotFound(testCase)
            testCase.verifyError(@() extract_chat_prompts('Z:\does\not\exist.json'), 'extract_chat_prompts:FileNotFound');
        end
    end
end

function fp = writeJSON(testCase, data)
% Helper to write JSON to a temporary file and return its path
import matlab.unittest.fixtures.TemporaryFolderFixture
fix = testCase.applyFixture(TemporaryFolderFixture);
dirPath = fix.Folder;
fp = fullfile(dirPath, 'sample.json');
fid = fopen(fp,'w');
cleaner = onCleanup(@() fclose(fid)); %#ok<NASGU>
str = jsonencode(data);
fprintf(fid, '%s', str);
end
