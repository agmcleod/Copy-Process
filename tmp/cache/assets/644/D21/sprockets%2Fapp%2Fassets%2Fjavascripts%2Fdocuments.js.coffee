o: ActiveSupport::Cache::Entry	:@compressedF:@expires_in0:@created_atf1314635259.4219992 	:@value{I"
class:EFI"BundledAsset;
FI"id;
F"%424b570c8108945f8d236e14dfc53622I"logical_path;
FI"documents.js;
TI"pathname;
FI"5$root/app/assets/javascripts/documents.js.coffee;
TI"content_type;
FI"application/javascript;
FI"
mtime;
F"2011-08-29 12:27:37 -0400I"	body;
FI"7(function() {
  $(function() {
    return $('#listify').click(function() {
      var contents, end, item, items, len, list, selectedText, start, val;
      contents = $('#document_content');
      val = contents.val();
      len = val.length;
      start = contents[0].selectionStart;
      end = contents[0].selectionEnd;
      selectedText = val.substring(start, end);
      items = selectedText.split(/\n/);
      list = (function() {
        var _i, _len, _results;
        _results = [];
        for (_i = 0, _len = items.length; _i < _len; _i++) {
          item = items[_i];
          _results.push("<li>" + item + "</li>");
        }
        return _results;
      })();
      return contents.val(val.substring(0, start) + "<ul>" + list.join("\n") + "</ul>" + val.substring(end, len));
    });
  });
}).call(this);
;
TI"asset_paths;
F[I"5$root/app/assets/javascripts/documents.js.coffee;
TI"dependency_paths;
F[{I"	path;
FI"5$root/app/assets/javascripts/documents.js.coffee;
TI"
mtime;
FIu:	Time���  Pn:@_zone"EDT:offseti���I"hexdigest;
F"%f44fbc7ad14e6448735b14f182a808b5I"_version;
F"%04022600d66f9b114572f4f8acc8c150