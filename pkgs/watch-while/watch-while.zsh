#!@zsh@/bin/zsh

set -ue

if [ $# -eq 0 ]; then
	echo >&2 "Usage: $0 <command> [arg...]"
	exit 1
fi

# This file should be a (symbolik link to a) file which we want to watch.
# TODO: Once we're finished with that movie, we just read the next.
movie=${XDG_CONFIG_HOME:-$HOME/.config}/watch-while/movie

if [ -f $movie ] && ! [ -v NO_WATCH ]; then
	@mpv@/bin/mpv --save-position-on-quit --autofit='90%x90%' -- $movie >/dev/null 2>&1 &
	mpv_pid=$?
	trap 'kill -s QUIT $mpv_pid' EXIT

	# We don't exec because we want our exit handler to fire.
	"$@" || exit $?
else
	# In this case where we don't have any movie we just transparently run the command.
	exec "$@"
fi
