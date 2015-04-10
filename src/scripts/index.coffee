class BingSearcher
  constructor: (api_key, format = 'json') ->
    @url = 'https://api.datamarket.azure.com/Bing/Search/v1/Image'
    @options =
      dataType: format,
      headers:
        Authorization: "Basic #{api_key}"

  search: (q) ->
    dtd = $.Deferred();

    data = {'Query': "'#{q}'", '$format': @options.dataType}
    opts = $.extend {data: data}, @options

    opts.success = (data, status, xhr)->
      dtd.resolveWith(@, [data.d, status, xhr])
    opts.error = (xhr, status, error)->
      dtd.rejectWith(@, [error, status, xhr])

    $.ajax(@url, opts)
    dtd.promise()

window.BingSearcher = BingSearcher

#$(document).ready ->
#  app_key = 'V3pOMy9Fb1J2cUU5ejYvZHRLZHhxSHp4TkJ0Q3dBUFRjcUszTUVDVVkyMDpXek4zL0VvUnZxRTl6Ni9kdEtkeHFIenhOQnRDd0FQVGNxSzNNRUNVWTIw';
#
#  display = (image)->
#    thumbnail = image.Thumbnail
#    img = $("<img src=#{thumbnail.MediaUrl} width=#{thumbnail.Width} height=#{thumbnail.Height} />")
#    img.data('image', {u: image.MediaUrl, w: image.Width, h: image.Height})
#    $('body').append(img);
#
#  bing = new BingSearcher(url, app_key);
#  searcher = bing.search 'Java'
#  searcher.done (data, status, xhr)->
    #display(image) for image in data.results
