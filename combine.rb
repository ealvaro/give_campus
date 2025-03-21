require 'csv'
require 'json'

amounts = Hash.new(0.0)
donor_counts = Hash.new(0)
json_error_amount = 0.0
json_error_count = 0
json_error_rows = []  # Array to capture complete rows with JSON parse errors

def process_csv(file)
  CSV.foreach(file, headers: true) { |row| yield row }
end

# Process offline donors
process_csv('offline-donors.csv') do |row|
  name = row['designation_name'].to_s.strip
  name = "Undefined Designation" if name.empty?
  
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
      name = "Undefined Designation" if name.empty?
      
      amounts[name] += donation_amt.to_f
      donor_counts[name] += 1
    end
  rescue JSON::ParserError
    # Accumulate error donation data and record the complete row
    json_error_amount += row['amount'].to_f
    json_error_count += 1
    json_error_rows << row.to_h
  end
end

# Build aggregated donation groups from valid rows
aggregated = amounts.map do |name, total|
  { name: name, donors: donor_counts[name], dollars: total }
end

# Append aggregated JSON parse error summary if any error occurred
if json_error_count > 0
  aggregated << { name: "JSON parse error", donors: json_error_count, dollars: json_error_amount }
end

# Final output with both aggregated results and error rows
output = {
  aggregated: aggregated,
  json_parse_errors: json_error_rows
}

puts JSON.pretty_generate(output)