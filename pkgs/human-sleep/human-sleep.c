/*
 * This file uses code stolen from systemd to implement a smarter version of the `sleep` command.
 */

#include <assert.h>
#include <errno.h>
#include <stdbool.h>
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <time.h>

// Misc. utitlites
#define streq(a, b)     (strcmp((a), (b)) == 0)
#define strneq(a, b, n) (strncmp((a), (b), (n)) == 0)
#define ELEMENTSOF(x)   (sizeof(x)/sizeof((x)[0]))

// String categories
#define WHITESPACE          " \t\n\r"
#define DIGITS              "0123456789"

// Type representing XXX.
typedef uint64_t nsec_t;

// Conversion rates
#define NSEC_PER_USEC   ((nsec_t) 1000ULL)
#define NSEC_PER_MSEC   ((nsec_t) 1000000ULL)
#define NSEC_PER_SEC    ((nsec_t) 1000000000ULL)
#define NSEC_PER_MINUTE ((nsec_t) (60ULL*NSEC_PER_SEC))
#define NSEC_PER_HOUR   ((nsec_t) (60ULL*NSEC_PER_MINUTE))
#define NSEC_PER_DAY    ((nsec_t) (24ULL*NSEC_PER_HOUR))
#define NSEC_PER_WEEK   ((nsec_t) (7ULL*NSEC_PER_DAY))
#define NSEC_PER_MONTH  ((nsec_t) (2629800ULL*NSEC_PER_SEC))
#define NSEC_PER_YEAR   ((nsec_t) (31557600ULL*NSEC_PER_SEC))

// XXX Constants
#define NSEC_INFINITY ((nsec_t) UINT64_MAX)

char *startswith(const char *s, const char *prefix) {
        size_t l;

        assert(s);
        assert(prefix);

        l = strlen(prefix);
        if (!strneq(s, prefix, l))
                return NULL;

        return (char*) s + l;
}

static const char* extract_nsec_multiplier(const char *p, nsec_t *ret) {
        static const struct {
                const char *suffix;
                nsec_t nsec;
        } table[] = {
                { "seconds", NSEC_PER_SEC    },
                { "second",  NSEC_PER_SEC    },
                { "sec",     NSEC_PER_SEC    },
                { "s",       NSEC_PER_SEC    },
                { "minutes", NSEC_PER_MINUTE },
                { "minute",  NSEC_PER_MINUTE },
                { "min",     NSEC_PER_MINUTE },
                { "months",  NSEC_PER_MONTH  },
                { "month",   NSEC_PER_MONTH  },
                { "M",       NSEC_PER_MONTH  },
                { "msec",    NSEC_PER_MSEC   },
                { "ms",      NSEC_PER_MSEC   },
                { "m",       NSEC_PER_MINUTE },
                { "hours",   NSEC_PER_HOUR   },
                { "hour",    NSEC_PER_HOUR   },
                { "hr",      NSEC_PER_HOUR   },
                { "h",       NSEC_PER_HOUR   },
                { "days",    NSEC_PER_DAY    },
                { "day",     NSEC_PER_DAY    },
                { "d",       NSEC_PER_DAY    },
                { "weeks",   NSEC_PER_WEEK   },
                { "week",    NSEC_PER_WEEK   },
                { "w",       NSEC_PER_WEEK   },
                { "years",   NSEC_PER_YEAR   },
                { "year",    NSEC_PER_YEAR   },
                { "y",       NSEC_PER_YEAR   },
                { "usec",    NSEC_PER_USEC   },
                { "us",      NSEC_PER_USEC   },
                { "μs",      NSEC_PER_USEC   }, /* U+03bc (aka GREEK LETTER MU) */
                { "µs",      NSEC_PER_USEC   }, /* U+b5 (aka MICRO SIGN) */
                { "nsec",    1ULL            },
                { "ns",      1ULL            },
                { "",        NSEC_PER_SEC    }, /* CHANGED: default is sec */
        };
        size_t i;

        assert(p);
        assert(ret);

        for (i = 0; i < ELEMENTSOF(table); i++) {
                char *e;

                e = startswith(p, table[i].suffix);
                if (e) {
                        *ret = table[i].nsec;
                        return e;
                }
        }

        return p;
}

