file_path = "#{__dir__}/../db/db.rb"
lines = File.readlines(file_path)

unless lines.first&.chomp == 'ENV["APP_ENV"] = "test"'
  File.open(file_path, 'w') do |file|
    file.puts('ENV["APP_ENV"] = "test"')
    file.puts(lines)
  end
end
