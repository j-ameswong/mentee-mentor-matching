file_path = "#{__dir__}/../db/db.rb"
lines = File.readlines(file_path)

if lines.first&.chomp == 'ENV["APP_ENV"] = "test"'
  File.open(file_path, 'w') do |file|
    file.puts(lines[1..-1]) # Write all lines except first
  end
end
