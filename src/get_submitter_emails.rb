require 'papercall'
require 'date'
require 'yaml'

# Get the full submission download from Papercall. Scrape the submitters name and email
# address and save in a file.

pc_conf = YAML::load_file('conf/pc.conf')

Papercall.fetch(:from_papercall,
                pc_conf["api_key"],
                :submitted,
                :accepted,
                :rejected,
                :waitlist,
                :declined)

submitters = Array.new
Papercall.all.each do |submission|

  submitters << {:name=>submission["profile"]["name"], \
                 :email=>submission["profile"]["email"]
                 }
end

submitters.uniq!

tsv = ""
tab = "\t"
n=0 # index so we can recover the ordering in the spreadsheet
submitters.each do |submitter|
	tsv << submitter[:name] << tab << \
	       submitter[:email].to_s  << "\n"
end

File.write("submitter_emails-" + Date.today.to_s + ".tsv", tsv)
