class Profile::MyAccountsController < Profile::BaseController
  inherit_resources
  include ProfileableController
end
