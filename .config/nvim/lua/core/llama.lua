---| Llama.vim Configuration -----------------------------
-- AI-powered code completion
-- using local llama.cpp server

---| pass-backed Llama API key -------------------------------------
-- Source the FIM api key from the `pass` store at API/LLAMA_API_KEY instead
-- of relying on $LLAMA_API_KEY. gpg-agent caches the key, so the common case
-- is a silent, no-prompt decrypt. On a cold cache we force loopback pinentry
-- and prompt with Neovim's own inputsecret() (uses the Neovim TUI, so it does
-- not fight pinentry-tty for the terminal). Set vim.g.llama_skip_pass = true
-- to fall back to $LLAMA_API_KEY only.
local function pass_secret(name)
	if vim.g.llama_skip_pass then return nil end

	-- fast path: pass + warm gpg-agent cache -> instant, no prompt
	local ok, fetched = pcall(function()
		local res = vim.system({ "pass", "show", name }, { text = true }):wait(10000)
		if res and res.code == 0 then
			local secret = vim.split(res.stdout, "\n")[1] or ""
			if secret ~= "" then
				vim.env.LLAMA_API_KEY = secret
				return true
			end
		end
		return false
	end)
	if ok and fetched then return vim.env.LLAMA_API_KEY end

	-- cold cache: loopback decrypt, passphrase fed to gpg via stdin
	-- (--passphrase-fd 0) so it never lands on the command line
	local store = vim.fn.expand("$HOME") .. "/.password-store/" .. name .. ".gpg"
	local cmd = {
		"gpg", "--batch", "--quiet", "--no-tty",
		"--pinentry-mode", "loopback", "--passphrase-fd", "0",
		"--decrypt", store,
	}
	for attempt = 1, 3 do
		local pp = vim.fn.inputsecret(
			"GPG passphrase for " .. name .. " (" .. attempt .. "/3): ")
		if pp == "" then
			vim.cmd("redraw")
			break
		end
		local res = vim.system(cmd, { stdin = pp .. "\n", text = true }):wait(60000)
		vim.cmd("redraw")
		if res.code == 0 then
			vim.env.LLAMA_API_KEY = vim.split(res.stdout, "\n")[1]
			return vim.env.LLAMA_API_KEY
		end
		if res.stderr:lower():find("bad passphrase") then
			vim.notify("llama.vim: wrong GPG passphrase", vim.log.levels.WARN)
		else
			vim.notify("llama.vim: " .. vim.trim(res.stderr), vim.log.levels.ERROR)
			break
		end
	end
	return nil
end

local llama_api_key = pass_secret("API/LLAMA_API_KEY") or vim.env.LLAMA_API_KEY
if not llama_api_key or llama_api_key == "" then
	vim.notify("llama.vim: LLAMA_API_KEY unavailable from pass/$env; FIM requests will be rejected", vim.log.levels.WARN)
	llama_api_key = ""
end

-- FIM configuration:
-- model_fim must equal the llama-server --alias (see ~/.llama.cpp/scripts/start-llama-fim.sh).
-- Alternative ggml names (Qwen2.5-Coder-7B/3B-Q8_0-GGUF) apply only if you run
-- the built-in --fim-qwen-* preset instead of a custom --alias.
vim.g.llama_config = {
	-- Behavior
	enable_at_startup = true,
	auto_fim = true,
	max_line_suffix = 8,
	-- Server connection
	endpoint_fim = "http://100.101.38.4:8080/infill",
	api_key = llama_api_key,
	model_fim = "qwen2.5-coder-fim-7b-spec",
	-- Disable llama.vim instruction-editing mappings (FIM-only settings)
	keymap_inst_trigger = "",
	keymap_inst_rerun = "",
	keymap_inst_continue = "",
	keymap_inst_accept = "",
	keymap_inst_cancel = "",
	-- Context settings
	n_prefix = 384,
	n_suffix = 192,
	n_predict = 128,
	stop_strings_fim = {},
	-- Timeout settings
	t_max_prompt_ms = 1000,
	t_max_predict_ms = 1000,
	-- Cache settings
	max_cache_keys = 250,
	-- Ring buffer
	ring_n_chunks = 4,
	ring_chunk_size = 32,
	ring_scope = 512,
	ring_update_ms = 1000,
	-- Keymaps
	keymap_fim_trigger = "<M-l>", -- Trigger FIM
	keymap_fim_accept_full = "<Tab>", -- Accept full
	keymap_fim_accept_line = "<C-F>", -- Accept line
	keymap_fim_accept_word = "<C-D>", -- Accept word
	keymap_fim_next = "<C-l>", -- Next FIM suggestion
	keymap_fim_prev = "<C-h>", -- Previous FIM suggestion
	-- Info
	show_info = 2, -- 0=off, 1=statusline, 2=inline
}

