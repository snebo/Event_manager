# frozen_string_literal: true

require 'csv'
require 'google/apis/civicinfo_v2'
require 'erb'
require 'date'

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

def save_thank_you_letter(id, message)
  Dir.mkdir('output') unless Dir.exist?('output')
  filename = "output/thanks_#{id}.html"

  File.open(filename, 'w') do |file|
    file.puts message
  end
end

def clean_phone_number(number)
  number.to_s.gsub!(/[^0-9]/i, '')
  if number.length != 10
    number.length == 11 && number.chr == '1' ? number[1..-1] : 'bad number'
  else
    number
  end
end

def find_most_popular(hrs)
  puts ''
  hr_table = hrs.inject(Hash.new(0)) {|h, v| h[v] += 1; h}
  hr_table = hr_table.sort_by { |_, val| val }.reverse
  hr_table.each { |k, v| puts("#{k}: #{v} registers")}
end

template = File.read('form_letter.erb')
erb_template = ERB.new template

content = CSV.open(
  'event_attendees.csv',
  headers: true,
  header_converters: :symbol
)
hours= [] #store the time
days = []
day_hash = {0 => "Sunday",
1 => "Monday", 
2 => "Tuesday",
3 => "Wednesday",
4 => "Thursday",
5 => "Friday",
6 => "Saturday"}

content.each do |row|
  id = row[0]
  name = row[:first_name].capitalize
  zips = clean_zipcodes(row[:zipcode])
  legislators = legislators_by_zipcode(zips)

  phone_number = clean_phone_number(row[:homephone])
  puts "#{name}: #{phone_number}"

  personal_message = erb_template.result(binding)
  save_thank_you_letter(id, personal_message)

  hours.push(row[:regdate].split(' ')[1].split(':')[0])

  days.push(day_hash[Date.strptime("#{row[:regdate]}", '%m/%d/%y').wday])
  
end
find_most_popularhours(hours)
find_most_popular(days)