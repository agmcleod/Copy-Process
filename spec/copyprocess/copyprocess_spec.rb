require 'spec_helper'

module CopyProcess
  describe CopyProcess do
    describe "#contains_valid_headers" do
      it "should return false if invalid" do
        CopyProcess::contains_valid_headers('').should == false
      end
    end
  end
end