int parse_nsec(const char *t, nsec_t *ret) {
        const char *p, *s;
        nsec_t nsec = 0;
        bool something = false;

        assert(t);
        assert(ret);

        p = t;

        p += strspn(p, WHITESPACE);
        s = startswith(p, "infinity");
        if (s) {
                s += strspn(s, WHITESPACE);
                if (*s != 0)
                        return -EINVAL;

                *ret = NSEC_INFINITY;
                return 0;
        }

        for (;;) {
		// CHANGED: Use seconds per default
                nsec_t multiplier = 0, k;
                long long l;
                char *e;

                p += strspn(p, WHITESPACE);

                if (*p == 0) {
                        if (!something)
                                return -EINVAL;

                        break;
                }

                if (*p == '-') /* Don't allow "-0" */
                        return -ERANGE;

                errno = 0;
                l = strtoll(p, &e, 10);
                if (errno > 0)
                        return -errno;
                if (l < 0)
                        return -ERANGE;

                if (*e == '.') {
                        p = e + 1;
                        p += strspn(p, DIGITS);
                } else if (e == p)
                        return -EINVAL;
                else
                        p = e;

                s = extract_nsec_multiplier(p + strspn(p, WHITESPACE), &multiplier);
		assert(multiplier != 0);
                if (s == p && *s != '\0')
                        /* Don't allow '12.34.56', but accept '12.34 .56' or '12.34s.56' */
                        return -EINVAL;

                p = s;

                if ((nsec_t) l >= NSEC_INFINITY / multiplier)
                        return -ERANGE;

#if 0
printf("Using multiplier: %llu\n", multiplier);
#endif

                k = (nsec_t) l * multiplier;
                if (k >= NSEC_INFINITY - nsec)
                        return -ERANGE;

                nsec += k;

                something = true;

                if (*e == '.') {
                        nsec_t m = multiplier / 10;
                        const char *b;

                        for (b = e + 1; *b >= '0' && *b <= '9'; b++, m /= 10) {
                                k = (nsec_t) (*b - '0') * m;
                                if (k >= NSEC_INFINITY - nsec)
                                        return -ERANGE;

                                nsec += k;
                        }

                        /* Don't allow "0.-0", "3.+1", "3. 1", "3.sec" or "3.hoge" */
                        if (b == e + 1)
                                return -EINVAL;
                }
        }

        *ret = nsec;

        return 0;
}

static char *concat_arguments(int argc, char *argv[]) {
	size_t buffer_length = 0;
	for (int i = 1; i < argc; i++) {
		buffer_length += strlen(argv[i]);
	}
	buffer_length += argc - 1; // spaces

	char *buffer = calloc(1, buffer_length);
	if (buffer == NULL) {
		perror("failed to alloc (argument concatenation)");
	}

	for (int i = 1; i < argc; i++) {
		if (i != 1) {
			strlcat(buffer, " ", buffer_length);
		}
		strlcat(buffer, argv[i], buffer_length);
	}

	return buffer;
}

static void usage(FILE *fp) {
	const char *name = "human-sleep";

	fprintf(fp, "Usage: %s <description>\n\n", name);
	fprintf(fp, "Description must be something like '1 day' or '2 hours'.\n");
	fprintf(fp, "All arguments are concatenated.\n");
}

static void xnanosleep(struct timespec *ts) {
	struct timespec remainder = *ts;
	while (true) {
		if (nanosleep(&remainder, &remainder) < 0) {
			if (errno == EINTR) {
				continue;
			} else {
				perror("failed to sleep");
				exit(EXIT_FAILURE);
			}
		} else {
			break; // successfully slept
		}
	}
}

