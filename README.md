# site-sentinel-concierge
Sits alongside Site Sentinel controller code, to hold open doors during weekday business hours.

Both scripts (get_holidays.rb and concierge.rb) need to be setup in crontab.

get_holidays.rb needs to run as a cron job before the main concierge.rb script; an hour or so before is best.

concierge.rb should be setup to run half an hour or so before the door open time is scheduled.


