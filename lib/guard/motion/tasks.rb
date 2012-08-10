# include rake task spec:specific only if included in a rake file
if Kernel.const_defined?(:Rake)
  desc "Run a specific list of motion specs"
  namespace :spec do
    task :specific, :files do |task, args|
      files = args[:files]

      if files.nil? || files.empty?
        puts "No spec file passed to the task."
        puts "Please run the task like this: `rake spec:specific[./spec/app_delegate_spec.rb;./spec/other_spec.rb]`"
        exit 1
      end

      App.config.spec_mode = true
      spec_files = App.config.spec_files.select{|file_path| !(file_path =~ /_spec.rb$/)}
      spec_files += files.split(';')
      App.config.instance_variable_set("@spec_files", spec_files)
      Rake::Task["simulator"].invoke
    end
  end
end