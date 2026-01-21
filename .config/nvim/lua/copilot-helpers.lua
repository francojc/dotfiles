---| Copilot Helper Functions ------------------------------------------------
-- Helper functions for managing CopilotChat model presets and configurations

-- Model preset definitions
local model_presets = {
  academic = {
    model = "claude-sonnet-4.5",
    temperature = 0.4,
    description = "Academic Writing (Claude 4.5, temp 0.4)"
  },
  creative = {
    model = "claude-sonnet-4.5",
    temperature = 0.7,
    description = "Creative/Brainstorming (Claude 4.5, temp 0.7)"
  },
  precise = {
    model = "gpt-5.2",
    temperature = 0.2,
    description = "Editing/Proofreading (GPT-5.2, temp 0.2)"
  },
  research = {
    model = "gemini-2.5-pro",
    temperature = 0.5,
    description = "Research Synthesis (Gemini 2.5 Pro, temp 0.5)"
  },
  code = {
    model = "claude-sonnet-4.5",
    temperature = 0.1,
    description = "Code Development (Claude 4.5, temp 0.1)"
  },
}

-- Track current preset (default to academic)
_G.Copilot_current_preset = "academic"

-- Set a specific model preset
_G.Copilot_set_model_preset = function(preset_name)
  local preset = model_presets[preset_name]
  if not preset then
    vim.notify("Unknown preset: " .. preset_name, vim.log.levels.ERROR)
    return
  end

  local CopilotChat = require("CopilotChat")
  CopilotChat.setup({
    model = preset.model,
    temperature = preset.temperature,
  })

  _G.Copilot_current_preset = preset_name
  vim.notify(
    string.format("Model preset: %s (model: %s, temp: %.1f)", 
      preset_name, 
      preset.model, 
      preset.temperature
    ),
    vim.log.levels.INFO
  )
end

-- Interactive model preset picker
_G.Copilot_toggle_model_preset = function()
  local preset_names = { "academic", "creative", "precise", "research", "code" }
  
  vim.ui.select(preset_names, {
    prompt = "Select AI model preset:",
    format_item = function(item)
      local icon = item == _G.Copilot_current_preset and "● " or "○ "
      return icon .. model_presets[item].description
    end,
  }, function(choice)
    if choice then
      _G.Copilot_set_model_preset(choice)
    end
  end)
end

return {
  presets = model_presets,
  set_preset = _G.Copilot_set_model_preset,
  toggle_preset = _G.Copilot_toggle_model_preset,
}
