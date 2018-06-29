(($, window, undefined_, I) ->
  RuckusAdmin =
    elements: {}
    selectors:
      additionalAgreementsField: "#de_account_agreements"
      additionalAgreements: "#additional-agreements"
      addAdditionalAgreement: "a.add-additional-agreement"
      adminMainnav: ".admin-nav"
      adminSubnav: ".admin-subnav"
      body: "body"
      builderOverlay: "#builder-overlay"
      cancel: ".cancel"
      checkBox: ".check-box, .box-form .checkbox"
      dateField: "input.date"
      dashboardGraph: "#dashboard-graph"
      dashboardGraphSelect: "#update-graph-range"
      dashboardGraphUpdateForm: "#update-graph"
      destroyLinks: "a[data-method=\"delete\"]"
      draggable: ".draggable"
      editableText: ".editable"
      error: ".error"
      mediaUploadForm: "#media-upload-form"
      myAccountForm: "#my-account-form"
      onOffSwitch: ".switch:not(.disabled)"
      postFeed: ".post-feed"
      renameLink: ".rename"
      ruckusDropdown: ".ruckus-drop"
      scrollToLinks: "a[data-scrollto]"
      socialFeedForm: "#socialfeed-create"
      tableSort: "table.data"
      thumbSelector: ".thumb-selector"
      tips: "i.tip"
      urlCurlInput: ".url-curl"
      sliders: ".css-slider"

    _turnOnActiveSwitches: ->
      # on/off switches
      $.each $("input[type='checkbox']:checked"), (index, selector) ->
        $(selector).closest('.switch').addClass('active')


    _bindVendors: ->
      self = this
      @elements.draggable.children ""
      @elements.dateField.datepicker dateFormat: "mm/dd/y"
      @elements.tableSort.tablesorter dateFormat: "ddmmyyyy"
      @elements.tips.tooltip()
      @elements.sliders.cssSlider()

      # Graph/Dashboard
      if @elements.dashboardGraph.length
        $("<div id=\"chart-tooltip\" class=\"tooltip top\"><div class=\"tooltip-inner\"><div></div></div><div class=\"tooltip-arrow\"></div></div>").css(
          position: "absolute"
          display: "none"
          opacity: 1
          zIndex: 9999
        ).appendTo "body"
        @elements.dashboardGraphUpdateForm.submit()
      @graphOptions =
        shadowSize: 0
        series:
          lines:
            show: true
            lineWidth: 3

          points:
            show: true
            lineWidth: 0
            radius: 6
            fillColor: "#008DA0"

        legend:
          show: false

        yaxis:
          show: false

        xaxis:
          show: true
          mode: "time"
          timeformat: "%m/%d"
          tickLength: 0
          alignTicksWithAxis: true
          reserveSpace: true
          font:
            size: 14
            lineHeight: 14
            family: "'Lato', sans-serif"
            color: "#AAB1B3"

        grid:
          show: true
          color: "#FFF"
          hoverable: true
          mouseActiveRadius: 10
          labelMargin: 20


      # Flot Graph Update

      # on change of select, trigger submit
      $(document).on("change.updateGraph", @selectors.dashboardGraphSelect, ->
        $(this).parents("form").submit()
        return
      ).on "ajax:complete", @selectors.dashboardGraphUpdateForm, (event, xhr, status) ->
        response = $.parseJSON(xhr.responseText)
        offsetResponse = self._processChartDates(response.data)
        responseInfo = response.info
        self.elements.dashboardGraph.unbind "plothover"
        self.elements.dashboardGraph.plot [
          label: "Visits"
          data: offsetResponse
          color: "#008DA0"
        ], self.graphOptions
        self.elements.dashboardGraph.bind "plothover", (event, pos, item) ->
          if item
            y = Math.round(item.datapoint[1])
            $("#chart-tooltip .tooltip-inner > div").html y + " " + item.series.label + responseInfo[item.dataIndex]
            $("#chart-tooltip").css(
              top: item.pageY - 65
              left: item.pageX - 50
            ).fadeIn 200
          else
            $("#chart-tooltip").hide()
          return

        return


      # ScrollTo Links
      $(document).on "click", @selectors.scrollToLinks, (event) ->
        event.preventDefault()
        $el = $($(this).data("scrollto"))
        speed = (if ($(this).data("scrollto-speed")) then $(this).data("scrollto-speed") else 1000)
        offset = ((if $(this).data("scrollto-offset") then $(this).data("scrollto-offset") else 0))
        I.scrollTo $el, speed, offset
        return

      return

    _bindEvents: ->
      self = this
      @elements.body.on("click.toggleDropdown", (event) ->
        $(".ruckus-drop-options").hide()  unless $(event.target).closest(".ruckus-drop").length is 1
        return
      ).on "click.editText", ->
        self._editTextClose $(".editing")
        return


      # array of IDS in order on the screen

      # Clip Data

      # object ID

      # new Text

      # clear url field
      $(document).on("ruckus:sorted", (doc, el, ids) ->
        console.log ids
        return
      ).on("ruckus:updateClip", (doc, el, data) ->
        console.log data
        return
      ).on("ruckus:updateText", (doc, el, id, text) ->
        console.log id
        console.log text
        return
      ).on("click.closeFields", @selectors.cancel, (event) ->
        $el = $(this)
        href = $el.attr("href")
        action = $el.data("action")
        return  unless action
        event.preventDefault()
      ).on("click.showMsg", @selectors.error, (event) ->
        $el = $(this)
        $errorMessage = $el.find(".error-message")
        return  if $el.hasClass("message-displayed")
        if $errorMessage.length
          event.preventDefault()
          $errorMessage.slideDown 300
          $el.addClass "message-displayed"
        return
      ).on("click.switch", @selectors.checkBox, (event) ->
        event.preventDefault()
        $el = $(this)
        self._switchToggle $el
        return
      ).on("click.switch", @selectors.onOffSwitch, (event) ->
        event.preventDefault()
        $el = $(this)
        self._switchToggle $el
        return
      ).on("change", [
        @selectors.mediaUploadForm
        "input[type=\"file\"]"
      ].join(" "), ->
        self.elements.mediaUploadForm.submit()
        return
      ).on("focus", [
        @selectors.mediaUploadForm
        "input[type=\"url\"]"
      ].join(" "), ->
        $form = $(this).closest("form")
        $form.find(".fileupload").addClass "disabled"
        $form.find("input[type=\"file\"]").prop "disabled", true
        return
      ).on "blur", [
        @selectors.mediaUploadForm
        "input[type=\"url\"]"
      ].join(" "), ->
        $el = $(this)
        $form = $el.closest("form")
        if $el.val() is ""
          $form.find(".fileupload").removeClass "disabled"
          $form.find("input[type=\"file\"]").prop "disabled", false
        return


      # Password repeat validation

      # add required prop to element

      # if password is empty, remove required prop
      $(document).on("focus", [
        @selectors.myAccountForm
        "#new-password-1"
      ].join(" "), ->
        $(this).prop "required", true
        $("#new-password-2").prop "required", true
        return
      ).on("blur", [
        @selectors.myAccountForm
        "#new-password-1"
      ].join(" "), ->
        if $(this).val() is ""
          $(this).prop "required", false
          $("#new-password-2").prop "required", false
        return
      ).on "keyup", [
        @selectors.myAccountForm
        "#new-password-1"
      ].join(" "), ->

        # update algorith for checking password
        $("#new-password-2").attr "pattern", @value
        return


      # jQuery UJS Ajax Events for data-remote forms

      # Destroy Links for item content
      $(document).on "ajax:complete", @selectors.destroyLinks, (event, xhr, status) ->
        $(event.currentTarget).closest(".item").fadeOut 500, ->
          $(this).remove()
          return
        return


      # SocialFeed Form
      $(document).on "ajax:complete", @selectors.socialFeedForm, (event, xhr, status) ->
        $el = $(this)
        $el.find("textarea").val ""
        return

      $(document).on "click.nav", [
        @selectors.thumbSelector
        ".thumb-nav i"
      ].join(" "), (event) ->
        event.preventDefault()
        $el = $(this)
        $parentLi = $el.parents("li")
        return  if $parentLi.hasClass("disabled")
        $parentNav = $parentLi.parents(".thumb-nav")
        $selector = $el.parents(".thumb-selector")
        $thumbs = $selector.find(".thumbs")
        $allThumbs = $thumbs.children("li")
        direction = (if $parentLi.hasClass("next") then "next" else "prev")
        $active = $thumbs.find(".active")
        $nextImg = (if direction is "next" then $active.next("li") else $active.prev("li"))
        return  unless $nextImg.length
        $active.hide().removeClass "active"
        $nextImg.show().addClass "active"
        currentImg = $allThumbs.index($nextImg) + 1
        if currentImg is $allThumbs.length
          $parentNav.find(".next").addClass "disabled"
        else
          $parentNav.find(".next").removeClass "disabled"
        if currentImg > 1
          $parentNav.find(".prev").removeClass "disabled"
        else
          $parentNav.find(".prev").addClass "disabled"
        $selector.find(".thumb-current").text currentImg
        $($selector.parents("form")[0]).find("input[name=\"press_release[active_image_id]\"]").val $nextImg.data("id")
        return

      $(document).on("click.editText", @selectors.editableText, (event) ->
        event.preventDefault()
        event.stopPropagation()
        $el = $(this)
        self._editText $el
        return
      ).on "keydown.editText", [
        @selectors.editableText
        "input[type=\"text\"]"
      ].join(" "), (event) ->
        $el = $(this)
        $editableText = $el.parents(".editable")
        keyCode = event.keyCode

        # esc: 27, enter: 13
        switch keyCode
          when 27
            self._editTextClose $editableText
          when 13
            newText = $editableText.find("input[type=\"text\"]").val()
            if newText.length
              self._editTextClose $editableText, newText
            else
              self._editTextClose $editableText
        return

      $(document).on "click.renameLink", @selectors.renameLink, (event) ->
        event.preventDefault()
        event.stopPropagation()
        $el = $(this)
        $parent = $el.parents("li.white-box")
        $editableText = $parent.find(".editable")
        unless $editableText.hasClass("editing")
          self._editText $editableText
        else
          value = $editableText.find("input[type=\"text\"]").val()
          if typeof value is "string" and value.length
            self._editTextClose $editableText, value
          else
            self._editText $editableText
        return

      $(document).on("click.dropdown", [
        @selectors.ruckusDropdown
        ".ruckus-selected"
      ].join(" "), (event) ->
        event.stopPropagation()
        event.preventDefault()
        $(this).next(".ruckus-drop-options").toggle()
        return
      ).on("click.selectOption", [
        @selectors.ruckusDropdown
        ".ruckus-drop-options > li"
      ].join(" "), (event) ->
        event.stopPropagation()
        event.preventDefault()
        $el = $(this)
        return  if $el.hasClass("new-category")
        issueCategorySlug = $el.data("issue-category")
        self._toggleDrop $el, issueCategorySlug
        return
      ).on "keydown.createNew", [
        @selectors.ruckusDropdown
        ".ruckus-drop-options .new-category input[type=\"text\"]"
      ].join(" "), (event) ->

        # 13 is return/enter;
        if event.keyCode is 13
          $el = $(this)
          issueCategorySlug = $el.val().toLowerCase().replace(" ", "")
          $li = $el.parents("li")
          self._toggleDrop $li, issueCategorySlug
        return

      $(document).on 'click', @selectors.additionalAgreementsField, (event) ->
        $(self.selectors.addAdditionalAgreement).show()

      $(document).on 'blur', @selectors.additionalAgreementsField, (event) ->
        if $(this).val() is ''
          $(self.selectors.addAdditionalAgreement).hide()


      $(document).on "click.addAgreement", @selectors.addAdditionalAgreement, (event) ->
        event.preventDefault()
        additionalAgreementItem = self.elements.additionalAgreements.find(".additional-agreement.item:eq(0)")
        additionalAgreementInput = self.elements.additionalAgreements.find(".form-control")
        if additionalAgreementInput.val()
          additionalAgreementItemClone = additionalAgreementItem.clone()
          additionalAgreementItemClone.appendTo $("#additional-agreements-added")
          additionalAgreementInput.val("")
          $('#agreement-error').hide()
        additionalAgreementInput.trigger "focus"
        return


      # Tutorial Hotspots
      $(document).on("mouseenter", [
        @selectors.builderOverlay
        "a.hotspot"
      ].join(" "), ->
        mainnav = (if $(this).data("mainnav") then $(this).data("mainnav") else false)
        section = (if $(this).data("section") then $(this).data("section") else false)
        self.elements.body.find(mainnav).addClass "highlight"  if mainnav
        self.elements.body.find(section).addClass "highlight"  if section
        return
      ).on "mouseleave", [
        @selectors.builderOverlay
        "a.hotspot"
      ].join(" "), ->
        self.elements.adminMainnav.find("a").removeClass "highlight"
        self.elements.adminSubnav.find("a").removeClass "highlight"
        return

      return

    _toggleDrop: ($el, issueCategorySlug, toggle) ->
      toggle = true  if typeof toggle is "undefined"
      $parentDrop = $el.closest(".ruckus-drop")
      $dropSelected = $parentDrop.find(".ruckus-selected")
      $dropOptions = $parentDrop.find(".ruckus-drop-options")
      customCategoryInput = undefined
      customCategoryHTML = undefined
      if issueCategorySlug
        if $el.hasClass("new-category")

          # get Custom Category Input
          customCategoryInput = $el.find("input[type=\"text\"]")

          # populate .category .color-block with text value
          $el.find(".category .color-block").text customCategoryInput.val()
          customCategoryHTML = $el.find(".category").html()

          # empty the value of the input
          $el.find("input[type=\"text\"]").val ""

          # insert new li before the custom input
          $el.before "<li data-issue-category=\"" + issueCategorySlug + "\" class=\"category\">" + customCategoryHTML + "</li>"
        $dropSelected.find(".category").html $el.find(".category").html()
        $($parentDrop.data("field")).val issueCategorySlug
      $dropOptions.toggle()
      return

    _getElements: ->
      for key of @selectors
        @elements[key] = $(@selectors[key])
      @elements.window = $(window)
      return

    _processChartDates: (data) ->
      self = this
      formattedData = []
      offestInMilliseconds = new Date().getTimezoneOffset() * 60 * 1000
      formattedTimestamp = undefined
      value = undefined
      i = 0

      while i < data.length

        # formattedTimestamp = (data[i][0] * 1000) + offestInMilliseconds;
        formattedTimestamp = (data[i][0] * 1000)
        value = data[i][1]
        formattedData.push [
          formattedTimestamp
          value
        ]
        i++
      formattedData

    _switchToggle: (elem, action) ->
      self = this
      $el = elem
      $checkbox = $el.find("input[type=\"checkbox\"]")
      isTypeRadio = (if $el.find("input[type=\"radio\"]").length then true else false)
      action = (if typeof action isnt "undefined" then action else null)

      # check if radio - if so set $checkbox to radio input
      $checkbox = $el.find("input[type=\"radio\"]")  if isTypeRadio
      return  unless $checkbox.length

      # if is radio remove class 'active' from all check-box parents
      $("input[name=\"" + $checkbox.attr("name") + "\"]").closest(self.selectors.checkBox).removeClass "active"  if isTypeRadio
      if action is "off"
        $el.removeClass "active"
      else if action is "on"
        $el.addClass "active"
      else
        $el.toggleClass "active"
      if $el.hasClass("active")
        $checkbox.prop "checked", true
        $checkbox.closest(".check-box").find("input[type=\"hidden\"]").val "1"
      else
        $checkbox.prop "checked", false
        $checkbox.closest(".check-box").find("input[type=\"hidden\"]").val "0"
      return

    _editText: ($el) ->
      return  if $el.hasClass("editing")
      ogText = $el.text()
      inputName = $el.data("update-name")
      $el.data "og-text", ogText
      $el.addClass "editing"
      $el.html "<input type=\"text\" name=\"" + inputName + "\" />"
      $input = $el.find("input[type=\"text\"]")
      $input.select()
      return

    _editTextClose: ($el, text) ->
      return  unless $el.length
      ogText = $el.data("og-text")
      text = (if typeof text isnt "undefined" then text else ogText)
      unless text is ogText
        $input = $el.find("input[type=\"text\"]")
        suffix = $input.data("text-suffix")
        prefix = $input.data("text-prefix")
        suffix = (if $.type(suffix) is "string" then suffix else "")
        prefix = (if $.type(prefix) is "string" then prefix else "")
        text = prefix + text + suffix
        $(document).triggerHandler "ruckus:updateText", [
          $(this)
          $el.data("id")
          text
        ]
      $el.html(text).removeClass "editing"
      return

    _addTexture: ->
      @elements.body.prepend "<div class=\"texture\"></div>"
      return

    _showTutorial: ->
      @elements.builderOverlay.fadeIn 1000
      @elements.adminSubnav.find(".actions").fadeOut 1000
      return

    _hideTutorial: ->
      @elements.builderOverlay.fadeOut 1000
      @elements.adminSubnav.find(".actions").fadeIn 1000
      return

    _checkTutorial: ->
      @_showTutorial()  if window.location.hash is "#help"  if window.location.hash
      return

    _applySortable: ->
      $(@selectors.draggable).sortable
        containment: "parent"
        handle: "i"
        stop: ->
          $el = $(this)
          ids = new Array
          $el.children("li").each ->
            ids.push $(this).data("id")
            return

          $(document).triggerHandler "ruckus:sorted", [
            $(this)
            ids
          ]
          return

      return

    initialize: ->
      self = this
      @_getElements()
      @_applySortable()
      @_bindVendors()
      @_bindEvents()
      @_addTexture()
      @_checkTutorial()
      @_turnOnActiveSwitches()
      return


  # Send to global namespace
  window.RuckusAdmin = RuckusAdmin

  # DOM Ready
  $ ->
    RuckusAdmin.initialize()
    return

  return
) jQuery, window, null, Impress
