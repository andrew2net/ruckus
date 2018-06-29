class BioFeatured::Cell < BaseCell
  self_contained!

  def show
    render
  end

  def render_hero_unit_block
    render_hero_or_hero_placeholder if show_hero_unit?
  end

  def render_bio_block
    render_bio_or_bio_placeholder if show_biography?
  end

  def render_hero_or_hero_placeholder
    if show_hero_unit_placeholder?
      render partial: 'hero_unit_placeholder'
    else
      render partial: 'hero_unit', locals: { hero_medium: profile.hero_unit_medium }
    end
  end

  def render_bio_or_bio_placeholder
    if show_biography_placeholder?
      render partial: 'bio_placeholder'
    else
      render partial: 'bio'
    end
  end

  def render_bio_pencil
    render partial: 'biography_pencil' if show_navigation?
  end

  def render_bio_switch
    render partial: 'biography_switch' if show_biography_switch?
  end

  def render_hero_unit_switch
    render partial: 'hero_unit_switch' if show_hero_unit_switch?
  end

  def show_biography?
    show_navigation? || (profile.biography_on? && profile.biography.present?)
  end

  def show_hero_unit?
    show_navigation? || (profile.hero_unit_on? && profile.hero_unit_medium.present?)
  end

  def show_biography_placeholder?
    profile.biography.blank? && show_navigation?
  end

  def show_biography_switch?
    profile.biography.present? && show_navigation?
  end

  def show_hero_unit_switch?
    profile.hero_unit_medium.present? && show_navigation?
  end

  def show_hero_unit_placeholder?
    profile.hero_unit_medium.blank? && show_navigation?
  end

  def biography_classes
    "section-editable tab-wrapper #{show_hero_unit? ? 'col-sm-5 col-sm-pull-6' : 'col-sm-12'}"
  end

  def hero_unit_classes
    "section-editable #{show_biography? ? 'col-sm-6 col-sm-push-6' : 'col-sm-8 col-sm-offset-2'}"
  end
end
