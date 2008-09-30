# Look in the tasks/setup.rb file for the various options that can be
# configured in this Rakefile. The .rake files in the tasks directory
# are where the options are used.

load 'tasks/setup.rb'

ensure_in_path 'lib'
require 'dm-mailchimp-adapter'

task :default => 'spec:run'

PROJ.name = 'dm-mailchimp-adapter'
PROJ.authors = 'FIXME (who is writing this software)'
PROJ.email = 'FIXME (your e-mail)'
PROJ.url = 'FIXME (project homepage)'
PROJ.rubyforge.name = 'dm-mailchimp-adapter'

PROJ.spec.opts << '--color'

# EOF
