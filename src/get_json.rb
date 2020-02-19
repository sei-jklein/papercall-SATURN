require 'papercall'
require 'date'
require 'yaml'
require 'json'
# Get the full submission download from Papercall. Save as a json file.

pc_conf = YAML::load_file('conf/pc.conf')

Papercall.fetch(:from_papercall,
                pc_conf["api_key"],
                :submitted,
                :accepted,
                :rejected,
                :waitlist,
                :declined)

abbr_submissions = Array.new # Abbreviated submissions, sanitize identifying information
Papercall.all.each do |submission|
    abbr_submissions << submission['talk']
end

File.write('/saturn/saturn-' + Date.today.to_s + '.json', abbr_submissions.to_json)
