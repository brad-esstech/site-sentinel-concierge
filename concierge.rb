#!/usr/bin/env ruby

require_relative 'config.rb' # site config
require_relative 'common.rb' # common functions

@log = Logger.new(ROOT_PATH + '/log/concierge.txt', 'daily')
@log.datetime_format = "%d-%m-%Y %H:%M:%S"

@log.info "-------------------------------------------"
@log.info "Starting..."

# base date/time calculations from here
current_time = Time.new

# What is the day of the week? If Sat or Sunday, we don't need to do anything.
# if [0,6].include? current_time.wday # 0 = Sunday; 6 = Saturday
#  @log.info "Today is not a weekday... ending."
#  abort
#end

@log.info "It's a weekday. Is it a public holiday?"    

# load holidays list
@log.info "Getting holidays list..."
holidays = get_holidays
@log.info "Got holidays list."

holidays.each do |holiday|
  if current_time.strftime("%Y-%m-%d") == holiday["date"]
    if holiday["global"] == true
      @log.info "Today is #{holiday["localName"]}, which is a national public holiday... ending."
      abort
    elsif holiday["counties"].include? "AUS-WA"
      @log.info "Today is #{holiday["localName"]}, which is a public holiday in WA... ending."
      abort
    end
  end
end

@log.info "Nope, it's a regular workday."

DOOR_OPEN_TIME = Time.new(current_time.strftime("%Y"),current_time.strftime("%m"),current_time.strftime("%d"),DOOR_OPEN_TIME_HOUR,DOOR_OPEN_TIME_MINUTE,00)
DOOR_CLOSE_TIME = Time.new(current_time.strftime("%Y"),current_time.strftime("%m"),current_time.strftime("%d"),DOOR_CLOSE_TIME_HOUR,DOOR_CLOSE_TIME_MINUTE,00)

time_to_quit = false
logged_door_open_message = false

until time_to_quit == true  
  # need to hold relay open from DOOR_OPEN_TIME to DOOR_CLOSE_TIME
  current_time = Time.new # need to keep checking the time
  
  if current_time.between?(DOOR_OPEN_TIME, DOOR_CLOSE_TIME)
    @log.info "Door should be open; checking state of ingress and egress relays, closing if not already closed..." if logged_door_open_message == false
    logged_door_open_message = true
    in_action = fork { exec("python3 #{ROOT_PATH}/solenoids_on.py") }
    Process.detach(in_action)
    sleep(5)
  else
    if current_time > DOOR_CLOSE_TIME
      time_to_quit = true
      in_action = fork { exec("python3 #{ROOT_PATH}/solenoids_off.py") }
      Process.detach(in_action)
      @log.info "Door should be closed until the next work day... ending."
      
    else
      @log.info "Door should be closed until the start of the work day... sleeping one minute"
      sleep(60)
    end
  end
  
end

