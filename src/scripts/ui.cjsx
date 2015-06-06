SearchPanel = React.createClass
  componentDidMount: ->
    #console.log 'search panel ready.'

  startSearch: ->
    @props.onBeforeSearch?()

    $(@refs.loading.getDOMNode()).css('visibility', 'visible')
    $(@refs.keyword.getDOMNode()).attr("readonly","readonly")

  endSearch: (data)->
    @props.onSearched data

    $(@refs.loading.getDOMNode()).css('visibility', 'hidden')
    $(@refs.keyword.getDOMNode()).removeAttr("readonly")

  getSearcher: ->
    key = 'V3pOMy9Fb1J2cUU5ejYvZHRLZHhxSHp4TkJ0Q3dBUFRjcUszTUVDVVkyMD'
    key += 'pXek4zL0VvUnZxRTl6Ni9kdEtkeHFIenhOQnRDd0FQVGNxSzNNRUNVWTIw'
    @searcher ?= new BingSearcher key

  handleSearch: (e)->
    e.preventDefault()
    text = @refs.keyword.getDOMNode().value.trim()
    return unless text.length > 0

    @startSearch()
    loader = @getSearcher().search(text)
    loader.done (data)=> @endSearch(data)

  handleSettings: ->
    console.log 'TODO: settings..'

  render: ->
    <div className="panel-heading search-bar">
        <div className="input-group">
            <span className="input-group-addon cursor-hand">
                <img ref="loading" src="vendor/images/loading-min.gif" style={visibility: 'hidden'}/>
            </span>
            <form className="form-inline" onSubmit={@handleSearch}>
                <input type="text" ref="keyword" className="form-control input-lg" placeholder="Search" autofocus='autofocus'/>
            </form>
            <div className="input-group-addon cursor-hand" onClick={@handleSettings}>
                &nbsp;&clubs;&nbsp;
            </div>
        </div>
    </div>

ImageGallery = React.createClass
  getInitialState: ->
    {images: [], __next: false}
  componentDidMount: ->
    #console.log @getDOMNode()

  render: ->
    imgs = for image,idx in @state.images
                [url, title] = [image.Thumbnail.MediaUrl, image.Title]
                <img className="img-thumbnail" src={url} alt={title} title={title} data-idx={idx}/>

    <div className="panel-body">
        Panel content
    </div>

ActionBarPanel = React.createClass
  getInitialState: ->
    {total: 0, loaded: 0}

  render: ->
    <div className="action-bar">
      <span className="status" aria-hidden="true">{@state.loaded}/{@state.total}</span><br/>
      <span className="glyphicon glyphicon-heart-empty" aria-hidden="true"></span>
      <span className="glyphicon glyphicon-share" aria-hidden="true"></span>
      <span className="glyphicon glyphicon-piggy-bank" aria-hidden="true"></span>
    </div>

