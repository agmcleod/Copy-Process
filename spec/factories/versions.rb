# Read about factories at http://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :version do
    document_id 1
    content "/*\n" +
    "Type: Recycling\n" +
    "Layer: State\n" +
    "Variation: 2\n" +
    "*/\n" +
    "HEADER: A second recycling header.\n" +
    "BODY: Recycling sentence one, again - recycling. A second sentence about\n" +
    "recycling, i think. A third sentence about recycling. A fouth sentence about \n" +
    "recycling.\n" +
    "CTA: A call to action - important.\n" +
    "BODY: Recycling sentence* onesise. A second sentence about\n" +
    "recycling. A third sentence about recycling?* A follow up sentence\n" +
    "FOOTER: Some sort of footer\n" +
    "CTA2: A second call to action\n"
  end
  
  factory :bad_version, :class => "Version" do
    document_id 2
    content "HEADER: A second recycling header.\n" +
    "BODY: Recycling sentence one, again. A second sentence about\n" +
    "recycling, i think. A third sentence about recycling. A fouth sentence about \n" +
    "recycling.\n" +
    "CTA: A call to action - important.\n" +
    "BODY: Recycling sentence* onesise. A second sentence about\n" +
    "recycling. A third sentence about recycling?* A follow up sentence\n" +
    "FOOTER: Some sort of footer\n" +
    "CTA2: A second call to action\n"
  end
end
