import requests
import os

URL = "https://karriere.forsvaret.dk/varnepligt/varnepligten/cybervarnepligt/"
TARGET_PHRASE = "Der er p&aring; nuv&aelig;rende tidspunkt ikke planlagt nogen afpr&oslash;vninger."

try:
    response = requests.get(URL);
    print(f"Forespørgsel til {URL} gav status {response.status_code}")
except:
    message = "nejj den er ødelagt"
else:
    if TARGET_PHRASE in response.text:
        message = "der er stadig ikke planlagt nogle afprøvninger"
    else:
        message = "noget har ændret sig på siden!!"
        print(response.text)

token = os.getenv("TOKEN")
data = {
   "title": "forsvaret status",
   "message": message,
   "url": URL,
}
response = requests.post(f"https://notifications.linus.onl/api/send-notification/{token}", json=data)
print(f"Forespørgsel til at sende notifikation gav status {response.status_code}")
response.raise_for_status()

