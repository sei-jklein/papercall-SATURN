require 'papercall'
require 'date'
require 'yaml'

# Do some analysis of feedback events to evaluate effectiveness and usefulness

pc_conf = YAML::load_file('conf/pc.conf')

reviewers = []
File.read('conf/reviewers.txt').each_line {|line|
    # each element is an array [name, event count, last event date]. This sets us up to use
    # assoc later on the name
    # the slice is to remove the trailing "\n"
    reviewers << [line.partition(' ')[2].to_s.slice(0..-2), 0, Date.new(1970,1,1).jd]
}

Papercall.fetch(:from_papercall,
                pc_conf["api_key"],
                :submitted,
                :accepted,
                :rejected,
                :waitlist,
                :declined)

feedback_events = []

Papercall.all.each do |submission|
#   ratings = submission['ratings']
#   ratings.each do |review|
#     # each element is an array [name, event count, last event date]. This sets us up to use
#     # assoc later on the name
#     reviewers << [review['user']['name'].partition(' ')[2], 0, Date.new(1970,1,1).jd]
#   end

  feedback = submission['feedback']
  feedback.each do |event|
    # save user last name and Julian day of the event
    feedback_events << {
      day: DateTime.parse(event['created_at']).jd, \
      name: event['user']['name'].partition(' ')[2]
    }
  end
end

reviewers.uniq!
reviewers.sort! { |x, y| x[0] <=> y[0] }
puts 'Unique reviewers: ' << reviewers.length.to_s

reviewer_events = []
submitter_events = []

feedback_events.each do |event|
  # Note that some of the submissions may have an empty name. We assume
  # that none of the reviewers have an empty name in their profile.
  if reviewers.assoc(event[:name]).nil? then submitter_events << event
  else reviewer_events << event
  end
end
puts 'Total feedback events: ' << feedback_events.length.to_s
puts 'Reviewer events: ' << reviewer_events.length.to_s
puts 'Average reviewer events per submission: ' << \
     (reviewer_events.length / Papercall.all.length.to_f).to_s
puts 'Submitter events: ' << submitter_events.length.to_s

reviewer_events.sort! { |x, y| x[:day] <=> y[:day] }

# scale days to start with the day of the first feedback event
first_day = reviewer_events.first[:day]
reviewer_events.each do |event|
  event[:rday] = event[:day] - first_day
end

histogram = Array.new(reviewer_events.last[:rday] + 1)
day = first_day
histogram.each_index do |i|
  histogram[i] = { date: Date.jd(day).strftime('%F'), count: 0 }
  day += 1
end

reviewer_events.each do |event|
  h_ind = event[:rday]
  histogram[h_ind][:count] = (histogram[h_ind][:count]).to_i + 1
  r_ind = reviewers.find_index { |r| r[0] == event[:name] }
  reviewers[r_ind][1] = (reviewers[r_ind][1]).to_i + 1
  reviewers[r_ind][2] = event[:day]
end

puts 'Date, # of reviewer feedback events'
histogram.each do |h|
  puts h[:date].to_s << '    ' << h[:count].to_s
end

reviewers.sort! { |x, y| y[2] <=> x[2] }
puts 'Reviewer , # of feedback messages sent, date of last event'
reviewers.each do |r|
  puts r[0].to_s.ljust(12) << ' : ' << r[1].to_s.ljust(5) << ' : ' << Date.jd(r[2]).strftime('%F').to_s
end
