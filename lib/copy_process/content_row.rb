module CopyProcess
  class ContentRow
    attr_reader :type_name, :content, :kw, :layer
  
    def initialize(type_name, content, kw, layer)
      @type_name = type_name
      @content = content
      @kw = kw
      @layer = layer
    end
  end
end