require 'spec_helper'

module CopyProcess
  describe ContentElement do
    describe "#initialize" do
      it "should initialize 2 string variables" do
        ce = ContentElement.new('p1s1', 'some content')
        ce.name.should == 'p1s1'
        ce.content.should == 'some content'
      end
    end
  end
end