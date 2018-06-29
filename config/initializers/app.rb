def wingop?
  Figaro.env.app == 'wingop'
end

def ruckus?
  !wingop?
end

def app_name
  ruckus? ? 'Ruck.us' : 'Win.GOP'
end
