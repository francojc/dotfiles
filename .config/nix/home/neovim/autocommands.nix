{
  programs.nixvim = {
    autoGroups = {
      "personal" = {clear = true;};
    };
    autoCmd = [

      # Highlight yanked text
      {
        event = "TextYankPost";
        desc = "Highlight yanked text";
        group = "personal";
        callback.__raw = ''
          function()
            vim.highlight.on_yank()
          end
          '';
      }

      # Nvim .11 completions
      {
        event = "LspAttach";
        desc = "Nvim default LSP completion";
        callback.__raw = ''
              function(ev)
                local client = vim.lsp.get_client_by_id(ev.data.client_id)
                if client.supports_method("textDocument/completion") then
                  vim.lsp.completion.enable(true, client.id, ev.buf, { autotrigger = true })
                end
              end
              '';
      }

      # Remove trailing whitespace
      {
        event = "BufWritePre";
        desc = "Remove trailing whitespace on save";
        group = "personal";
        callback.__raw = ''
          function()
            vim.cmd('%s/\\s\\+$//e')
          end
          '';
      }
    ];
  };
}
