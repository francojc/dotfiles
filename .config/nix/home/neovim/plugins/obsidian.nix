{
 programs.nixvim = {
    plugins.obsidian = {
      enable = true;
      settings = {
        ui.enable = false;
        completion = {
          min_chars = 2;
          nvim_cmp = true;
        };
        attachments = {
          img_folder = "Assets/Attachments";
        };
        notes_subdir = "Inbox";
        new_notes_location = "notes_subdir";
        workspaces = [
          {
            name = "Notes";
            path = "~/Google Drive/My Drive/Notes/";
          }
        ];
        daily_notes = {
          template = "~/Google Drive/My Drive/Notes/Assets/Templates/Daily.md";
          folder = "Daily";
        };
        mappings = {
          gf = {
            action = "require('obsidian').util.gf_passthrough";
            opts = {
              noremap = false;
              expr = true;
              buffer = true;
            };
          };
          "<leader>ch" = {
            action = "require('obsidian').util.toggle_checkbox";
            opts.buffer = true;
          };
        };
        templates = {
          subdir = "~/Google Drive/My Drive/Notes/Assets/Templates/";
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
