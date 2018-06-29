class Profile::DummyDestroysController < Profile::BaseController
  inherit_resources

  def destroy
    render json: { detroyed: true  }
  end

end
