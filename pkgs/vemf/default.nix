# This isn't the actual definition of the derivation for the Vemf interpreter
# – that is found under vemf-unwrapped. This is just a wrapper script.
{
  writeShellScriptBin,
  vemf-unwrapped,
  rlwrap,
}:
writeShellScriptBin "vemf" ''
  exec -a vemf ${rlwrap}/bin/rlwrap ${vemf-unwrapped}/bin/vemf "$@"
''
