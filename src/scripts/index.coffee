class BingSearcher
  constructor: (format = 'json') ->
    console.log('create bing search...')
    @url = 'https://api.datamarket.azure.com/Bing/Search/v1/Image'
    @options =
      dataType: format
      headers:
        Authorization: "Basic V3pOMy9Fb1J2cUU5ejYvZHRLZHhxSHp4TkJ0Q3dBUFRjcUszTUVDVVkyMDpXek4zL0VvUnZxRTl6Ni9kdEtkeHFIenhOQnRDd0FQVGNxSzNNRUNVWTIw"

  search: (q, top = 100, skip = 0) ->
    data = {'Query': "'#{q}'", '$format': @options.dataType, '$top': 100, '$skip': 0}
    opts = $.extend({data: data}, @options)
    console.log('..............%o', opts)
    $.ajax(@url, opts)

class GoogleSearcher
  constructor: ->
    console.log('create google search...')
    @url = 'https://www.googleapis.com/customsearch/v1'
    @baseData =
      searchType: 'image'
      cx: '002116361772409970175:tw5q8nr2cws'
      key: 'AIzaSyCHRDnE2KV1RDeI44zmSFLOJgSKkgOG18I'

  search: (q)->
    $.ajax(@url, {data: $.extend({q: q}, @baseData)}).promise()

window.ImageProvider = class ImageProvider
  [g, b] = [new GoogleSearcher(), new BingSearcher()]

  fail = (terms, xhr, status, error)->
    console.log('Failed search [%s]: ', terms, error)

  constructor: ()->
#    console.log 'create images provider'

  search: (terms)->
    #google = g.search(terms).fail (xhr, status, error)-> fail(terms, xhr, status, error)
    bing = b.search(terms).fail (xhr, status, error)-> fail(terms, xhr, status, error)

    #google.done (data)->
    #  console.log('--------------google')
    #  console.log(data)

    bing.done (data)->
      console.log('--------------Bing')
      console.log(data)

#    loader.fail (x, status, error)->
#      console.log(error);
#      console.log(status);
#      console.log(x)
