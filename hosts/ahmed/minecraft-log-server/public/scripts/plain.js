import ReconnectingEventSource from "./reconnecting-eventsource.min.js";

function main() {
	const sse = new ReconnectingEventSource("/stream", {
		// Retry time after browser fails to reconnect (e.g. HTTP 502).
		// This is pretty sus, so let's wait a little longer...
		max_retry_time: 5_000,
	});

	sse.addEventListener("open", (event) => {
		addSpecialMessage("info", "Connection to log server established!");
	});

	sse.addEventListener("error", (event) => {
		console.error("SSE Error: ", event);
		addSpecialMessage("error", "Connection to log server lost! Retrying connection...");
	});

	sse.addEventListener("entry", (event) => {
		const line = JSON.parse(event.data);
		addEntry(line);
	});
}

function addEntry(json) {
	const $container = document.createElement("span");
	$container.classList.add("regular");

	const $time = document.createElement("time");
	const timestamp = new Date(+json["__REALTIME_TIMESTAMP"] / 1000);
	$time.textContent = `[${timestamp.toISOString()}]: `;
	$time.dateTime = timestamp;
	$container.append($time)

	const $unit = document.createElement("span");
	$unit.textContent = json["_SYSTEMD_UNIT"];
	$container.append($unit);
	$container.append(": ")

	const $message = document.createElement("span");
	$message.textContent = json["MESSAGE"];
	$container.append($message);

	$container.append("\n");
	addToOutput($container);
}

function addSpecialMessage(klass, message) {
	const $message = document.createElement("span");
	$message.classList.add(klass);
	$message.textContent = message;
	$message.textContent += "\n";
	addToOutput($message);
}

function addToOutput($elem) {
	// TODO: Maybe allow for a little wiggle-room?
	const wasAtBottom = window.innerHeight + window.scrollY >= document.body.offsetHeight;

	const $target = document.getElementById("target");
	$target.appendChild($elem);

	if (wasAtBottom) {
		window.scrollTo(0, document.body.scrollHeight);
	}
}

main();
