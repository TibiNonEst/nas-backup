#!/usr/bin/ruby
require 'rubygems'
require 'json'
require 'aws-sdk-s3'

json = File.read("#{__dir__}/config.json")
config = JSON.parse(json)

input = ""
config.folders.each do |folder|
  input << " #{folder}"
end
puts "Starting backup"
puts "Starting zipping proccess"
File.delete("#{__dir__}/backup.zip") if File.exist?("#{__dir__}/backup.zip")
Dir.chdir(__dir__) do
  system("zip -r #{__dir__}/backup.zip#{input}")
end
puts "Finished zipping proccess"
puts "Starting upload"

keys = config["keys"]
s3config = config["s3"]
s3 = Aws::S3::Resource.new(region: s3config["region"], endpoint: s3config["endpoint"], access_key_id: keys["access"], secret_access_key: keys["secret"])
obj = s3.bucket(s3config["bucket"]).object(s3config["object"])
obj.upload_file("#{__dir__}/backup.zip")

puts "Upload done"
File.delete("#{__dir__}/backup.zip")
puts "Backup Complete!"
