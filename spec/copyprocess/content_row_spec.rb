require 'spec_helper'

module CopyProcess
  describe ContentRow do
    describe "#initialize" do
      it "should initialize 3 string variables" do
        row = ContentRow.new('some sentence here', 'p1s1', 'ruby programming')
        row.type_name.should == 'p1s1'
        row.content.should == 'some sentence here'
        row.kw.should == 'ruby programming'
      end
    end
  end
end