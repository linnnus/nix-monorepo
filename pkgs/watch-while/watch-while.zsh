#!@zsh@/bin/zsh

set -ue

# This file should be a (symbolik link to a) file which we want to watch. Once
# we're finished with that movie, we just read the next.
movie=${XDG_CONFIG_HOME:-$HOME/.config}/watch-while/movie

if [ -f $movie ]; then
	@mpv@/bin/mpv --save-position-on-quit --autofit='90%x90%' -- $movie >/dev/null 2>&1 &
	mpv_pid=$?
	trap 'kill -s QUIT $mpv_pid' EXIT

	# We don't exec because we want our exec handler to fire.
	"$@" || exit $?
else
	# In this case where we don't have any movie we just transparently run the command.
	exec "$@"
fi
