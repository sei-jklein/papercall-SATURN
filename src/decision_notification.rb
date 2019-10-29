require 'papercall'
require 'date'
require 'yaml'

# Get the full submission download from Papercall. Group by decision status to
# facilitate creating notification lists.

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

  submitters << {:title=>submission["talk"]["title"], \
                 :rating=>submission["rating"].to_i, \
                 :decision=>submission["state"], \
                 :name=>submission["profile"]["name"], \
                 :email=>submission["profile"]["email"]
                 }
end

submitters.sort!{ |x,y| x[:decision] <=> y[:decision] }

tsv = ""
tab = "\t"
submitters.each do |submitter|
	tsv << submitter[:decision].to_s << tab << \
	       submitter[:rating].to_s << tab << \
	       submitter[:title].to_s << tab << \
		   submitter[:name].to_s << tab << \
	       submitter[:email].to_s  << "\n"
end

File.write("decision_notification-" + Date.today.to_s + ".tsv", tsv)
