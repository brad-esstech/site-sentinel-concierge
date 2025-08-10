require 'logger'
require 'json'
require 'time'

# create log directory if it doesn't exist
Dir.mkdir "#{ROOT_PATH}/log" if not Dir.exist?"#{ROOT_PATH}/log" 

def get_holidays
  until File.exist? HOLIDAYS
    @log.error "Holidays list #{HOLIDAYS} does not exist... waiting 3 seconds..."
   sleep(3)
  end
  holidays = JSON.parse(File.read(HOLIDAYS))
  #holidays.push ({ "date" => "2022-12-15", "localName" => "International JB Day", "global" => false, "counties" => "[\"AUS-TAS, AUS-WA\"]" })
  #holidays.push ({ "date" => "2022-12-15", "localName" => "International JB Day", "global" => true })
  return holidays
end

