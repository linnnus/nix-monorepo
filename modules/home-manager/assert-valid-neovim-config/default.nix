# This HM module asserts the nvim configuration has valid syntax during
# building. This shortens the iteration cycle a bit when working on the Lua
# config as it means I don't have to launch `nvim` only to discover I missed a
# comma.
#
# This approach uses import-from-derivation which _does_ slow down evaluation.
#
# This approach should not affect the final closure size as there is no
# reference to `checkDerivation` in `build.toplevel`. It does however generate
# a bit of garbage in the Nix store every time the Neovim configuration
# changes.
{
  pkgs,
  config,
  ...
}: let
  checkDerivation =
    pkgs.runCommand "successful-syntax-check.nix" {
      passAsFile = ["luaConfig"];
      luaConfig = config.programs.neovim.generatedConfigs.lua;
    } ''
      # Print listing to give context to error messages when viewing logs (as
      # suggested by the assertion's message).
      nl -b a $luaConfigPath

      # `luac` compiles Lua to bytecode, but we can ask it to only parse the input file with `-p`.
      # Result is exported via import-from-derivation.
      if ${pkgs.lua}/bin/luac -p -- $luaConfigPath; then
        echo true >$out
      else
        echo false >$out
      fi
    '';

  isValidSyntax = import "${checkDerivation}";
in {
  assertions = [
    {
      assertion = isValidSyntax;
      message = "Syntax error in Neovim configuration. Run `nix log ${checkDerivation.drvPath}` for more information.";
    }
  ];
}
