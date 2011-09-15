class DunsError < Exception
end

# = Synopsis
# The Duns library provides a small wrapper around the Dun & Bradstreet
# website's advanced search functionality.  Currently it only implements
# searching for company by DUNS number.
#
# == Example
#  require 'rubygems'
#  require 'duns-lookup'
#
#  Duns.lookup_duns( *invalid_number* )
#     # => nil
#  Duns.lookup_duns( *some_valid_number* )
#     # => {:name => *a_name*, :address => *an_address*}

class Duns
  require 'rubygems'
  require 'open-uri'
  require 'mechanize'
  
  # D&B homepage URL
  @@dnb_homepage = 'http://smallbusiness.dnb.com/'
  
  # The URI for D&B advanced search
  @@dnb_advanced_search = 'https://smallbusiness.dnb.com/ePlatform/servlet/AdvancedCompanySearch?storeId=10001&catalogId=70001?storeId=10001&catalogId=70001'

  # Our Mechanize agent
  @@agent = Mechanize.new
  @@agent.user_agent_alias = 'Windows IE 7'

  ####
  # Look up a given DUNS number in the D&B database.
  # If the number is found, returns a hash with :name and :address keys.
  # Otherwise, returns nil.
  #  
  def self.lookup_duns(number)
    formatted_number = enforce_duns_formatting(number) # Abort early if invalid format
    
    form = @@agent.get( @@dnb_advanced_search ).form('DunsSearchForm')
    form.dunsNumber = formatted_number
    page = @@agent.submit(form)
    
    extract_search_results(page)
  end


  ####
  # Updates the internal URL used as the base for advanced searches.
  # 
  # The D&B website uses lots of extraneous (to us) URL params, and I have no idea what they all mean.
  # If the base URL stops working, this method will try to set a new one by visiting the main page and
  # finding & clicking an Advanced Search link.
  # 
  # This is mostly a precaution, but if searches stop working a good first bet would be to try running this
  # method.  If search is still broken, something actually changed in the D&B HTML and we'll need to retool
  # the gem.
  #
  def self.update_advanced_search_url
    page = @@agent.get( @@dnb_homepage )
    advanced_link = page.links.find{|l| l.text.match(/search/i) && l.uri.to_s.match(/AdvancedCompanySearch/)}
    raise(DunsError, "Unable to find an advanced search link at: #{@@dnb_homepage}") if advanced_link.nil?
    @@dnb_advanced_search = advanced_link.uri.to_s
  end
  
  
  protected
  
  # Given a search page, extract the results
  def self.extract_search_results(page)
    return nil if page.search('div.text-red').size > 0
    
    # Given a DUNS number search, we only expect one result.  For other search types (when/if implemented), loop over all TRs returned in this table
    company_name    = extract_name( page.search("//table[@id='SearchResultsTable']//tr[1]/td[2]") )
    company_address = extract_address( page.search("//table[@id='SearchResultsTable']//tr[1]/td[3]") )

    {:name => company_name, :address => company_address}
  end
  
  # Retrieve an address from the proper D&B HTML for the td element
  def self.extract_address(td)
    td.text.gsub(/\s{2,}/, ' ')
  end
  
  # Retrieve a name from the proper D&B HTML for the td element
  def self.extract_name(td)
    raw_text = td.text.gsub(/\s{2,}/, ' ')
    with_js = raw_text.match(/var companyName=escape(.+?)var companyAddr/)[1] # First get the surrounding js, to ensure we don't get confused by e.g. a ) in the company name

    # Now we have e.g. >> ('NORTH TEXAS CIRCUIT BOARD CO., INC.'); << and we need to strip off the extraneous stuff
    with_js[2..-5]
  end
  
  # Strip out non-numeric characters, and raise error if remaining number is still invalid
  def self.enforce_duns_formatting(orig_number)
    number = orig_number.to_s.gsub(/\D/, '')
    raise(DunsError, "Received invalid DUNS number (must be 9 digits): #{orig_number}") unless number.length == 9
    return number
  end
end