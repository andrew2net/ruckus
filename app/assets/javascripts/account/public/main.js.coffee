(($, window, undefined_, I) ->
  RuckusAccount =
    issuesLoading: false
    elements: {}
    selectors:
      body: "body"
      aboutTabWrapper: "#about-tab-wrapper"
      aboutTabContainer: "#about-tab-containers"
      aboutTabContainers: "#about-tab-containers > div"
      aboutTabButton: "#about-tab-button"
      endoresmentsContainer: "#press_releases"
      endoresmentsButton: "#press_releases-button"
      issuesTabWrapper: "#issues-tab-wrapper"
      issuesSlideWrapper: "#issues-slider-wrapper"
      issuesSlider: "#issues-slider-wrapper .css-slider"
      joinCampaign: "form.join-campaign"
      likes: "a.likes"
      mediaSlider: "#media-slider"
      ajaxModalLinks: ".ajax-modal-link"
      ajaxIssueLinks: ".ajax-issue-link"
      imageModalLinks: ".image-popup"
      videoModalLinks: ".video-popup"
      tabSelectorWrapper: ".tab-selector-wrapper"
      tabSelector: ".tab-selector"
      tabs: "ul.tabs"
      tabsLis: "ul.tabs li"
      tabLinks: "ul.tabs li > a"
      expansionButtons: ".expansion-button"
      expansionContainers: ".expansion-container"
      expansionWrappers: ".expansion-wrapper"

    defaultMFPOptions:
      mainClass: "mfp-fade"
      removalDelay: 160
      callbacks:
        close: ->
          $body = $(this.content).find('.ruckus-modal-body')
          $body.mCustomScrollbar "destroy" if $body.length
        ajaxContentAdded: ->
          $body = $(this.content).find('.ruckus-modal-body')
          if $body.length
            $body.mCustomScrollbar
              theme: 'dark-2'
              scrollInertia: 400
          if $(this.content).hasClass('donate-modal')
            RuckusAccount._initDonateSlider($('.donate-modal'));
          if document.referrer.indexOf('de_account') > -1 and
             window.location.href.indexOf('?resources=info') > -1
            inputFields = this.content.find(".disclaimer").find('input')
            inputFields.addClass('highlighted')
            firstLabel= inputFields.first().prev('label')
            $body.mCustomScrollbar('scrollTo', firstLabel)
          GoogleMap.generateMaps()

    _bindVendors: ->
      self = this
      @elements.mediaSlider.smoothTouchScroll continuousScrolling: false
      @elements.ajaxModalLinks.magnificPopup $.extend(
        type: "ajax"
      , self.defaultMFPOptions)
      @elements.issuesSlideWrapper.on "click", @selectors.ajaxIssueLinks, (event) ->
        event.preventDefault()
        !$(this).closest(".slide").hasClass("full")

      @elements.issuesSlideWrapper.magnificPopup $.extend(
        delegate: ".slide a.slide-link"
        type: "ajax"
        gallery:
          enabled: true
          preload: [
            0
            2
          ]
          navigateByImgClick: false
          arrowMarkup: "<button title=\"%title%\" type=\"button\" class=\"mfp-arrow mfp-arrow-%dir% issues-arrow\"></button>"
          tPrev: "Previous (Left arrow key)"
          tNext: "Next (Right arrow key)"
          tCounter: "<span class=\"mfp-counter\">%curr% of %total%</span>"
      , self.defaultMFPOptions)
      @elements.imageModalLinks.magnificPopup $.extend(
        type: "image"
        mainClass: "mfp-img-mobile"
        image:
          verticalFit: true
      , self.defaultMFPOptions)
      @elements.videoModalLinks.magnificPopup $.extend(
        disableOn: 700
        type: "iframe"
        preloader: false
        fixedContentPos: false
      , self.defaultMFPOptions)
      return

    _bindEvents: ->
      self = this
      @elements.tabSelector.on "click", (event) ->
        event.preventDefault()
        self.toggleTabOpen $(this)
        return

      @elements.aboutTabWrapper.on "click", @selectors.tabLinks, (event) ->
        event.preventDefault()
        elem = $(this)
        self.toggleTabOpen elem
        self.updateActiveTab elem
        self.elements.aboutTabContainers.removeClass "active"
        self.elements.aboutTabContainers.eq(self.elements.aboutTabWrapper.find(self.selectors.tabLinks).index(elem)).addClass "active"
        self.calcAboutContainerHeight()
        return

      @elements.issuesTabWrapper.on("click", @selectors.tabLinks, (event) ->
        event.preventDefault()
        elem = $(this)
        unless self.issuesLoading
          self.toggleTabOpen elem
          self.updateIssues elem
          self.updateActiveTab elem
        return
      ).on "click", ".slide a.slide-link", (event) ->
        unless $(this).closest(".slide").hasClass("full")
          event.preventDefault()
          false

      $(document).on "focus", @selectors.joinCampaign + " input", ->
        terms = $(this).closest("form").find(".terms")
        termsHeight = terms.get(0).scrollHeight
        terms.height termsHeight
        return

      $(document).on 'click', '.expansion-button', (event) ->
        event.preventDefault()
        self.calcExpandContainer $(this)
        return

      @elements.window.on "resize", ->
        self.calcAboutContainerHeight()
        self.calcEndoresmentsContainerHeight()
        return

      @elements.body.on "click", "#social-feed-more", (event) ->
        event.preventDefault()
        console.log "#social-feed-more:click - load more campaign updates items"
        return

      @elements.body.on "click", @selectors.likes, (event) ->
        event.preventDefault()
        self._likesUpdate $(this)
        return

      return

    _checkModernizrMQ: ->
      self = this
      issuesSlider = @elements.issuesSlideWrapper.find(".css-slider")
      if Modernizr.mq("(max-width: 767px)")
        self.smallsize = true
        self.elements.body.addClass "ruckus-small"
        issuesSlider.data "start", 0
      else
        self.smallsize = false
        self.elements.body.removeClass "ruckus-small"
        issuesSlider.data "start", 1
      return

    _initDonateSlider: ->
      if $(".donate-modal").length > 0
        RuckusAccount._donateSlider $(".donate-modal")
        $("a[data-toggle=\"tooltip\"]").tooltip placement: "right"
        $(".dontate-amount").on "click", "input[type=\"radio\"]", ->
          $(".donate-amount-error").remove()
          if $(this).val() is "other"
            $("#other-amount").addClass "active"
          else
            $("#other-amount").removeClass "active"
          return

        $("#donate-form").on "submit", ->
          checkedRadio = $(".dontate-amount").find("input[type='radio']:checked")
          errorMessage = "<p class='donate-amount-error invalid'><label>Please choose contribution amount</label></p>"

          if checkedRadio.length
            $(".donate-amount-error").remove()
          else
            if $(".donate-amount-error").length is 0
              $(".dontate-amount").before(errorMessage)

        $("#donate-form").validator()
      $(".ruckus-modal-body, #donate-terms").mCustomScrollbar "destroy"
      $(".ruckus-modal-body, #donate-terms").mCustomScrollbar theme: "dark-2"
      return

    _donateSlider: (donateModal) ->
      self = this
      donateSlider = donateModal.find(".css-slider")
      nextSteps = donateModal.find("button.next-step")
      donateCancel = donateModal.find("a.donate-cancel")
      donateForm = donateModal.find("form")


      # build the slider
      donateSlider.cssSlider()

      # next step buttons - if form set valid move forward
      nextSteps.on "click", (event) ->
        event.preventDefault()
        slider = donateSlider.data("CSSSlider")
        if self._donateSliderValidate(donateSlider.data("CSSSlider"))
          slider.goTo slider.current + 1

          # do this on slide complete
          donateSlider.on "slider:complete", (event, slider) ->
            $(".ruckus-modal-body input").attr('tabindex', '-1')
            $("#donation-step-" + (slider.current + 1) + ' input').removeAttr('tabindex')
            $(".ruckus-modal-body").mCustomScrollbar "update"
            $(".ruckus-modal-body").mCustomScrollbar "scrollTo", "top"
            $("#donation-steps").find("span:eq(" + slider.current + ")").addClass "current"
            $("#donation-steps").find("span:eq(" + ((slider.current) - 1) + ")").removeClass("current").addClass "completed"
            return

        return


      # donate-cancel links - if clicked, close the modal
      donateCancel.on "click", (event) ->
        event.preventDefault()
        $.magnificPopup.close()
        return

      return

    _donateSliderValidate: (slider) ->
      self = this
      currentSlideFields = $(slider.elements.slides[slider.current]).find("input.required, select.required, textarea.required")
      donateFormValidator = $("#donate-form").data("FormValidator")
      fieldsFilled = true
      currentSlideFields.each ->
        if $(this).val() is ""
          donateFormValidator.validateField @name, true
          fieldsFilled = false
        return


      #TODO::replace with actual validation
      fieldsFilled

    _getElements: ->
      for key of @selectors
        @elements[key] = $(@selectors[key])
      @elements.window = $(window)
      return

    _likesUpdate: (elem) ->
      self = this
      like = elem
      likeCount = like.find("span")
      likeType = like.data("like-type")
      likeID = like.data("like-id")
      data =
        scorable_id: elem.data("id")
        scorable_type: elem.data("type")

      $.ajax "/front/score",
        data: data
        method: "POST"
        dataType: "json"
        complete: (e, xhr, settings) ->
          anotherEls = $(".liked-count[data-id=" + data.scorable_id + "][data-type=" + data.scorable_type + "]")
          count = parseInt(likeCount.html())
          if e.status is 200
            count = (count + 1)
            like.addClass "liked"
          else if e.status is 204
            count = (count - 1)
            like.removeClass "liked"
          anotherEls.html count
          likeCount.html count
          $('#social-feed[data-id="' + data.scorable_id + '"] .likes span').html count
          return

      return

    _setFullSlides: (slider, index) ->
      self = this
      fullSlides = undefined
      if index is 0
        fullSlides = $(slider.elements.slides[index]).add(slider.elements.slides[index + 1])
      else if index is (slider.elements.slides.length - 1)
        fullSlides = $(slider.elements.slides[index]).add(slider.elements.slides[index - 1])
      else
        fullSlides = $(slider.elements.slides[index]).add(slider.elements.slides[index - 1]).add(slider.elements.slides[index + 1])
      $(slider.elements.slides).removeClass "full"
      fullSlides.addClass "full"
      return

    calcAboutContainerHeight: ->
      self = this

      # check to see if the wrapper has the class of open, if so then run update the height of the active container

      # pass in the wrapper and container element for use in the update method
      self.updateExpansionWrapperHeight self.elements.aboutTabContainer, self.elements.aboutTabContainer.find(".active").get(0)  if self.elements.aboutTabContainer.hasClass("open") or Modernizr.mq("(max-width: 767px)")
      return

    calcEndoresmentsContainerHeight: ->
      self = this

      # check to see if the wrapper has the class of open, if so then run update the height of the active container

      # pass in the wrapper and container element for use in the update method
      self.updateExpansionWrapperHeight self.elements.endoresmentsContainer, self.elements.endoresmentsContainer.find(".expansion-container").get(0)  if self.elements.endoresmentsContainer.hasClass("open")
      return

    calcExpandContainer: (elem) ->
      self = this
      wrapper = $(elem).closest(self.selectors.expansionWrappers)
      containers = wrapper.find(self.selectors.expansionContainers)
      container = undefined

      # check to see if there are more than 1 container
      if containers.length > 1

        #more than one - get active
        containers.each (event, ind) ->
          if $(this).hasClass("active")

            # get active class height
            container = $(this).get(0)
            self.expandWrapper wrapper, container
          return

      else if containers.length is 1

        # only one - get height
        # check for 'open' class on elem, if there, remove it and set height to 0 - else add it and set height to scrollheight
        container = $(containers).get(0)
        self.expandWrapper wrapper, container
      return

    expandWrapper: (wrapper, container) ->
      self = this
      buttonOffset = 25

      # check to see if wrapper is open or not then set height
      if wrapper.hasClass("open")
        wrapper.removeClass("open").height 0
      else
        wrapper.addClass "open"
        self.updateExpansionWrapperHeight wrapper, container
      return

    issuesSliderEvents: ->
      self = this
      issuesSlider = @elements.issuesSlideWrapper.find(".css-slider")
      @_checkModernizrMQ()
      @elements.issuesSlideWrapper.find(".slide-fade-wrapper").addClass "fade-in"
      issuesSlider.on "slider:built", (event, slider, index) ->
        self._setFullSlides slider, index
        return

      issuesSlider.cssSlider()
      issuesSlider.on "slider:before", (event, slider, index, direction) ->
        unless Modernizr.mq("(max-width: 767px)")
          if direction is "next"
            if index is slider.elements.slides.length - 1
              index = 1
              slider.goTo index
          if direction is "previous"
            if index is 0
              index = slider.elements.slides.length - 2
              slider.goTo index
        self._setFullSlides slider, index
        return

      return

    toggleTabOpen: (elem) ->
      tabSelectorWrapper = elem.closest(@selectors.tabSelectorWrapper)
      tabSelector = tabSelectorWrapper.find(@selectors.tabSelector)
      if tabSelector.is(":visible")
        if tabSelectorWrapper.hasClass("open")
          tabSelectorWrapper.removeClass "open"
        else
          tabSelectorWrapper.addClass "open"
      return

    updateActiveTab: (elem) ->
      tabSelectorWrapper = elem.closest(@selectors.tabSelectorWrapper)
      tabSelectorWrapper.find(@selectors.tabsLis).removeClass "active"
      elem.closest("li").addClass "active"
      tabSelectorWrapper.find(@selectors.tabSelector).html elem.html()
      return

    updateExpansionWrapperHeight: (wrapper, container) ->
      self = this
      buttonOffset = 25
      wrapper.height container.scrollHeight + buttonOffset if container?
      return

    updateIssues: (elem) ->
      self = this
      elemParentLi = elem.closest("li")
      hrefPartial = elem.attr("href").replace("#", "")
      issuesPartial = "/account/issues-partials/issues-" + hrefPartial + ".html"


      # check if that tab is already active, if it is - do nothing
      unless elemParentLi.hasClass("active")

        # if different - get the new content via ajax

        # set this.issuesLoading = true; - used to prevent other tab loading behaviour
        @issuesLoading = true

        # fade out current slide-inner
        self.elements.issuesSlideWrapper.find(".slide-fade-wrapper").removeClass "fade-in"

        # get new content

        # on success remove old faded out content & add new content in

        # run issuesSliderEvents() to setup the slider and fade it in

        # don't remove content - fade it back in
        $.get(issuesPartial, (data) ->
          self.elements.issuesSlideWrapper.find(".slide-fade-wrapper").remove()
          self.elements.issuesSlideWrapper.append data
          self.issuesSliderEvents()
          return
        , "html").fail(->
          self.elements.issuesSlideWrapper.find(".slide-fade-wrapper").addClass "fade-in"
          return
        ).always ->

          # reset the issuesLoading variable to false
          self.issuesLoading = false
          return

      return

    initialize: ->
      self = this
      @_getElements()
      @_bindVendors()
      @_bindEvents()
      @calcAboutContainerHeight()
      @issuesSliderEvents()
      return


  # Send to global namespace
  window.RuckusAccount = RuckusAccount

  # DOM Ready
  $ ->
    RuckusAccount.initialize()
    return

  return
) jQuery, window, null, Impress
