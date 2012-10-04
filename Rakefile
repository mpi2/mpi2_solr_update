require 'rake/testtask'

Rake::TestTask.new('test:solr:update') do |t|
  t.libs << 'test'
  t.pattern = 'test/unit/**/*_test.rb'
  t.verbose = true
end
Rake::Task['test:solr:update'].comment = 'Run mpi2_solr_update unit tests'

task :test => 'test:solr:update'
