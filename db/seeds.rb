if User.find_by_email('dacgroupdigital@gmail.com').nil?
  User.create!(:email => 'dacgroupdigital@gmail.com', :password => 'dacgroup2012', :password_confirmation => 'dacgroup2012')
end