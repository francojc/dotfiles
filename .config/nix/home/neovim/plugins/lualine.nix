{
  programs.nixvim = {
    plugins.lualine = {
      enable = true;
      settings = {
        options = {
          disabled_filetypes = {
            statusline = [ "aerial" "alpha" ];
            winbar = [ "aerial" ];
          };

          globalstatus = true;
          theme = "auto";
          section_separators = {
            left = "";
            right = "";
          };
          component_separators = {
            left = "";
            right = "";
          };
        };

        sections = {
          lualine_a = [
            {
              __unkeyed-1 = {
                __raw = ''
                  function()
                    local mode = vim.api.nvim_get_mode().mode
                    return " " .. string.lower(mode) .. " "
                  end
                '';
              };
            }

          ];
          lualine_b = [ "branch" "diff" ];
          lualine_c = [
            {
              __unkeyed-1 = {
                __raw = ''
                  function()
                    local reg = vim.fn.reg_recording()
                    if reg == "" then
                      return ""
                    else
                      return " " .. reg .. ""
                    end
                  end
                '';
              };
            }
          ];

          lualine_x = [ "searchcount" ];
          lualine_y = [
            "diagnostics"
          ];
          lualine_z = [ "progress" ];
        };
        winbar = { };
        inactive_winbar = { };
      };
    };
  };
}
