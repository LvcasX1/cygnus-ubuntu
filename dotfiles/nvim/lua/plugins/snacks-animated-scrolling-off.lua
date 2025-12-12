return {
	"folke/snacks.nvim",
	opts = {
		scroll = {
			enabled = false, -- Disable scrolling animations
		},
		picker = {
			enabled = false, -- Use Telescope instead
		},
	},
	keys = {
		{ "<leader>ff", false }, -- Disable snacks file finder, use Telescope
	},
}
