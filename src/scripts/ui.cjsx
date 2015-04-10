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
    <div className="panel-heading has-success">
        <div className="input-group">
            <span className="input-group-addon cursor-hand">
                <img ref="loading" src="/vendor/images/loading-min.gif" style={visibility: 'hidden'}/>
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
    console.log @getDOMNode()
  render: ->
    imgs = for image,idx in @state.images
                [url, title] = [image.Thumbnail.MediaUrl, image.Title]
                <img className="img-thumbnail" src={url} alt={title} title={title} data-idx={idx}/>

    <div className="panel-body">
        Panel content
    </div>

ImageSliderPanel = React.createClass
  getInitialState: ->
    {images: [], __next: false}

  initSlick: ->
    opts = {
        arrows: false, autoplay: true, infinite: true,
        mobileFirst: true, variableWidth: true
    }
    @slick = $(@refs.slick.getDOMNode()).slick opts

  destroySlick: ->
    slickNode = $(@refs.slick.getDOMNode())
    slickNode.slick('unslick')
    slickNode.children().each (idx, img)-> React.unmountComponentAtNode(img)
    slickNode.empty()

  stopImgLoader: ->
    window.stop()
    #$(@refs.imgLoader.getDOMNode()).attr('alt', 'stop')

  refresh: ->
    return if @state.images.length < 1
    @stopImgLoader()
    @destroySlick()
    @initSlick()

  loadNextImage: ->
    return if @imageQueue.length < 1
    imgLoader = @refs.imgLoader.getDOMNode()

    img = @imageQueue.shift()
    imgLoader.width = img.Width
    imgLoader.height = img.Height
    imgLoader.src = img.MediaUrl

  componentDidMount: ->
    @initSlick()

  handleClick: (event)->
    @slick.slick('slickNext')

  handleImageLoaded: (event)->
    img = event.currentTarget
    #console.log 'image loaded: %s', img.src

    img = $(img).clone(true).removeAttr('style').removeAttr('data-reactid').removeAttr('data-stop')
    @slick.slick('slickAdd', img)
    @loadNextImage()

  handleImageLoadFailed: (event)->
    console.log 'load image failed: %s', event.currentTarget.src
    @loadNextImage()

  render: ->
    @imageQueue = (image for image in @state.images)
    setTimeout @loadNextImage, 500
    <div className="panel-body cursor-hand">
        <img ref="imgLoader" onLoad={@handleImageLoaded} onError={@handleImageLoadFailed} onClick={@handleClick} style={display: 'none'}/>
        <div ref="slick" className="slider"></div>
    </div>

MainPanel = React.createClass
  getAvailableScreenSize: ->
    return @availableSize if @availableSize
    panel = $(@refs.imageGallery.getDOMNode())
    @availableSize = {width: panel.width(), height: panel.height()}
    return @availableSize

  resizeImageFor: (img, size)->
    {width, height} = size
    title = img.Title
    img = img.Thumbnail if width < img.Thumbnail.Width and height < img.Thumbnail.Height

    rate = if width < img.Width then width / img.Width else 1
    if rate isnt 1
        img.Width = width
        img.Height = Math.round(img.Height * rate)

    rate = if height < img.Height then height / img.Height else 1
    if rate isnt 1
        img.Height = height
        img.Width = Math.round(img.Width * rate)

    img.Title = title if img.Title
    img

  componentDidMount: ->
    $(window).resize => @handleWindowResize()

  handleWindowResize: ->
    [mainPanel,searchPanel,imagePanel] = [@refs.mainPanel, @refs.searchPanel, @refs.imageGallery]
    mainHeight = $(window).height()
    searchHeight = $(searchPanel.getDOMNode()).outerHeight()

    $(mainPanel.getDOMNode()).height(mainHeight)
    $(imagePanel.getDOMNode()).height(mainHeight - searchHeight)

  handleBeforeSearch: ->
    dom = @refs.imageGallery.getDOMNode()

  handleSearched: (data)->
    size = @getAvailableScreenSize()
    images = (@resizeImageFor(image, size) for image in data.results)
    @refs.imageGallery.refresh()
    @refs.imageGallery.setState {images: images, nextPage: data.__next}

  render: ->
    <div className="container-fluid"><div className="row">
        <div className="panel panel-success" ref='mainPanel'>
            <SearchPanel ref="searchPanel"
                onSearched={@handleSearched}
                onBeforeSearch={@handleBeforeSearch}
             />
            <ImageSliderPanel ref="imageGallery"/>
        </div>
    </div></div>

React.render <MainPanel/>, document.body
$(window).trigger('resize')
