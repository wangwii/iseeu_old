(function() {
  var BingSearcher;

  BingSearcher = (function() {
    function BingSearcher(api_key, format) {
      if (format == null) {
        format = 'json';
      }
      this.url = 'https://api.datamarket.azure.com/Bing/Search/v1/Image';
      this.options = {
        dataType: format,
        headers: {
          Authorization: "Basic " + api_key
        }
      };
    }

    BingSearcher.prototype.search = function(q) {
      var data, dtd, opts;
      dtd = $.Deferred();
      data = {
        'Query': "'" + q + "'",
        '$format': this.options.dataType
      };
      opts = $.extend({
        data: data
      }, this.options);
      opts.success = function(data, status, xhr) {
        return dtd.resolveWith(this, [data.d, status, xhr]);
      };
      opts.error = function(xhr, status, error) {
        return dtd.rejectWith(this, [error, status, xhr]);
      };
      $.ajax(this.url, opts);
      return dtd.promise();
    };

    return BingSearcher;

  })();

  window.BingSearcher = BingSearcher;

}).call(this);
