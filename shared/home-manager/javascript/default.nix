# This module configures development tools for JavaScript/TypeScript.
{pkgs, ...}: {
  home.packages = with pkgs; [
    unstable.deno
    nodejs_latest
    yarn

    # Needed for react-native development
    cocoapods
  ];

  programs.neovim.extraLuaConfig = ''
    local util = require("lspconfig.util")
    require("lspconfig")["denols"].setup({
      init_options = {
        enable = true,
        unstable = true,
        lint = true,
        nodeModulesDir = true,
      },
      cmd = { "${pkgs.unstable.deno}/bin/deno", "lsp" },
      root_dir = function(startpath)
        if util.find_package_json_ancestor(startpath) then
          -- This is a Node project; let ts_ls handle this one.
          -- This exactly mirrors how typescript-langauge-server yields to this server for Deno projects.
          return nil
        else
          -- Otherwise, we try to find the root or
          -- default to the current directory.
          return util.root_pattern("deno.json", "deno.jsonc", ".git")(startpath)
              or util.path.dirname(startpath)
        end
      end,
    });

    require("lspconfig")["ts_ls"].setup({
      cmd = { "${pkgs.nodePackages_latest.typescript-language-server}/bin/typescript-language-server", "--stdio" },
      root_dir = function(startpath)
        local find_deno_root_dir = util.root_pattern("deno.json", "deno.jsonc")
        if find_deno_root_dir(startpath) then
          -- This is a Deno project; let deno-lsp handle this one.
          -- This exactly mirrors how deno-lsp yields to this server for Node projects.
          return nil
        else
          -- Otherwise fall back to the usual resolution method.
          -- See: https://github.com/neovim/nvim-lspconfig/blob/056f569f71e4b726323b799b9cfacc53653bceb3/lua/lspconfig/server_configurations/ts_ls.lua#L15
          return util.root_pattern("tsconfig.json", "jsconfig.json", "package.json", ".git")(startpath)
        end
      end,
      -- We also have to disallow starting in without a root directory, as otherwise returning
      -- nil from find_root will just cause the LSP to be spawned in single file mode instead of yielding to deno-lsp.
      --
      -- This has the side effect that Deno LSP will be preferred in a single file context which is what we want!
      --
      -- See: https://github.com/neovim/nvim-lspconfig/blob/056f569f71e4b726323b799b9cfacc53653bceb3/lua/lspconfig/manager.lua#L281-L286
      single_file_support = false,
    })
  '';
}
