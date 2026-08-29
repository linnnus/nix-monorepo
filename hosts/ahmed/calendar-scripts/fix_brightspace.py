import requests
import os
from datetime import timedelta
from ical.calendar_stream import IcsCalendarStream
from ical.event import Event

def fix_calendar(raw_ics: str) -> str:
    def map_event(event: Event) -> Event:
        updates = {}
        if event.timespan.duration.total_seconds() == 0:
            # Transform to an all-day event. All-day events are represented by
            # having a date (instead of a datetime) as the start time.
            updates["dtstart"] = event.timespan.start.date()
            updates["dtend"] = event.timespan.start.date() + timedelta(days=1)
        return event.model_copy(update=updates)

    cal = IcsCalendarStream.calendar_from_ics(raw_ics)
    cal.events = [map_event(e) for e in cal.events]
    return IcsCalendarStream.calendar_to_ics(cal)

if __name__ == "__main__":
    CALENDAR_URL = os.environ["CALENDAR_URL"]
    RESULT_PATH = os.environ["RESULT_PATH"]

    response = requests.get(CALENDAR_URL)
    response.raise_for_status()
    ics = fix_calendar(response.text)
    open(RESULT_PATH, "w").write(ics)
