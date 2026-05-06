# Anti-Alarm Technical Specification

This document outlines the technical details for the anti-alarm system.

## 1. tcsh Script (`crescendo.csh`)

*   **Logic:** The script will be written in `tcsh`. It will be responsible for gradually increasing the volume of the audio output. The volume will increase from 0% to 80% over a period of 45 minutes. The script will calculate the volume increment and the sleep interval to achieve this smooth crescendo.
*   **Control:** The script's execution will be controlled by a trigger file located at `/var/www/html/alarm_status.txt`. The script will check for the existence and content of this file at the start. If the file indicates the alarm is 'on', the script will start the crescendo. If the file indicates 'off' or is not present, the script will either not run or will terminate if already running. The script will also create a process ID (PID) file to prevent multiple instances from running simultaneously.
*   **Interaction:**
    *   It will use the `mpc` (Music Player Client) command to control the Music Player Daemon (`mpd`). Specifically, it will use `mpc play` to start playback.
    *   It will use `pactl` (PulseAudio Controller) to adjust the volume. The `pactl set-sink-volume` command will be used to set the volume of the relevant audio sink.

## 2. Control Mechanism

*   **Trigger File:** The control mechanism will be a simple flat file located at `/var/www/html/alarm_status.txt`.
*   **Format:** The file will contain a single word: `on` or `off`.
    *   `on`: The alarm is active and the crescendo should be running.
    *   `off`: The alarm is inactive.
*   **Usage:**
    *   **`crescendo.csh`:** The script will read this file. If the content is `on`, it will start or continue the crescendo. If the content is `off`, it will terminate gracefully, stopping the music and resetting the volume.
    *   **`cron` job:** The `cron` job will trigger the `crescendo.csh` script. The script itself will contain the logic to check the file and decide whether to run.

## 3. Crontab

*   **Entry:** A `crontab` entry will be created to run every minute.
*   **Command:** `* * * * * /path/to/crescendo.csh`
*   **Logic:** The `cron` job will execute the `crescendo.csh` script every minute. The script itself is responsible for checking the `alarm_status.txt` file and its own PID file to determine if it should start the crescendo, continue running, or exit.

## 4. Frontend (`index.html`)

*   **HTML Structure:** The frontend will be a single `index.html` file.
    *   An `aria-label` will be used for accessibility on the button and slider.
    *   A button will be used to toggle the alarm status between 'on' and 'off'.
    *   A slider will be provided to manually override and set the volume.
*   **JavaScript Interaction:**
    *   The JavaScript code will use `fetch()` to make `POST` requests to a backend endpoint (which will write to the flat file) to update the alarm status.
    *   It will also use `fetch()` to make `GET` requests to retrieve the current alarm status and update the UI accordingly.
*   **CSS Framework:** Milligram CSS will be used. It is a minimalist CSS framework that provides a clean and modern look with a very small footprint, which is ideal for a simple interface like this.

## 5. Nginx Configuration

*   **Serve `index.html`:** Nginx will be configured to serve the `index.html` file as the root of the website.
*   **Serve Flat File:** Nginx will be configured to serve the `/var/www/html/alarm_status.txt` file. A specific `location` block will be created to handle requests for this file, allowing `GET` and `POST` methods.
*   **Backend Interaction:** The Nginx configuration will proxy requests to the backend script that modifies the `alarm_status.txt` file. This will likely involve using `fastcgi_pass` or a similar directive if a simple CGI script is used to handle file writes.
