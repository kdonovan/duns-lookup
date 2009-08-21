$LOAD_PATH.unshift(File.dirname(__FILE__))
$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
require 'duns-lookup'
require 'spec'
require 'spec/autorun'

Spec::Runner.configure do |config|
  
end

# TODO -- to run the specs, input valid information from a real company here
# Try looking up your business by hand first to see exactly the format used by the D&B website
# (for instance punctuation matters, as in the abbreviations of CO and INC below)
def real_duns
  {
    :number   => nil,  # Enter the company's DUNS number
    :name     => nil,  # Enter the official company name, ALL UPPER CASE: FOO WIDGET CO., INC.
    :address  => nil   # Enter the officially registered address, ALL UPPER CASE: 123 W MAIN ST, SAN FRANCISCO, CA
  }
end

# A valid, but non-existant DUNS number
def fake_duns
  {:number => '123456789'}
end
