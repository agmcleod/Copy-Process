if User.find_by_email('dacgroupdigital@gmail.com').nil?
  User.create!(email: 'dacgroupdigital@gmail.com', password: '8JxD4yXTPoFUfF', password_confirmation: '8JxD4yXTPoFUfF')
end