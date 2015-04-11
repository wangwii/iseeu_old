(function() {
  var ActionBarPanel, ImageGallery, ImageSliderPanel, MainPanel, SearchPanel;

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
        "className": "panel-heading search-bar"
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
    componentDidMount: function() {},
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

  ActionBarPanel = React.createClass({
    getInitialState: function() {
      return {
        total: 0,
        loaded: 0
      };
    },
    render: function() {
      return React.createElement("div", {
        "className": "action-bar"
      }, React.createElement("span", {
        "className": "status",
        "aria-hidden": "true"
      }, this.state.loaded, "\x2F", this.state.total), React.createElement("br", null), React.createElement("span", {
        "className": "glyphicon glyphicon-heart-empty",
        "aria-hidden": "true"
      }), React.createElement("span", {
        "className": "glyphicon glyphicon-share",
        "aria-hidden": "true"
      }), React.createElement("span", {
        "className": "glyphicon glyphicon-piggy-bank",
        "aria-hidden": "true"
      }));
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
      slickNode.empty();
      return this.loadedImgCount = 0;
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
    scalingImg: function(img) {
      var displayImg, height, panel, rate, width, _ref;
      panel = $(this.getDOMNode());
      _ref = [panel.width(), panel.height()], width = _ref[0], height = _ref[1];
      displayImg = {
        title: img.Title
      };
      if (width <= img.Thumbnail.Width && height <= img.Thumbnail.Height) {
        img = img.Thumbnail;
      }
      displayImg.src = img.MediaUrl;
      rate = width < img.Width ? width / img.Width : 1;
      if (rate !== 1) {
        _.merge(displayImg, {
          width: width,
          height: Math.round(img.Height * rate)
        });
      } else {
        _.merge(displayImg, {
          width: img.Width,
          height: img.Height
        });
      }
      rate = height < displayImg.height ? height / displayImg.height : 1;
      if (rate !== 1) {
        _.merge(displayImg, {
          height: height,
          width: Math.round(displayImg.width * rate)
        });
      }
      return displayImg;
    },
    loadNextImage: function() {
      var img, imgLoader;
      if (this.imageQueue.length < 1) {
        return;
      }
      imgLoader = this.refs.imgLoader.getDOMNode();
      img = this.scalingImg(this.imageQueue.shift());
      imgLoader.width = img.width;
      imgLoader.height = img.height;
      imgLoader.src = img.src;
      imgLoader.title = img.title;
      return $(imgLoader).width(img.width).height(img.height);
    },
    componentDidMount: function() {
      this.initSlick();
      if (!this.loadedImgCount) {
        this.loadedImgCount = 0;
      }
      return this.refs.actionBar.setState({
        total: this.totalImgCount,
        loaded: this.loadedImgCount
      });
    },
    handleClick: function(event) {
      return this.slick.slick('slickNext');
    },
    handleImageLoaded: function(event) {
      var img;
      this.loadedImgCount = this.loadedImgCount + 1;
      this.refs.actionBar.setState({
        total: this.totalImgCount,
        loaded: this.loadedImgCount
      });
      img = event.currentTarget;
      img = $(img).clone(true).removeAttr('style').removeAttr('data-reactid');
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
      this.totalImgCount = this.imageQueue.length;
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
      }), React.createElement(ActionBarPanel, {
        "ref": "actionBar"
      }));
    }
  });

  MainPanel = React.createClass({
    componentDidMount: function() {
      return $(window).resize((function(_this) {
        return function() {
          return _this.handleWindowResize();
        };
      })(this));
    },
    handleWindowResize: function() {
      $(this.refs.mainPanel.getDOMNode()).height($(window).height());
      return $(this.refs.mainPanel.getDOMNode()).width($(window).width());
    },
    handleBeforeSearch: function() {},
    handleSearched: function(data) {
      var images;
      images = data.results;
      this.refs.imageGallery.refresh();
      this.refs.imageGallery.setState({
        images: images,
        nextPage: data.__next
      });
      return this.hideSearchPanel();
    },
    hideSearchPanel: function() {
      return $(this.refs.searchPanel.getDOMNode()).slideUp(200);
    },
    handleDblClick: function() {
      return $(this.refs.searchPanel.getDOMNode()).toggle(200);
    },
    render: function() {
      return React.createElement("div", {
        "className": "container-fluid",
        "onDoubleClick": this.handleDblClick
      }, React.createElement("div", {
        "className": "row panel",
        "ref": 'mainPanel'
      }, React.createElement(SearchPanel, {
        "ref": "searchPanel",
        "onSearched": this.handleSearched,
        "onBeforeSearch": this.handleBeforeSearch
      }), React.createElement(ImageSliderPanel, {
        "ref": "imageGallery"
      })));
    }
  });

  React.render(React.createElement(MainPanel, null), document.body);

  $(window).trigger('resize');

}).call(this);
