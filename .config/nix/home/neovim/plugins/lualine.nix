{
  programs.nixvim = {
    plugins.lualine = {
      enable = true;
      settings = {
        options = {
          disabled_filetypes = {
            statusline = ["aerial" "alpha" "avante" "nvim-tree"];
            winbar = ["aerial" "alpha" "avante" "nvim-tree" "NvimTree"];
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
                    local mode_maps = {
                      n = "normal";
                      i = "insert";
                      c = "command";
                      V = "v-line";
                      [""] = "v-block";
                      v = "visual";
                      R = "replace";
                      s = "select";
                      S = "select";
                      [""] = "select";
                      t = "terminal";
                    }
                    local mode_name = mode_maps[mode]
                    return " " .. mode_name .. " "
                  end
                '';
              };
            }
          ];
          lualine_b = ["branch" "diff"];
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

          lualine_x = ["searchcount"];
          lualine_y = ["diagnostics"];
          lualine_z = [
            {
              __unkeyed-1 = "filetype";
              colored = false;
            }
            "progress"
          ];
        };
        tabline = {};
        winbar = {};
        inactive_winbar = {};
      };
    };
  };
}
