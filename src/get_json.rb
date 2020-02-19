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

File.write('/saturn/saturn-' + Date.today.to_s + '.json', Papercall.all.to_json)
