return {
    'rose-pine/neovim',
    name = 'rose-pine',
    priority = 1000, -- high priority
    init = function() 
        vim.cmd.colorscheme 'rose-pine'
    end,
}
