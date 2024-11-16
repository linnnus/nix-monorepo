{
  writeShellApplication,
  human-sleep,
}:
writeShellApplication {
  name = "disable-sleep";

  runtimeInputs = [human-sleep];

  text = ''
    set -ue

    if [ "$(id -u)" -ne 0 ]; then
            echo "Acquiring root access..."
            exec sudo "$0" "$@"
    fi

    cleanup() {
            echo "Re-enabling sleep..."
            pmset -a disablesleep 0
    }

    echo "Disabling sleep..."
    pmset -a disablesleep 1
    trap cleanup EXIT

    echo "Waiting..."
    human-sleep "$@"
  '';
}
