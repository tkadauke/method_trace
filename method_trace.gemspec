Gem::Specification.new do |s| 
  s.platform  =   Gem::Platform::RUBY
  s.name      =   "method_trace"
  s.version   =   "0.0.1"
  s.date      =   Date.today.strftime('%Y-%m-%d')
  s.author    =   "Thomas Kadauke"
  s.email     =   "tkadauke@imedo.de"
  s.homepage  =   "http://www.imedo.de/"
  s.summary   =   "Find method definition site"
  s.files     =   Dir.glob("lib/**/*")

  s.has_rdoc = true
  s.extra_rdoc_files = ["README.rdoc"]
  
  s.require_path = "lib"
end