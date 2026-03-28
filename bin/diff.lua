local filesystem = require("filesystem")
local shell = require("shell")

local function print_usage()
	print("Usage: diff file1 file2")
end

local function print_error(message)
	if io.stderr ~= nil and io.stderr.write ~= nil then
		io.stderr:write(message .. "\n")
	else
		print(message)
	end
end

local function split_lines(contents)
	local normalized = contents:gsub("\r\n", "\n"):gsub("\r", "\n")
	local lines = {}
	local start_index = 1

	while start_index <= #normalized do
		local newline_index = normalized:find("\n", start_index, true)
		if newline_index == nil then
			table.insert(lines, normalized:sub(start_index))
			break
		end

		table.insert(lines, normalized:sub(start_index, newline_index - 1))
		start_index = newline_index + 1
	end

	return lines
end

local function read_lines(path)
	if not filesystem.exists(path) then
		return nil, "diff: " .. path .. ": No such file or directory"
	end

	if filesystem.isDirectory(path) then
		return nil, "diff: " .. path .. ": Is a directory"
	end

	local handle, err = io.open(path, "r")
	if handle == nil then
		return nil, "diff: " .. path .. ": " .. tostring(err)
	end

	local contents = handle:read("*a") or ""
	handle:close()

	return split_lines(contents)
end

local function build_lcs_table(left_lines, right_lines)
	local line_count_left = #left_lines
	local line_count_right = #right_lines
	local lcs = {}

	for left_index = 0, line_count_left do
		lcs[left_index] = {[0] = 0}
	end

	for right_index = 0, line_count_right do
		lcs[0][right_index] = 0
	end

	for left_index = 1, line_count_left do
		for right_index = 1, line_count_right do
			if left_lines[left_index] == right_lines[right_index] then
				lcs[left_index][right_index] = lcs[left_index - 1][right_index - 1] + 1
			else
				local from_left = lcs[left_index - 1][right_index]
				local from_right = lcs[left_index][right_index - 1]
				if from_left >= from_right then
					lcs[left_index][right_index] = from_left
				else
					lcs[left_index][right_index] = from_right
				end
			end
		end
	end

	return lcs
end

local function backtrack_diff(left_lines, right_lines, lcs)
	local operations = {}
	local left_index = #left_lines
	local right_index = #right_lines

	while left_index > 0 or right_index > 0 do
		if left_index > 0 and right_index > 0 and left_lines[left_index] == right_lines[right_index] then
			table.insert(operations, 1, {type = "equal"})
			left_index = left_index - 1
			right_index = right_index - 1
		elseif right_index > 0 and (left_index == 0 or lcs[left_index][right_index - 1] >= lcs[left_index - 1][right_index]) then
			table.insert(operations, 1, {type = "insert", line = right_lines[right_index]})
			right_index = right_index - 1
		else
			table.insert(operations, 1, {type = "delete", line = left_lines[left_index]})
			left_index = left_index - 1
		end
	end

	return operations
end

local function collect_hunks(left_lines, right_lines)
	local lcs = build_lcs_table(left_lines, right_lines)
	local operations = backtrack_diff(left_lines, right_lines, lcs)
	local hunks = {}
	local current_hunk
	local left_position = 0
	local right_position = 0

	local function finish_hunk()
		if current_hunk == nil then
			return
		end

		current_hunk.left_end = left_position
		current_hunk.right_end = right_position
		table.insert(hunks, current_hunk)
		current_hunk = nil
	end

	for _, operation in ipairs(operations) do
		if operation.type == "equal" then
			finish_hunk()
			left_position = left_position + 1
			right_position = right_position + 1
		else
			if current_hunk == nil then
				current_hunk = {
					left_start = left_position + 1,
					right_start = right_position + 1,
					left_lines = {},
					right_lines = {},
				}
			end

			if operation.type == "delete" then
				left_position = left_position + 1
				table.insert(current_hunk.left_lines, operation.line)
			else
				right_position = right_position + 1
				table.insert(current_hunk.right_lines, operation.line)
			end
		end
	end

	finish_hunk()
	return hunks
end

local function format_range(first_line, last_line)
	if first_line == last_line then
		return tostring(first_line)
	end

	return tostring(first_line) .. "," .. tostring(last_line)
end

local function print_normal_diff(hunks)
	for _, hunk in ipairs(hunks) do
		if #hunk.left_lines > 0 and #hunk.right_lines > 0 then
			print(format_range(hunk.left_start, hunk.left_end) .. "c" .. format_range(hunk.right_start, hunk.right_end))
			for _, line in ipairs(hunk.left_lines) do
				print("< " .. line)
			end
			print("---")
			for _, line in ipairs(hunk.right_lines) do
				print("> " .. line)
			end
		elseif #hunk.left_lines > 0 then
			print(format_range(hunk.left_start, hunk.left_end) .. "d" .. tostring(hunk.right_end))
			for _, line in ipairs(hunk.left_lines) do
				print("< " .. line)
			end
		else
			print(tostring(hunk.left_end) .. "a" .. format_range(hunk.right_start, hunk.right_end))
			for _, line in ipairs(hunk.right_lines) do
				print("> " .. line)
			end
		end
	end
end

local args = select(1, shell.parse(...))

if #args ~= 2 then
	print_usage()
	os.exit(2)
end

local left_lines, left_error = read_lines(args[1])
if left_lines == nil then
	print_error(left_error)
	os.exit(2)
end

local right_lines, right_error = read_lines(args[2])
if right_lines == nil then
	print_error(right_error)
	os.exit(2)
end

local hunks = collect_hunks(left_lines, right_lines)

if #hunks == 0 then
	os.exit(0)
end

print_normal_diff(hunks)
os.exit(1)
