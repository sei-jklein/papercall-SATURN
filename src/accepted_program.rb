require 'papercall'
require 'date'
require 'yaml'

# Get the full submission download from Papercall. Extract a few fields to support
# populating the program schedule

pc_conf = YAML::load_file('conf/pc.conf')

Papercall.fetch(:from_papercall,
                pc_conf["api_key"],
                :accepted,
                :waitlist)

abbr_submissions = Array.new
Papercall.all.each do |submission|
  if (submission["state"] != "rejected") then
	  abbr_submissions << {:id=>submission["id"], \
						   :title=>submission["talk"]["title"], \
						   :author=>submission["profile"]["name"], \
    	                   :email=>submission["profile"]["email"], \
						   :description=>submission["talk"]["description"], \
						   :bio=>submission["profile"]["bio"]}
  end
end

outstring = ""
EOL = "\n"
abbr_submissions.each do |submission|
	outstring << submission[:id].to_s << EOL
    outstring << submission[:title].to_s << EOL
	outstring << submission[:author].to_s << EOL
	outstring << submission[:email].to_s << EOL << EOL
    # Zap gremlins in the returned text fields.
	outstring << submission[:description].to_s.gsub(/\r/,"") << EOL << EOL << EOL
	outstring << submission[:bio].to_s.gsub(/\r/,"") << EOL << "==========================================" << EOL
end

File.write("accepted_talks-" + Date.today.to_s + ".txt", outstring)
