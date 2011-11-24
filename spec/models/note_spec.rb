describe Note do
  describe "#note_does_not_overlap" do
    before do
      site = Site.create(name: 'Test')
      @document = Document.create(content: "/*\nType: Test\nLayer: Fake\nVariation: 1\n*/", site_id: site.id)
      Note.create(document_id: @document.id, body: "Test", start_character: 1, end_character: 10)
      Note.create(document_id: @document.id, body: "Test", start_character: 15, end_character: 20)
    end
    
    it "11..14 should be valid, as it does not collide" do
      n = Note.new(body: "Test", start_character: 11, end_character: 14, document_id: @document.id)
      n.valid?.should be_true
    end
  end
end