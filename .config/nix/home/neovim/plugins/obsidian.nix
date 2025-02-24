{
  programs.nixvim = {
    plugins.obsidian = {
      enable = true;
      settings = {
        ui.enable = false;
        completion = {
          min_chars = 2;
          nvim_cmp = false; # Use nvim-cmp
        };
        picker.name = "fzf-lua";
        # 'Mobile Documents/iCloud~md~obsidian/Documents/Notes'
        attachments = {
          img_folder = "~/Library/Mobile Documents/iCloud~md~obsidian/Documents/Notes/Assets/Attachments/";
        };
        follow_url_func.__raw = ''
          function(url)
          -- Open the URL in the default browser
             vim.fn.jobstart({"open", url})
          end
        '';
        notes_subdir = "Inbox";
        new_notes_location = "notes_subdir";
        workspaces = [
          {
            name = "Notes";
            path = "~/Library/Mobile Documents/iCloud~md~obsidian/Documents/Notes/";
          }
        ];
        daily_notes = {
          template = "~/Library/Mobile Documents/iCloud~md~obsidian/Documents/Notes/Assets/Templates/Daily.md";
          folder = "Daily";
        };
        mappings = {
          "gf" = {
            action = "require('obsidian').util.gf_passthrough";
            opts = {
              noremap = false;
              expr = true;
              buffer = true;
            };
          };
          "<leader>oc" = {
            action = "require('obsidian').util.toggle_checkbox";
            opts.buffer = true;
            opts.desc = "Toggle checkbox";
          };
        };
        templates = {
          subdir = "~/Library/Mobile Documents/iCloud~md~obsidian/Documents/Notes/Assets/Templates/";
          substitutions = {
            monday.__raw = ''
              function()
                  -- Get the current date
                  local currentDate = os.date("*t")

                  -- Calculate the difference in days to the first day of the week (Monday)
                  local diff = (currentDate.wday + 5) % 7

                  -- Subtract the difference to get the date of the first day of the week
                  currentDate.day = currentDate.day - diff

                  -- Return the date of the first day of the week
                  return os.date("%Y-%m-%d", os.time(currentDate))
              end
            '';
            tuesday.__raw = ''
              function()
                  -- Get the current date
                  local currentDate = os.date("*t")

                  -- Calculate the difference in days to the first day of the week (Monday)
                  local diff = (currentDate.wday + 4) % 7

                  -- Subtract the difference to get the date of the first day of the week
                  currentDate.day = currentDate.day - diff

                  -- Return the date of the first day of the week
                  return os.date("%Y-%m-%d", os.time(currentDate))
              end
            '';
            wednesday.__raw = ''
              function()
                  -- Get the current date
                  local currentDate = os.date("*t")

                  -- Calculate the difference in days to the first day of the week (Monday)
                  local diff = (currentDate.wday + 3) % 7

                  -- Subtract the difference to get the date of the first day of the week
                  currentDate.day = currentDate.day - diff

                  -- Return the date of the first day of the week
                  return os.date("%Y-%m-%d", os.time(currentDate))
              end
            '';
            thursday.__raw = ''
              function()
                  -- Get the current date
                  local currentDate = os.date("*t")

                  -- Calculate the difference in days to the first day of the week (Monday)
                  local diff = (currentDate.wday + 2) % 7

                  -- Subtract the difference to get the date of the first day of the week
                  currentDate.day = currentDate.day - diff

                  -- Return the date of the first day of the week
                  return os.date("%Y-%m-%d", os.time(currentDate))
              end
            '';
            friday.__raw = ''
              function()
                  -- Get the current date
                  local currentDate = os.date("*t")

                  -- Calculate the difference in days to the first day of the week (Monday)
                  local diff = (currentDate.wday + 1) % 7

                  -- Subtract the difference to get the date of the first day of the week
                  currentDate.day = currentDate.day - diff

                  -- Return the date of the first day of the week
                  return os.date("%Y-%m-%d", os.time(currentDate))
              end
            '';
          };
        };
      };
    };
  };
}
