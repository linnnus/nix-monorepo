import sys
import os

def die(message: str, *, exit_code: int = 1):
    print("yargs: " + message, file=sys.stderr)
    sys.exit(exit_code)

args = sys.argv[1:]
if not args:
    die(f"usage: yargs cmd [args...]")

def do_replacement(args: list[str], substitute: str) -> list[str]:
    new_args = [a.replace("%", substitute) for a in args]
    if new_args == args: # No substitution done
        new_args.append(substitute)
    return new_args

for line in sys.stdin:
    line = line[:-1] # Strip trailing newline
    to_execute = do_replacement(args, line)
    result = os.spawnvp(os.P_WAIT, to_execute[0], to_execute)
    if result > 0:
        exit_code = result
        die(f"subprocessed exited with exit code {exit_code}", exit_code=exit_code)
    elif result < 0:
        SIG = -result
        die(f"subprocessed killed by signal {SIG}")