int main(int argc, char *argv[])
{
#ifdef TEST
	nsec_t u;
        assert(parse_nsec("5s", &u) >= 0);
        assert(u == 5 * NSEC_PER_SEC);
        assert(parse_nsec("5s500ms", &u) >= 0);
        assert(u == 5 * NSEC_PER_SEC + 500 * NSEC_PER_MSEC);
        assert(parse_nsec(" 5s 500ms  ", &u) >= 0);
        assert(u == 5 * NSEC_PER_SEC + 500 * NSEC_PER_MSEC);
        assert(parse_nsec(" 5.5s  ", &u) >= 0);
        assert(u == 5 * NSEC_PER_SEC + 500 * NSEC_PER_MSEC);
        assert(parse_nsec(" 5.5s 0.5ms ", &u) >= 0);
        assert(u == 5 * NSEC_PER_SEC + 500 * NSEC_PER_MSEC + 500 * NSEC_PER_USEC);
        assert(parse_nsec(" .22s ", &u) >= 0);
        assert(u == 220 * NSEC_PER_MSEC);
        assert(parse_nsec(" .50y ", &u) >= 0);
        assert(u == NSEC_PER_YEAR / 2);
        assert(parse_nsec("2.5", &u) >= 0);
        assert(u == 2);
        assert(parse_nsec(".7", &u) >= 0);
        assert(u == 0);
        assert(parse_nsec("infinity", &u) >= 0);
        assert(u == NSEC_INFINITY);
        assert(parse_nsec(" infinity ", &u) >= 0);
        assert(u == NSEC_INFINITY);
        assert(parse_nsec("+3.1s", &u) >= 0);
        assert(u == 3100 * NSEC_PER_MSEC);
        assert(parse_nsec("3.1s.2", &u) >= 0);
        assert(u == 3100 * NSEC_PER_MSEC);
        assert(parse_nsec("3.1 .2s", &u) >= 0);
        assert(u == 200 * NSEC_PER_MSEC + 3);
        assert(parse_nsec("3.1 sec .2 sec", &u) >= 0);
        assert(u == 3300 * NSEC_PER_MSEC);
        assert(parse_nsec("3.1 sec 1.2 sec", &u) >= 0);
        assert(u == 4300 * NSEC_PER_MSEC);
        assert(parse_nsec(" xyz ", &u) < 0); // failures...
        assert(parse_nsec("", &u) < 0);
        assert(parse_nsec(" . ", &u) < 0);
        assert(parse_nsec(" 5. ", &u) < 0);
        assert(parse_nsec(".s ", &u) < 0);
        assert(parse_nsec(" infinity .7", &u) < 0);
        assert(parse_nsec(".3 infinity", &u) < 0);
        assert(parse_nsec("-5s ", &u) < 0);
        assert(parse_nsec("-0.3s ", &u) < 0);
        assert(parse_nsec("-0.0s ", &u) < 0);
        assert(parse_nsec("-0.-0s ", &u) < 0);
        assert(parse_nsec("0.-0s ", &u) < 0);
        assert(parse_nsec("3.-0s ", &u) < 0);
        assert(parse_nsec(" infinity .7", &u) < 0);
        assert(parse_nsec(".3 infinity", &u) < 0);
        assert(parse_nsec("3.+1s", &u) < 0);
        assert(parse_nsec("3. 1s", &u) < 0);
        assert(parse_nsec("3.s", &u) < 0);
        assert(parse_nsec("12.34.56", &u) < 0);
        assert(parse_nsec("12..34", &u) < 0);
        assert(parse_nsec("..1234", &u) < 0);
        assert(parse_nsec("1234..", &u) < 0);
        assert(parse_nsec("1111111111111y", &u) == -ERANGE);
        assert(parse_nsec("1.111111111111y", &u) >= 0);
#endif

	if (argc < 2) {
		usage(stderr);
		exit(EXIT_FAILURE);
	}

	for (int i = 1; i < argc; ++i) {
		if (streq(argv[i], "--help") || streq(argv[i], "-h")) {
			usage(stdout);
			exit(EXIT_SUCCESS);
		}
	}

	char *description = concat_arguments(argc, argv);
	nsec_t result;
	if (parse_nsec(description, &result) < 0) {
		fprintf(stderr, "Cannot parse duration: %s\n", description);
		exit(EXIT_FAILURE);
	}

	struct timespec ts;
	ts.tv_sec = result / NSEC_PER_SEC;
	ts.tv_nsec = result % NSEC_PER_SEC;
	xnanosleep(&ts);

	return EXIT_SUCCESS;
}

// vi: ft=c noet
