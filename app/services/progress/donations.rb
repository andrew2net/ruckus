class Progress::Donations < Progress::WithOneItem
  def completed?
    @profile.donations_on? && @profile.de_account.present?
  end
end
