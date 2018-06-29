$ ->
  'use strict'
  jcrop_api = undefined
  boundx = undefined
  boundy = undefined
  coordinates = undefined
  loadingImage = undefined
  aspectRatio = undefined
  $imagePreview = $('.preview')
  xsize = 132
  ysize = 132
  updatePreview = (coords) ->
    if parseInt(coords.w) > 0
      rx = xsize / coords.w
      ry = ysize / coords.h

      $('.preview-container img').css
        width: Math.round(rx * boundx) + 'px'
        height: Math.round(ry * boundy) + 'px'
        marginLeft: '-' + Math.round(rx * coords.x) + 'px'
        marginTop: '-' + Math.round(ry * coords.y) + 'px'

  setCreatedImageAspectRatio = (image) ->
    realImageWidth = document.getElementById(image.attr('id')).naturalWidth
    aspectRatio = realImageWidth / image.width()
  setUploadedImageAspectRatio = (image) ->
    aspectRatio = loadingImage.width / image.width()
  updateSubmittedCoords = (coordinates) ->
    if aspectRatio and coordinates
      $('input.crop-width').val coordinates.w * aspectRatio
      $('input.crop-height').val coordinates.h * aspectRatio
      $('input.crop-x').val coordinates.x * aspectRatio
      $('input.crop-y').val coordinates.y * aspectRatio
  cropSelectedImage = ->
    $('#newly_selected_image').load ->
      image = $(this)
      setCreatedImageAspectRatio image
      cropImage image

  cropUploadedImage = ->
    image = $('.result').find('canvas')
    setUploadedImageAspectRatio image
    cropImage image
    return
  cropImage = (image) ->
    type = $('.photo-crop-wrapper').attr 'type'
    ratio = undefined
    ratio = 1 if type is 'photo'
    ratio = 2.8 if type is 'background'
    ratio = 1 if type is 'featured_unit'
    ratio = 0 if type is 'media_stream'

    image.Jcrop
      aspectRatio: ratio
      minSize: [
        132
        132
      ]
      setSelect: [
        40
        40
        image.width() - 40
        image.height() - 40
      ]
      onChange: updatePreview if type is 'photo'
      onSelect: (coords) ->
        coordinates = coords
        updatePreview(coordinates) if type is 'photo'
        updateSubmittedCoords coordinates

      onRelease: ->
        coordinates = null
    , ->
      boundx = @getBounds()[0]
      boundy = @getBounds()[1]
      jcrop_api = this
      $imagePreview.appendTo jcrop_api.ui.holder
      updatePreview(coordinates) if type is 'photo'

  showUploadedImage = (e) ->
    formId = $(e.target).closest('form').attr('id')
    $('.button-crop').data 'formId', formId
    if e.target.files[0]
      reader = new FileReader()
      reader.onload = (e) ->
        $('.preview-container img').attr 'src', e.target.result
      reader.readAsDataURL e.target.files[0]

    loadingImage = loadImage(e.target.files[0], (img) ->
      $('.result').html('').append img
      $('.button-crop').text 'Done'
      $('#media-upload-form, #media-profile-form').hide()
      $('.photo-crop-wrapper, .photo-crop, .profile-upload, .button-crop').show()
      $('.fileupload-wrapper').not('.fileupload-step').hide()
      $('.fileupload-wrapper').removeClass('invalid').find('.validation-error').hide()
      cropUploadedImage()
    ,
      minWidth: 132
      minHeight: 132
      maxWidth: 400
      maxHeight: 400
      canvas: true
    )
    # TODO: Throw error message
    false
  showImageToCrop = (e) ->
    e.preventDefault()
    $form = $(e.target).closest('form')
    formId = $form.attr('id')
    $selectedImage = $form.find('.check-box.active')
    imagePath = $selectedImage.closest('li').find('img').attr('src')
    fullSizeImagePath = imagePath.replace('thumb_', '')
    $('.button-crop').data 'formId', formId
    $('.preview-container img').attr 'src', fullSizeImagePath
    image = new Image()
    image.src = fullSizeImagePath
    image.id = 'newly_selected_image'
    $('.result').html('').append image
    $('.button-crop').text 'Done'
    $('#media-upload-form, #media-profile-form').hide()
    $('.photo-crop-wrapper, .photo-crop, .profile-upload, .button-crop').show()
    cropSelectedImage()

  submitCropForm = (e) ->
    updateSubmittedCoords()
    formId = $(e.target).data('formId')
    $('.button-crop').text $('.button-crop').data('disable-with')
    $('.button-cancel, .button-reset').addClass('disabled')
    $('#' + formId).submit()

  resetCropForm = (e) ->
    unless $(@).hasClass('disabled')
      e.preventDefault()
      jcrop_api.release()
      cropUploadedImage()

  destroyCropForm = (e) ->
    unless $(@).hasClass('disabled')
      e.preventDefault()
      jcrop_api.destroy()
      $('.reset-form').trigger('click')
      $('.photo-crop-wrapper').hide()
      $('#media-upload-form').show()
      $('#media-profile-form').show()
      $('.fileupload-wrapper').show()
      $('.media-upload').show()
      $('.check-box').removeClass('active')
      $('.check-box').find('input').removeAttr('checked')
      $('.actually_active').addClass('active')



  $(document).on 'change', '.upload-profile-pic', showUploadedImage
  $(document).on 'click', '.button-photo-selected', showImageToCrop
  $(document).on 'click', '.button-crop', submitCropForm
  $(document).on 'click', '.button-reset', resetCropForm
  $(document).on 'click', '.button-cancel', destroyCropForm
