(function() {
  var ImageGallery, ImageSliderPanel, MainPanel, SearchPanel;

  SearchPanel = React.createClass({
    componentDidMount: function() {},
    startSearch: function() {
      var _base;
      if (typeof (_base = this.props).onBeforeSearch === "function") {
        _base.onBeforeSearch();
      }
      $(this.refs.loading.getDOMNode()).css('visibility', 'visible');
      return $(this.refs.keyword.getDOMNode()).attr("readonly", "readonly");
    },
    endSearch: function(data) {
      this.props.onSearched(data);
      $(this.refs.loading.getDOMNode()).css('visibility', 'hidden');
      return $(this.refs.keyword.getDOMNode()).removeAttr("readonly");
    },
    getSearcher: function() {
      var key;
      key = 'V3pOMy9Fb1J2cUU5ejYvZHRLZHhxSHp4TkJ0Q3dBUFRjcUszTUVDVVkyMD';
      key += 'pXek4zL0VvUnZxRTl6Ni9kdEtkeHFIenhOQnRDd0FQVGNxSzNNRUNVWTIw';
      return this.searcher != null ? this.searcher : this.searcher = new BingSearcher(key);
    },
    handleSearch: function(e) {
      var loader, text;
      e.preventDefault();
      text = this.refs.keyword.getDOMNode().value.trim();
      if (!(text.length > 0)) {
        return;
      }
      this.startSearch();
      loader = this.getSearcher().search(text);
      return loader.done((function(_this) {
        return function(data) {
          return _this.endSearch(data);
        };
      })(this));
    },
    handleSettings: function() {
      return console.log('TODO: settings..');
    },
    render: function() {
      return React.createElement("div", {
        "className": "panel-heading has-success"
      }, React.createElement("div", {
        "className": "input-group"
      }, React.createElement("span", {
        "className": "input-group-addon cursor-hand"
      }, React.createElement("img", {
        "ref": "loading",
        "src": "vendor/images/loading-min.gif",
        "style": {
          visibility: 'hidden'
        }
      })), React.createElement("form", {
        "className": "form-inline",
        "onSubmit": this.handleSearch
      }, React.createElement("input", {
        "type": "text",
        "ref": "keyword",
        "className": "form-control input-lg",
        "placeholder": "Search",
        "autofocus": 'autofocus'
      })), React.createElement("div", {
        "className": "input-group-addon cursor-hand",
        "onClick": this.handleSettings
      }, "\u00a0\u2663\u00a0")));
    }
  });

  ImageGallery = React.createClass({
    getInitialState: function() {
      return {
        images: [],
        __next: false
      };
    },
    componentDidMount: function() {
      return console.log(this.getDOMNode());
    },
    render: function() {
      var idx, image, imgs, title, url;
      imgs = (function() {
        var _i, _len, _ref, _ref1, _results;
        _ref = this.state.images;
        _results = [];
        for (idx = _i = 0, _len = _ref.length; _i < _len; idx = ++_i) {
          image = _ref[idx];
          _ref1 = [image.Thumbnail.MediaUrl, image.Title], url = _ref1[0], title = _ref1[1];
          _results.push(React.createElement("img", {
            "className": "img-thumbnail",
            "src": url,
            "alt": title,
            "title": title,
            "data-idx": idx
          }));
        }
        return _results;
      }).call(this);
      return React.createElement("div", {
        "className": "panel-body"
      }, "Panel content");
    }
  });

  ImageSliderPanel = React.createClass({
    getInitialState: function() {
      return {
        images: [],
        __next: false
      };
    },
    initSlick: function() {
      var opts;
      opts = {
        arrows: false,
        autoplay: true,
        infinite: true,
        mobileFirst: true,
        variableWidth: true
      };
      return this.slick = $(this.refs.slick.getDOMNode()).slick(opts);
    },
    destroySlick: function() {
      var slickNode;
      slickNode = $(this.refs.slick.getDOMNode());
      slickNode.slick('unslick');
      slickNode.children().each(function(idx, img) {
        return React.unmountComponentAtNode(img);
      });
      return slickNode.empty();
    },
    stopImgLoader: function() {
      return window.stop();
    },
    refresh: function() {
      if (this.state.images.length < 1) {
        return;
      }
      this.stopImgLoader();
      this.destroySlick();
      return this.initSlick();
    },
    loadNextImage: function() {
      var img, imgLoader;
      if (this.imageQueue.length < 1) {
        return;
      }
      imgLoader = this.refs.imgLoader.getDOMNode();
      img = this.imageQueue.shift();
      imgLoader.width = img.Width;
      imgLoader.height = img.Height;
      return imgLoader.src = img.MediaUrl;
    },
    componentDidMount: function() {
      return this.initSlick();
    },
    handleClick: function(event) {
      return this.slick.slick('slickNext');
    },
    handleImageLoaded: function(event) {
      var img;
      img = event.currentTarget;
      img = $(img).clone(true).removeAttr('style').removeAttr('data-reactid').removeAttr('data-stop');
      this.slick.slick('slickAdd', img);
      return this.loadNextImage();
    },
    handleImageLoadFailed: function(event) {
      console.log('load image failed: %s', event.currentTarget.src);
      return this.loadNextImage();
    },
    render: function() {
      var image;
      this.imageQueue = (function() {
        var _i, _len, _ref, _results;
        _ref = this.state.images;
        _results = [];
        for (_i = 0, _len = _ref.length; _i < _len; _i++) {
          image = _ref[_i];
          _results.push(image);
        }
        return _results;
      }).call(this);
      setTimeout(this.loadNextImage, 500);
      return React.createElement("div", {
        "className": "panel-body cursor-hand"
      }, React.createElement("img", {
        "ref": "imgLoader",
        "onLoad": this.handleImageLoaded,
        "onError": this.handleImageLoadFailed,
        "onClick": this.handleClick,
        "style": {
          display: 'none'
        }
      }), React.createElement("div", {
        "ref": "slick",
        "className": "slider"
      }));
    }
  });

  MainPanel = React.createClass({
    getAvailableScreenSize: function() {
      var panel;
      if (this.availableSize) {
        return this.availableSize;
      }
      panel = $(this.refs.imageGallery.getDOMNode());
      this.availableSize = {
        width: panel.width(),
        height: panel.height()
      };
      return this.availableSize;
    },
    resizeImageFor: function(img, size) {
      var height, rate, title, width;
      width = size.width, height = size.height;
      title = img.Title;
      if (width < img.Thumbnail.Width && height < img.Thumbnail.Height) {
        img = img.Thumbnail;
      }
      rate = width < img.Width ? width / img.Width : 1;
      if (rate !== 1) {
        img.Width = width;
        img.Height = Math.round(img.Height * rate);
      }
      rate = height < img.Height ? height / img.Height : 1;
      if (rate !== 1) {
        img.Height = height;
        img.Width = Math.round(img.Width * rate);
      }
      if (img.Title) {
        img.Title = title;
      }
      return img;
    },
    componentDidMount: function() {
      return $(window).resize((function(_this) {
        return function() {
          return _this.handleWindowResize();
        };
      })(this));
    },
    handleWindowResize: function() {
      var imagePanel, mainHeight, mainPanel, searchHeight, searchPanel, _ref;
      _ref = [this.refs.mainPanel, this.refs.searchPanel, this.refs.imageGallery], mainPanel = _ref[0], searchPanel = _ref[1], imagePanel = _ref[2];
      mainHeight = $(window).height();
      searchHeight = $(searchPanel.getDOMNode()).outerHeight();
      $(mainPanel.getDOMNode()).height(mainHeight);
      return $(imagePanel.getDOMNode()).height(mainHeight - searchHeight);
    },
    handleBeforeSearch: function() {
      var dom;
      return dom = this.refs.imageGallery.getDOMNode();
    },
    handleSearched: function(data) {
      var image, images, size;
      size = this.getAvailableScreenSize();
      images = (function() {
        var _i, _len, _ref, _results;
        _ref = data.results;
        _results = [];
        for (_i = 0, _len = _ref.length; _i < _len; _i++) {
          image = _ref[_i];
          _results.push(this.resizeImageFor(image, size));
        }
        return _results;
      }).call(this);
      this.refs.imageGallery.refresh();
      return this.refs.imageGallery.setState({
        images: images,
        nextPage: data.__next
      });
    },
    render: function() {
      return React.createElement("div", {
        "className": "container-fluid"
      }, React.createElement("div", {
        "className": "row"
      }, React.createElement("div", {
        "className": "panel panel-success",
        "ref": 'mainPanel'
      }, React.createElement(SearchPanel, {
        "ref": "searchPanel",
        "onSearched": this.handleSearched,
        "onBeforeSearch": this.handleBeforeSearch
      }), React.createElement(ImageSliderPanel, {
        "ref": "imageGallery"
      }))));
    }
  });

  React.render(React.createElement(MainPanel, null), document.body);

  $(window).trigger('resize');

}).call(this);
