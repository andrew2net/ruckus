$ ->
  RuckusAccount.updateIssues = (elem) ->
    self = RuckusAccount
    elemParentLi = elem.closest('li')
    url = elem.attr('href')

    unless elemParentLi.hasClass('active')
      self.issuesLoading = true
      self.elements.issuesSlideWrapper.find('.slide-fade-wrapper').removeClass('fade-in')
      $.get(url, (data) -> 
        self.elements.issuesSlideWrapper.find('.slide-fade-wrapper').remove()
        self.elements.issuesSlideWrapper.append(data)
        self.issuesSliderEvents()
      ).fail( -> 
        self.elements.issuesSlideWrapper.find('.slide-fade-wrapper').addClass('fade-in')
      ).always( -> 
        self.issuesLoading = false
      )