-- llama.vim's built-in :LlamaStatus always checks both FIM and instruction
-- endpoints. Replace with a custom command that only checks FIM.
-- Matching mirrors upstream get_model_status: accept id, aliases, or tags; if
-- exactly one model is served, treat it as ready (the --alias differs from
-- model_fim, so an exact-equality-only check false-warns). A 401/unauthorized
-- is reported as a key problem, not "model not loaded".
-- vim.schedule: llama.vim's setup() re-registers :LlamaStatus; defer ours so it
-- wins the override race.
vim.schedule(function()
	vim.api.nvim_create_user_command("LlamaStatus", function()
		local config = vim.g.llama_config
		local base = config.endpoint_fim:gsub("/infill$", "")
		local models_url = base .. "/v1/models"
		local result = vim.system({
			"curl",
			"--silent",
			"--show-error",
			"--max-time",
			"3",
			"--write-out",
			"\n%{http_code}",
			"--header",
			"Authorization: Bearer " .. config.api_key,
			"--url",
			models_url,
		}, { text = true }):wait()

		if result.code ~= 0 then
			vim.notify("FIM: unreachable (" .. vim.trim(result.stderr) .. ")", vim.log.levels.ERROR)
			return
		end

		-- split body from trailing http code line
		local out = result.stdout or ""
		local nl = out:find("\n[^\n]*$")
		local body, status = out, ""
		if nl then
			body = out:sub(1, nl - 1)
			status = vim.trim(out:sub(nl))
		end

		if status == "401" or status == "403" then
			vim.notify(
				"FIM: unauthorized (HTTP " .. status
				.. "). API key rejected by server — check pass API/LLAMA_API_KEY vs the server --api-key-file. Run :LlamaPassReload",
				vim.log.levels.ERROR)
			return
		elseif status ~= "200" then
			vim.notify("FIM: server returned HTTP " .. (status ~= "" and status or result.code), vim.log.levels.ERROR)
			return
		end

		local ok, response = pcall(vim.json.decode, body)
		local models = ok and response.data or nil
		if type(models) ~= "table" then
			vim.notify("FIM: invalid /v1/models response", vim.log.levels.ERROR)
			return
		end
		if #models == 0 then
			vim.notify("FIM: no models loaded on server", vim.log.levels.WARN)
			return
		end

		-- explicit match against the configured name
		local function matches(m)
			if m.id == config.model_fim then return true end
			for _, key in ipairs({ "aliases", "tags", "filenames" }) do
				local list = m[key]
				if type(list) == "table" then
					for _, v in ipairs(list) do
						if v == config.model_fim then return true end
					end
				end
			end
			return false
		end

		for _, m in ipairs(models) do
			if matches(m) then
				vim.notify("FIM: ✅ Ready (" .. m.id .. ")")
				return
			end
		end

		-- upstream fallback: a single served model is assumed to be the FIM model
		if #models == 1 then
			vim.notify("FIM: ✅ Ready (" .. models[1].id .. "; served id differs from model_fim '" .. config.model_fim .. "')")
			return
		end

		local ids = {}
		for _, m in ipairs(models) do ids[#ids + 1] = m.id end
		vim.notify("FIM: model not loaded (" .. config.model_fim .. "); server offers: " .. table.concat(ids, ", "),
			vim.log.levels.WARN)
	end, { desc = "Check authenticated FIM endpoint" })

	-- Re-pull the API key from `pass` without restarting Neovim. Updates
	-- g:llama_config.api_key in place; llama.vim reads that field per request,
	-- so new completions use the fresh key immediately.
	vim.api.nvim_create_user_command("LlamaPassReload", function()
		local key = pass_secret("API/LLAMA_API_KEY")
		if key and key ~= "" then
			local cfg = vim.g.llama_config
			cfg.api_key = key
			vim.g.llama_config = cfg
			vim.notify("llama.vim: API key reloaded from pass (" .. #key .. " chars)", vim.log.levels.INFO)
		else
			vim.notify("llama.vim: could not reload key from pass", vim.log.levels.ERROR)
		end
	end, { desc = "Re-read the Llama API key from pass" })
end)
