Gem::Specification.new do |s|
  s.name = %q{dm-mailchimp-adapter}
  s.version = "1.0.0"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["MandarinSoda"]
  s.autorequire = %q{dm-mailchimp-adapter}
  s.date = %q{2008-10-01}
  s.description = %q{A gem that provides mailchimp api integration via a DataMapper Adapter}
  s.email = %q{}
  s.extra_rdoc_files = ["README", "LICENSE", "TODO"]
  s.files = ["LICENSE", "README", "Rakefile", "TODO", "lib/dm-mailchimp-adapter.rb"]
  s.has_rdoc = true
  s.homepage = %q{http://mandarinsoda.com}
  s.require_paths = ["lib"]
  s.rubygems_version = %q{1.2.0}
  s.summary = %q{A gem that provides mailchimp api integration via a DataMapper Adapter}

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 2

    if current_version >= 3 then
    else
    end
  else
  end
end
