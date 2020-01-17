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

abbr_submissions = Array.new # Abbreviated submissions
Papercall.all.each do |submission|
  abbr_submissions << {
    title: submission['talk']['title'], \
    author: submission['profile']['name'], \
    abstract: submission["talk"]["abstract"]
    }
end
tsv = ''
tab = "\t"
EOL = "\n"
abbr_submissions.each do |submission|
    tsv <<  \
    submission[:title].to_s << tab << \
    submission[:author].to_s << tab << \
    submission[:abstract].to_s.gsub(/\r/,"") << EOL << EOL << EOL
end

File.write('/saturn/elevator_pitches-' + Date.today.to_s + '.tsv', tsv)
