require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe "DunsLookup" do
  context "Searching by DUNS number" do
    it "should raise an exception when invalid DUNS numbers are supplied" do
      lambda { Duns.lookup_duns('123') }.should raise_error(DunsError)
      lambda { Duns.lookup_duns('abcdefghi') }.should raise_error(DunsError)
      lambda { Duns.lookup_duns('123abc---') }.should raise_error(DunsError)
      lambda { Duns.lookup_duns('') }.should raise_error(DunsError)
    end

    it "should not raise an exception when a valid DUNS number is supplied" do
      lambda { Duns.lookup_duns('123456789') }.should_not raise_error(DunsError)
      lambda { Duns.lookup_duns('123 456 789') }.should_not raise_error(DunsError)
      lambda { Duns.lookup_duns('123-456-789') }.should_not raise_error(DunsError)
    end
    
    it "Returns no results where there shouldn't be any" do
      Duns.lookup_duns( fake_duns[:number] ).should be_nil
    end
  
    it "Should properly extract company name and address when a valid result is found" do
      unless real_duns[:number] && real_duns[:name] && real_duns[:address]
        raise "Must provide information from an existing company to validates results are correct. Edit #real_duns in spec_helper.rb"
      end

      results = Duns.lookup_duns( real_duns[:number] )
      results.should_not be_nil
      results.should be_a_kind_of Hash
      
      results[:name].should == real_duns[:name]
      results[:address].should == real_duns[:address]
    end
  end
end
