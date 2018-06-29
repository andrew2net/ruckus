(($, window, undefined_, I) ->
  RuckusMain =
    smallMenuAnimating: false
    elements: {}
    selectors:
      ajaxModalLinks: ".ajax-modal-link"
      imageModalLinks: ".image-modal-link"
      body: "body"
      cancelLinks: "a.cancel-link"
      contactForm: "#contact-form"
      expandMenu: "#expand-menu"
      goToLinks: ".goto-link[data-goto]"
      mainFeatures: ".main-features .feature"
      scrollToLinks: "a[data-scrollto]"
      sliders: ".slider"
      signupForm: "#signup-form"
      hideSmallMenu: '.hide-small-menu'

    defaultMFPOptions:
      mainClass: "mfp-fade"
      removalDelay: 160
      showCloseBtn: true
      closeOnBgClick: false
      callbacks:
        ajaxContentAdded: ->
          if $(".login-signup-modal").length > 0
            $(".login-form, .forgot-password-form").validator()  if $(".login-form, .forgot-password-form").length
            $(".signup-form").validator()  if $(".signup-form").length

    _bindVendors: ->
      self = this
      @elements.contactForm.validator()
      @elements.signupForm.validator()
      @elements.ajaxModalLinks.magnificPopup $.extend(
        type: "ajax"
      , self.defaultMFPOptions)
      @elements.imageModalLinks.magnificPopup $.extend(
        type: "image"
        image:
          verticalFit: true
      , self.defaultMFPOptions)
      @elements.sliders.cssSlider()

    _bindEvents: ->
      self = this
      @elements.body.on "click", @selectors.scrollToLinks, (event) ->
        event.preventDefault()
        $el = $($(this).data("scrollto"))
        speed = (if ($(this).data("scrollto-speed")) then $(this).data("scrollto-speed") else 1000)
        offset = ((if $(this).data("scrollto-offset") then $(this).data("scrollto-offset") else 0))
        I.scrollTo $el, speed, offset

      @elements.expandMenu.on "click", (event) ->
        event.preventDefault()
        self._smallMenuHandling()

      @elements.hideSmallMenu.on 'click', (event) ->
        self._smallMenuHandling(hide: true)

      @elements.body.on "transitionend webkitTransitionEnd oTransitionEnd MSTransitionEnd", (event) ->
        self._smallMenuReset()  if event.target.tagName is "BODY"

      @elements.window.on "resize", ->
        self._smallMenuHeight()

        # 768 or larger
        self._smallMenuReset true  if Modernizr.mq("only screen and (min-width: 768px)")

      @elements.body.on("click", @selectors.goToLinks, (event) ->
        event.preventDefault()
        data = $(this).data("goto")
        leftPos = 0
        leftPos = "-100%"  if data is "forgot-password"
        $(this).closest(".form-wrapper").css left: leftPos
      ).on "click", @selectors.cancelLinks, (event) ->
        event.preventDefault()
        $.magnificPopup.close()

      @elements.mainFeatures.each ->
        mainFeature = $(this)
        self.elements.window.yAxis "attach", (->
          padding = 100
          offset = mainFeature.offset().top - self.elements.window.height() / 2
          offset - padding
        ), ->
          mainFeature.addClass "visible"

    _getElements: ->
      for key of @selectors
        @elements[key] = $(@selectors[key])
      @elements.window = $(window)
      @elements.html = $("html")

    _smallMenuHandling: (options) ->
      self = this
      topOffset = @elements.window.scrollTop()
      @_smallMenuHeight()

      # add animating class that handles hardware acceleration
      @elements.html.addClass "ruckus-nav-animating"

      # get scrollTop and set top position of "fixed" elements to that - since hardware acceleration and transforms cause content box issues - fixed breaks
      # #sm-screen-nav & #footer
      $("#sm-screen-nav, #footer").css top: topOffset

      if (options? && options['hide']) || @elements.html.hasClass("ruckus-nav-open")
        @elements.html.removeClass "ruckus-nav-open"
        @elements.body.find("> .mask").remove()
      else
        @elements.html.addClass "ruckus-nav-open"
        @elements.body.append "<div class=\"mask\"></div>"
        @elements.body.find("> .mask").addClass "on"

    _smallMenuHeight: ->
      self = this
      windowHeight = windowHeight = @elements.window.height()
      $("#sm-screen-nav").css height: windowHeight

    _smallMenuReset: (hardReset) ->
      hardReset = (if typeof hardReset isnt "undefined" then hardReset else false)
      if hardReset
        @elements.html.removeClass "ruckus-nav-open"
        @elements.body.find("> .mask").remove()
      @elements.html.removeClass "ruckus-nav-animating"
      $("#sm-screen-nav, #footer").css top: 0

    _callModal: (href) ->
      $.magnificPopup.open $.extend
        items:
          src: href
          type: 'ajax'
        closeOnBgClick: false
        self.defaultMFPOptions

    _showLoginPopup: ->
      if location.search.indexOf('show_login_popup=true') > -1
        @_callModal('/accounts/sign_in')

    _showInvitationPopup: ->
      if location.search.indexOf('invitation_token') > -1
        @_callModal('/accounts/invitation/accept' + location.search)

    _showSignupPopup: ->
      if location.search.indexOf('show_signup_popup=true') > -1
        @_callModal('/accounts/sign_up')


    initialize: ->
      @_getElements()
      @_bindVendors()
      @_bindEvents()
      @_showLoginPopup()
      @_showSignupPopup()
      @_showInvitationPopup()


  # Send to global namespace
  window.RuckusMain = RuckusMain

  # DOM Ready
  $ ->
    RuckusMain.initialize()

) jQuery, window, null, Impress
