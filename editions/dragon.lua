--[[ Dragon - supports Lua, C/C++, Python, and Zig (via ZLS) ]]

-- `enabled_languages`      - the languages that are supported by the edition
-- `extra_extensions`       - the extensions that are installed with the edition
-- `enabled_theme`          - leave this NIL if you initialise the extensions/themes with .hooks()
-- `hooks`                  - all hooks that are meant to be run (primarily after setups)
--
return {
  enabled_languages = { "clangd", "jedi_language_server", "zls" },
  extra_extensions  = { "navarasu/onedark.nvim" },
  enabled_theme     = nil,
  hooks = function()
    require("onedark").load();
  end
}
