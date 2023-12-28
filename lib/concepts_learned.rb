# frozen_string_literal: true

# concepts learned
puts 'Event manager Initialized'
file_name = 'event_attendees.csv'
if File.exist?(file_name)
  # contents = File.read(file_name) #reads teh whole file into contents
  lines = File.readlines(file_name) # puts each line in an array
  lines.each_with_index do |line, idx|
    next if idx.zero?

    coloums = line.split(',')
    first_name = coloums[2]
    p first_name
  end
end
