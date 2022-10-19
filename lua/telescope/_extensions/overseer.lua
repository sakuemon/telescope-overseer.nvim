local has_telescope, telescope = pcall(require, 'telescope')
if not has_telescope then
	error('This plugins requires nvim-telescope')
end


local pickers = require('telescope.pickers')
local finders = require('telescope.finders')
local action_state = require('telescope.actions.state')
local entry_display = require('telescope.pickers.entry_display')
local conf = require('telescope.config').values

local ovs = require('overseer')


local function prepare_task_list()
	local tasks = require('overseer').list_tasks()
	local items = {}
	for key, task in ipairs(tasks) do
		table.insert(items, task)
	end
	return items
end

local displayer = entry_display.create({
	separator = '|',
	items = {
		{ width = 20 },
		{ width = 20 },
		{ remaining = true },
	},
})

local function overseer(opts)
	opts = opts or {}
	pickers.new(opts, {
		prompt_title = 'Tasks',
		finder = finders.new_table({
			results = prepare_task_list(),
			entry_maker = function(entry)
				local function make_displey()
					return displayer({
						entry.name,
						entry.status,
					})
				end

				local entry_str = string.format("%s %s(%d)", entry.name, entry.status, entry.exit_code)
				return {
					value = entry,
					display = entry_str,
					ordinal = entry.name,
				}
			end,
		}),
		sorter = conf.generic_sorter(opts),
		attach_mappings = function(prompt_bufnr, map)
			local action = function()
				local task = action_state.get_selected_entry().value
				ovs.run_action(task)
			end
			map('i', '<CR>', action)
			return true
		end,
	}):find()
end

return require('telescope').register_extension({
	exports = {
		overseer = overseer,
	},
})
