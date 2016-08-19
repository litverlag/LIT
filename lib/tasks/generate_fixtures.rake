#Usage:
#	bin/rake test:fixture_generator["select * from users","users"]
namespace :test do
  desc "generate fixtures for a given sql query from the current development database"

  task :fixture_generator, [:sql, :file_name] => :environment do |t, args|
    args.with_defaults(:sql => nil, :file_name => nil)
    i = "000"
    p "creating fixture - #{args.file_name}"
    File.open("#{Rails.root}/test/fixtures/#{args.file_name}.yml", 'a+') do |file|
      data = ActiveRecord::Base.connection.select_all(args.sql)
      file.write data.inject({}) { |hash, record|
        number = i.succ!
        hash["#{args.file_name}_#{number}"] = record
        hash
      }.to_yaml
    end

  end
end
