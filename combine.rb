#Input
# files offline-donors.csv & online-donors.csv
#
#Output
# [
#  {
#  name: "Area of Greatest Need",
#  donors: 2,
#  dollars: 37000
#  }
#
# ]
require 'csv'
require 'json'

grp = Hash.new(0)
cnt = Hash.new(0)

def load_offline(grp,cnt)

  CSV.open("offline-donors.csv", headers: true).each do |line|
    name =  line["designation_name"]
    unless name.nil? || name.empty?
      grp[name] += line["amount"].to_f
      cnt[name] += 1
    end
  end
end

def load_online(grp,cnt)

  CSV.open("online-donors.csv", headers: true).each do |line|
    des = JSON.parse line["designation"]
    unless des.empty?
      des.each { |g|
        name = g[0]
        grp[name] += g[1].to_f
        cnt[name] += 1
      }
    end
  end
end

load_offline(grp,cnt)
load_online(grp,cnt)

out = []
grp.each {|g|
  out << { name: g[0], donors: cnt[g[0]], dollars: g[1]} unless g[0].nil?
}
puts out.to_json
