import subprocess
import json
import dataclasses
import typing as t
import urllib.parse

@dataclasses.dataclass(kw_only=True, slots=True)
class Event:
    id: t.Optional[str | bytes] = None
    event: t.Optional[str | bytes] = None
    data: t.Optional[bytes | bytes] = None
    retry: t.Optional[int] = None

    def __post_init__(self):
        if (self.id is None and
            self.event is None and
            self.data is None and
            self.retry is None):
            raise ValueError("At least one property of event must be non-None: id, event, data, retry")

    def encode(self) -> bytes:
        """Returns the on-line representation of this event."""

        def to_bytes(s: str | bytes | int) -> bytes:
            if isinstance(s, str):
                return s.encode()
            elif isinstance(s, int):
                return str(s).encode()
            else:
                return s

        # We know the result won't be empty because of the invariant that at least one field is non-None.
        result = b""

        if self.id:    result += b"id: "    + to_bytes(self.id)    + b"\n"
        if self.event: result += b"event: " + to_bytes(self.event) + b"\n"
        if self.data:  result += b"data: "  + to_bytes(self.data)  + b"\n"
        if self.retry: result += b"retry: " + to_bytes(self.retry) + b"\n"

        # With this final newline, the encoding will end with two newlines, signifying end of event.
        result += b"\n"

        return result

def app(environ, start_response):
    print(f"{environ=} {start_response=}") # NOCOMMIT
    path = environ["PATH_INFO"].lstrip("/")
    method = environ["REQUEST_METHOD"]

    if method == "GET" and path == "stream":
        return send_stream(environ, start_response)
    else:
        return send_404(environ, start_response)

def send_stream(environ, start_response):
    status = "200 OK"
    headers = [("Content-Type", "text/event-stream"),
               ("Cache-Control", "no-cache"),
               ("X-Accel-Buffering", "no")]
    start_response(status, headers)

    # Set the retry rate for when the client looses connection.
    retry_event = Event(retry=2_000)
    yield retry_event.encode()

    # Figure out if the client is reconnecting.
    last_event_id = None
    if "HTTP_LAST_EVENT_ID" in environ:
        last_event_id = environ["HTTP_LAST_EVENT_ID"]
    else:
        query = urllib.parse.parse_qs(environ["QUERY_STRING"])
        if "lastEventId" in query:
            last_event_id = query["lastEventId"][0]

    # FIXME: We should also send heartbeat events to avoid NGINX killing our connection.
    UNITS = [ "minecraft-listen.socket", "minecraft-listen.service", "minecraft-server.socket",
              "minecraft-server.service", "minecraft-hook.service", "minecraft-stop.timer",
              "minecraft-stop.service" ]
    for event in get_log_entries(UNITS, last_event_id):
        yield event.encode()

def get_log_entries(units, last_event_id = None) -> t.Generator[Event, None, None]:
    # TODO: We could save some work by only selecting the fields we're interested in with `--fields`.
    args = [
            "/run/current-system/sw/bin/journalctl",
            # We want a stream
            "--follow",
            # A JSON line for each entry
            "--output=json",
            # Use UTC timestamps to avoid tricky timezone issues on the client
            "--utc",
            # Log entries from any of the units (logical OR)
            *(f"--unit={u}" for u in units)
    ]

    # Since we use the cursor as the SSE event ID, the client will send the
    # last cursor when retrying connections.
    if last_event_id:
        # If this is such a connection, we can avoid including duplicate entries by
        # starting just after the given cursor.
        args.append("--after-cursor=" + last_event_id)
    else:
        # Otherwise this the user has just opened the page and we should give
        # them a bit of context for the next lines that appear
        args.append("--lines=200")

    try:
        process = subprocess.Popen(args, stdout=subprocess.PIPE)
        assert process.stdout is not None
        for raw_line in process.stdout:
            assert raw_line[-2:] == b"}\n", "Raw line ends in single newline"
            parsed = json.loads(raw_line)
            event = Event(id=parsed["__CURSOR"],
                          event="entry",
                          data=raw_line.rstrip(b"\n"))
            yield event
    except Exception as e:
        print("Reading (mega sus) journalctl failed", e)
        raise e

def send_404(environ, start_response):
   status = "404 Not Found"
   headers = [("Content-type", "text/plain")]
   start_response(status, headers)
   return [b"The requested resource was not found."]
