require 'spec_helper'
describe Note do
  describe "#note_does_not_overlap" do
    before do
      site = Site.create!(name: 'Test')
      @document = site.documents.build
      @version = Version.new(content: "/*\nType: Test\nLayer: Fake\nVariation: 1\n*/")
      @document.versions << @version
      @document.active_version = @version
      @version.document = @document
      @version.save
      Note.create(version_id: @version.id, body: "Test", start_character: 1, end_character: 10)
      Note.create(version_id: @version.id, body: "Test", start_character: 15, end_character: 20)
    end
    
    it "11..14 should be valid, as it does not collide" do
      n = Note.new(body: "Test", start_character: 11, end_character: 14, version_id: @version.id)
      n.valid?.should be_true
    end
  end
end