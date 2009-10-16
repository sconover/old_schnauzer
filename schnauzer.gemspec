Gem::Specification.new do |s|
  s.name = %q{schnauzer}
  s.version = "0.1"
 
  s.authors = ["Steve Conover"]
  s.date = %q{2009-02-24}
  s.description = %q{A real Safari browser in ruby}
  s.email = %q{sconover@gmail.com}
  s.extensions = []
  s.extra_rdoc_files = ["README", "LICENSE"]
  s.files = []
  s.has_rdoc = true
  s.homepage = %q{http://github.com/sconover/schnauzer/tree/master}
  s.rdoc_options = ["--quiet", "--title", "Schnauzer", "--main", "README", "--inline-source"]
  s.require_paths = ["lib"]
  s.summary = %q{A real Safari browser in ruby.  You can provide your own url request/response handling.  It's fast.}
  s.add_dependency "sinatra"
  s.add_dependency "rubycocoa"
end