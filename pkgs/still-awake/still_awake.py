from tkinter import *
from typing import *
from os import system
from time import asctime, localtime

def position(root: Tk):
    """
    Position the window at the top center of the screen.

    Must be called after all widgets have been added.
    """

    # Apparently a common hack to get the window size. Temporarily hide the
    # window to avoid update_idletasks() drawing the window in the wrong
    # position.
    root.withdraw()
    root.update_idletasks()  # Update "requested size" from geometry manager

    x = (root.winfo_screenwidth() - root.winfo_reqwidth()) / 2
    y = (root.winfo_screenheight() - root.winfo_reqheight()) * 0.2
    root.geometry("+%d+%d" % (x, y))

    # Raise this window and give it focus
    root.deiconify()

def countdown(root: Tk, label: StringVar, counter: int, on_end: Callable):
    if counter > 0:
        content = str(counter) + (" second" if counter == 1 else " seconds")
        label.set(content)
        root.after(1000, countdown, root, label, counter - 1, on_end)
    else:
        on_end()

def sleep(root: Tk):
    """Send the device into hibernation mode."""

    root.destroy()

    print("Shutting down device...")

    # NOTE: This will ask whether python3 should be allowed to control system
    #       events on first invocation. Give it a test run, when you first
    #       install it.
    # system("/usr/bin/osascript -e 'tell app \"System Events\" to sleep'")
    # system("shutdown -s now")
    system("pmset sleepnow")

def dont_sleep(root: Tk):
    """End the application run loop."""

    print("User is still awake. Ending application without shutdown.")
    root.destroy()

def main():
    root = Tk()
    root.title("Still awake?")
    root.attributes("-topmost", True)
    root.resizable(width=False, height=False)

    top_frame = Frame(root, relief=RIDGE, borderwidth=0)
    top_frame.pack(padx=10, pady=(10, 5), expand=1)

    label = Label(top_frame, text="Are you still awake? If not, the device will go to sleep in...")
    label.pack(side=LEFT)

    counter = StringVar()
    counter_label = Label(top_frame, textvariable=counter)
    counter_label.pack(side=LEFT)
    countdown(root, counter, 30, on_end=lambda: sleep(root))

    bottom_frame = Frame(root, relief=RIDGE, borderwidth=0)
    bottom_frame.pack(padx=10, pady=(5, 10), expand=1)

    button = Button(bottom_frame, text="Yes, I'm awake!", command=lambda: dont_sleep(root))
    button.pack(side=BOTTOM)

    position(root)
    root.mainloop()

    print("Finished window loop. End of run.")

if __name__ == "__main__":
    # According to the Daemons and Services Programming Guide:
    #
    #     If you schedule a launchd job by setting the StartCalendarInterval
    #     key and the computer is asleep when the job should have run, your job
    #     will run when the computer wakes up. However, if the machine is off
    #     when the job should have run, the job does not execute until the next
    #     designated time occurs.
    #
    # This is not the behavior we want, so we explicitly check that we are
    # being run in the allowed time span. The definition of "allowed time span"
    # must match that of the job definition in `default.nix`.
    # FIXME: If you turn the computer on at, say, 22:15 the window pops up.
    #        That happens becuase we are within the allowed timspan but it's
    #        not the behavior I want.
    now = localtime()
    if now.tm_hour <= 5 or now.tm_hour >= 21:
        print(f"Starting at {asctime(now)}.")
        main()
    else:
        print(f"Skipping, as invoked outside allowed hours: {asctime(now)}")