ImageSliderPanel = React.createClass
  getInitialState: ->
    {images: [], __next: false}

  initSlick: ->
    opts = {
        arrows: false, autoplay: true
        infinite: true, mobileFirst: true, variableWidth: true
    }
    @slick = $(@refs.slick.getDOMNode()).slick opts

  destroySlick: ->
    slickNode = $(@refs.slick.getDOMNode())
    slickNode.slick('unslick')
    slickNode.children().each (idx, img)-> React.unmountComponentAtNode(img)
    slickNode.empty()

    @loadedImgCount = 0

  stopImgLoader: ->
    window.stop()
    #$(@refs.imgLoader.getDOMNode()).attr('alt', 'stop')

  refresh: ->
    return if @state.images.length < 1

    @stopImgLoader()
    @destroySlick()
    @initSlick()

  scalingImg: (img)->
    panel = $(@getDOMNode())
    [width, height] = [panel.width(), panel.height()]

    displayImg = {title: img.Title}
    #displayImg.originSize = {size: img.Width + 'x' + img.Height, tsize: img.Thumbnail.Width + 'x' + img.Thumbnail.Height}
    #displayImg.screenSize = width + 'x' + height

    img = img.Thumbnail if width <= img.Thumbnail.Width and height <= img.Thumbnail.Height
    displayImg.src = img.MediaUrl

    rate = if width < img.Width then width / img.Width else 1
    if rate isnt 1
      _.merge(displayImg, {width: width, height: Math.round(img.Height * rate)})
    else
      _.merge(displayImg, {width: img.Width, height: img.Height})

    rate = if height < displayImg.height then height / displayImg.height else 1
    _.merge(displayImg, {height: height, width: Math.round(displayImg.width * rate)}) if rate isnt 1

    return displayImg

  loadNextImage: ->
    return @finished = true if @imageQueue.length < 1
    imgLoader = @refs.imgLoader.getDOMNode()

    img = @scalingImg(@imageQueue.shift())
    imgLoader.width = img.width
    imgLoader.height = img.height
    imgLoader.src = img.src
    imgLoader.title = img.title
    $(imgLoader).width(img.width).height(img.height)

    #imgLoader.alt = 'L:' + img.originSize.size + '||T:' + img.originSize.tsize + '||S:'
        #+ img.screenSize + '||C:' + img.width + 'x' + img.height

  addImages: (images)->
    @imageQueue = @imageQueue.concat(images)
    setTimeout @loadNextImage, 100 if @finished

  componentDidMount: ->
    @initSlick()
    @loadedImgCount = 0 unless @loadedImgCount
    @refs.actionBar.setState {total: @totalImgCount, loaded: @loadedImgCount}

  handleClick: (event)->
    @slick.slick('slickNext')

  handleImageLoaded: (event)->
    @loadedImgCount = @loadedImgCount + 1
    @refs.actionBar.setState {total: @totalImgCount, loaded: @loadedImgCount}

    img = event.currentTarget
    img = $(img).clone(true).removeAttr('style').removeAttr('data-reactid')
    @slick.slick('slickAdd', img)
    @loadNextImage()

  handleImageLoadFailed: (event)->
    console.log 'load image failed: %s', event.currentTarget.src
    # TODO: maybe should to re-try
    @loadNextImage()

  render: ->
    @imageQueue = (image for image in @state.images)
    @totalImgCount = @imageQueue.length
    setTimeout @loadNextImage, 100

    <div className="panel-body cursor-hand">
        <img ref="imgLoader" onLoad={@handleImageLoaded} onError={@handleImageLoadFailed} onClick={@handleClick} style={display: 'none'}/>
        <div ref="slick" className="slider"></div>
        <ActionBarPanel ref="actionBar"/>
    </div>

MainPanel = React.createClass
  componentDidMount: ->
    $(window).resize => @handleWindowResize()

  handleWindowResize: ->
    $(@refs.mainPanel.getDOMNode()).height($(window).height())
    $(@refs.mainPanel.getDOMNode()).width($(window).width())

  handleBeforeSearch: ->
    # dom = @refs.imageGallery.getDOMNode()

  handleSearched: (data)->
    images = data.results

    # @refs.imageGallery.refresh()
    # @refs.imageGallery.setState {images: images, nextPage: data.__next}
    # @hideSearchPanel()
    @refs.imageGallery.addImages(images);

  hideSearchPanel: ->
    $(@refs.searchPanel.getDOMNode()).slideUp(200)

  handleDblClick: ->
    $(@refs.searchPanel.getDOMNode()).toggle(200)

  render: ->
    <div className="container-fluid" onDoubleClick={@handleDblClick}>
        <div className="row panel" ref='mainPanel'>
            <SearchPanel ref="searchPanel"
                onSearched={@handleSearched}
                onBeforeSearch={@handleBeforeSearch}
             />
            <ImageSliderPanel ref="imageGallery"/>
        </div>
    </div>

React.render <MainPanel/>, document.body
$(window).trigger('resize')
