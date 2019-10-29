require 'papercall'
require 'date'
require 'yaml'

# Get the full submission download from Papercall. Extract a few fields to
# support reviewer assignment. Sort by the created_at timestamp to put the
# newest submissions at the bottom of the list, and then export as a
# tab-delimited file. You can cut and paste the new submissions directly
# into the Google sheet and assign reviewers.
#
# Note that PaperCall UI does not order the submissions, so the new
# submissions will not be at the end of the list in PaperCall. We generate a
# direct link to each submission, based on the id, and include that to
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

abbr_submissions = [] # Abbreviated submissions
Papercall.all.each do |submission|
  abbr_submissions << {
    id: submission['id'], \
    created_at: submission['created_at'], \
    title: submission['talk']['title'], \
    name: submission['profile']['name'], \
    link: link_prefix + submission['id'].to_s \
  }
end

# sort by created_by timestamp
abbr_submissions.sort! { |x, y| x[:created_at] <=> y[:created_at] }

tsv = ''
TAB = "\t"
EOL = "\n"
abbr_submissions.each do |submission|
  tsv << submission[:id].to_s << TAB << \
    submission[:title].to_s << TAB << \
    submission[:name].to_s << TAB << \
    submission[:link] << EOL
end

File.write(Date.today.to_s + '.tsv', tsv)
