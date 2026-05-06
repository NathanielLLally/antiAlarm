#!/bin/tcsh

# crescendo.csh - Gradually increase volume for the alarm

# Control file path
set control_file = "/var/www/html/alarm_status.txt"

# Check if control file exists
if ( ! -f "$control_file" ) then
    # Optional: Log an error or exit silently
    exit
endif

# Read alarm status and start time
set alarm_status = `grep -o 'enabled\|disabled' "$control_file"`
set start_time_str = `grep -o '[0-9]\\{4\\}-[0-9]\\{2\\}-[0-9]\\{2\\} [0-9]\\{2\\}:[0-9]\\{2\\}:[0-9]\\{2\\}' "$control_file"`

# If alarm is not enabled, exit
if ( "$alarm_status" != "enabled" ) then
    exit
endif

# Get current time and start time in seconds since epoch
set current_time = `date +%s`
set start_time = `date -d "$start_time_str" +%s`

# If it's not time for the alarm yet, exit
if ( $current_time < $start_time ) then
    exit
endif

# Calculate elapsed time in minutes
@ elapsed_minutes = ( $current_time - $start_time ) / 60

# Define maximum volume and duration
set max_vol = 80
set duration = 45

# Calculate target volume
if ( $elapsed_minutes >= $duration ) then
    set volume = $max_vol
else
    # Formula: volume = (elapsed_minutes / duration) * max_vol
    # tcsh doesn't support floating point arithmetic, so we perform integer arithmetic.
    # We multiply first to maintain precision.
    @ volume = ( $elapsed_minutes * $max_vol ) / $duration
endif

# Ensure volume does not exceed max_vol
if ( $volume > $max_vol ) then
    set volume = $max_vol
endif

# Set the volume
/usr/bin/pactl set-sink-volume alsa_output.platform-soc_sound.stereo-fallback "$volume"%

# Check if music is playing
set mpc_status = `mpc status`
if ( `echo "$mpc_status" | grep -q "playing"` ) then
    # Already playing, do nothing
else
    # Start playing
    /usr/bin/mpc play
endif
