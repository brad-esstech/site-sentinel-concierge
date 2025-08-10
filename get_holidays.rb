#!/usr/bin/env ruby

require_relative 'config.rb' # load config
require 'httparty'
require 'digest/md5'

log = Logger.new(ROOT_PATH + '/log/get_holidays.txt', 'daily')
log.datetime_format = "%d-%m-%Y %H:%M:%S"

log.info "Getting public holidays data..."

api_url = "https://date.nager.at/api/v3/PublicHolidays/#{Time.new.year}/AU"
response = HTTParty.get(api_url)

if response.code == 200
  log.info "Successfully retrieved access list."
  
  # get existing access list from disk
  # if contents are the same as what we've retrieved from the server,
  # don't re-write to disk (saves unnecessary writes to SDCard)
  
  if File.exist? HOLIDAYS
    existing_access_list = File.read(HOLIDAYS)
    if Digest::MD5.hexdigest(existing_access_list) == Digest::MD5.hexdigest(response.body)
      log.info "Holidays list on disk (#{HOLIDAYS}) is already up to date."
    else
      log.info "Holidays list on disk is not current..."
      File.write(HOLIDAYS, response.body)
      log.info "Access list written to disk (#{HOLIDAYS})."
    end
  else
    log.info "Holidays list does not exist on disk."
    File.write(HOLIDAYS, response.body)
    log.info "Holidays list written to disk (#{HOLIDAYS})."
  end
else
  log.warn "Failed to retrieve holidays list (HTTP error #{response.code})!"
end
log.info "----------------------------------------------------------------------"