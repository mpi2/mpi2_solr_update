require 'date'

Gem::Specification.new do |s|
  s.name        = 'mpi2_solr_update'
  s.version     = '1.1.0'
  s.date        = Date.today.to_s
  s.summary     = "Manage updates from an app to a Solr index"
  s.description = "Manage updates from an app to a Solr index"
  s.authors     = ["Asfand Yar Qazi"]
  s.email       = 'htgt@sanger.ac.uk'
  s.homepage    = 'http://github.com/mpi2/mpi2_solr_update'

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  s.add_dependency 'activesupport'
  s.add_dependency 'json_pure'

  s.add_development_dependency 'test-unit'
  s.add_development_dependency 'mocha'
  s.add_development_dependency 'shoulda'
end
