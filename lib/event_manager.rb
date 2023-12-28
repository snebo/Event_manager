# frozen_string_literal: true

require 'csv'

def clean_zipcodes(zipcode)
  zipcode.to_s.rjust(5, '0')[0..4]
end

puts 'Event manager Initialized'

content = CSV.open(
  'event_attendees.csv',
  headers: true,
  header_converters: :symbol
)
content.each do |row|
  names = row[:first_name]
  zips = clean_zipcodes(row[:zipcode])
  p "#{names}: #{zips}"
end
