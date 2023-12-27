#!/bin/sh
set -ue
cc -Wall -Wextra `pkg-config --cflags --libs sqlite3` guestbook.c -o guestbook
