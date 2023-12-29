# frozen_string_literal: true

require 'csv'
require 'google/apis/civicinfo_v2'
require 'erb'

def clean_zipcodes(zipcode)
  zipcode.to_s.rjust(5, '0')[0..4]
end

puts 'Event manager Initialized'

def legislators_by_zipcode(zipcode)
  civic_info = Google::Apis::CivicinfoV2::CivicInfoService.new
  civic_info.key = 'AIzaSyClRzDqDh5MsXwnCWi0kOiiBivP6JsSyBw'

  begin
    civic_info.representative_info_by_address(
      address: zipcode,
      levels: 'country',
      roles: %w[legislatorUpperBody legislatorLowerBody]
    ).officials
  rescue
    'You can find your representative by visiting www.commoncause.org/take-action/find-elected-officials'
  end
end

template = File.read('form_letter.erb')
erb_template = ERB.new template

content = CSV.open(
  'event_attendees.csv',
  headers: true,
  header_converters: :symbol
)
content.each do |row|
  id = row[0]
  name = row[:first_name]
  zips = clean_zipcodes(row[:zipcode])
  legislators = legislators_by_zipcode(zips)

  personal_message = erb_template.result(binding)

  Dir.mkdir('output') unless Dir.exist?('output')
  filename = "output/thanks_#{id}.html"

  File.open(filename, 'w') do |file|
    file.puts personal_message
  end
end
