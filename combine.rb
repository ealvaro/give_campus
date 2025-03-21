require 'csv'
require 'json'

amounts = Hash.new(0.0)
donor_counts = Hash.new(0)

def process_csv(file)
  CSV.foreach(file, headers: true) { |row| yield row }
end

# Process offline donors
process_csv('offline-donors.csv') do |row|
  name = row['designation_name'].to_s.strip
  name = "undefined" if name.empty?

  amounts[name] += row['amount'].to_f
  donor_counts[name] += 1
end

# Process online donors
process_csv('online-donors.csv') do |row|
  designation_json = row['designation'].to_s.strip
  next if designation_json.empty?

  begin
    JSON.parse(designation_json).each do |designation_name, donation_amt|
      name = designation_name.to_s.strip
      name = "undefined" if name.empty?

      amounts[name] += donation_amt.to_f
      donor_counts[name] += 1
    end
  rescue JSON::ParserError
    # Skip rows with invalid JSON in the designation column
    next
  end
end

# Build and output the result
output = amounts.map do |name, total|
  { name: name, donors: donor_counts[name], dollars: total }
end

puts JSON.pretty_generate(output)