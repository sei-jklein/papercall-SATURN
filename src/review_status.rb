require 'papercall'
require 'date'
require 'yaml'

# Get the full submission download from Papercall. Extract a few fields
# to support review status. Sort by the created_at timestamp to put the
# newest submissions at the bottom of the list, and then export as a
# tab-delimited file. You can cut and paste the new submissions directly
# into the Google sheet and assign reviewers.
#
# Note that PaperCall UI does not order the submissions, so the new
# submissions will not be at the end of the list in PaperCall. We generate
# a direct link to each submission, based on the id, and include that to
# make assignment tagging easier.

pc_conf = YAML::load_file('conf/pc.conf')

Papercall.fetch(:from_papercall,
                pc_conf["api_key"],
                :submitted,
                :accepted,
                :rejected,
                :waitlist,
                :declined)

link_prefix = pc_conf["link_prefix"]

abbr_submissions = [] # Abbreviated abbr_submissions
Papercall.all.each do |submission|
  rating = submission['rating']
  variance = 0.0

  ratings = submission['ratings']
  reviewers = ''

  ratings.each do |review|
    value = review['value']
    reviewers << review['user']['name'].partition(' ')[2] \
              << '[' << value.to_s << ']' \
              << ', '
    variance += (value-rating) * (value-rating)
  end

  reviewers = reviewers[0..-3] 	#chop off the last ', '
  variance /= ratings.length
  std_dev = Math.sqrt(variance)
  std_dev = std_dev.to_i if !std_dev.to_f.nan?

  abbr_submissions << {
    id: submission['id'], \
    created_at: submission['created_at'], \
    status: submission['state'], \
    title: submission['talk']['title'], \
    format: submission['talk']['talk_format'][0..2], \
    author: submission['profile']['name'], \
    rating: rating.to_i, \
    n_reviews: ratings.length, \
    std_dev: std_dev, \
    reviewers: reviewers, \
    feedback: submission['feedback'].length, \
    link: link_prefix + submission['id'].to_s
    }
end

# sort by created_by timestamp to create consistent ordering
abbr_submissions.sort! { |x,y| x[:created_at] <=> y[:created_at] }

tsv = ''
tab = "\t"
n = 0 # index so we can recover the ordering in the spreadsheet
abbr_submissions.each do |submission|
    tsv << n.to_s << tab << \
           submission[:id].to_s << tab << \
           submission[:status].to_s << tab << \
           submission[:title].to_s << tab << \
           submission[:format].to_s << tab << \
           submission[:author].to_s << tab << \
           submission[:rating].to_s << tab << \
           submission[:n_reviews].to_s << tab << \
           submission[:std_dev].to_s << tab << \
           submission[:reviewers].to_s << tab << \
           submission[:feedback].to_s << tab << \
           submission[:link] << "\n"
    n += 1
end

File.write('review-status-' + Date.today.to_s + '.tsv', tsv)
