# coding: utf-8

# User.create!(name: "Sample User",
#              email: "sample@email.com",
#              password: "password",
#              password_confirmation: "password",
#              admin: true)

# 60.times do |n|
#   name  = Faker::Name.name
#   email = "sample-#{n+1}@email.com"
#   password = "password"
#   User.create!(name: name,
#                email: email,
#                password: password,
#                password_confirmation: password)
# end



User.create!(name: "Sample User",
  email: "sample@email.com",
  password: "password",
  password_confirmation: "password",
  admin: true)

User.create!(name: "SuperiorA ",
   email:"superior-a@email.com",
   password: "password",
   password_confirmation: "password",
   superior: true)

User.create!(name: "SuperiorB ",
   email:"superior-b@email.com",
   password: "password",
   password_confirmation: "password",
   superior: true)

60.times do |n|
name  = Faker::Name.name
email = "sample-#{n+1}@email.com"
password = "password"
User.create!(name: name,
    email: email,
    password: password,
    password_confirmation: password)
end

# MonthlyRequest.create!(requester_id:1,
#                         requested_id:2,
#                         request_month: "2020-10-01",
#                         state:2)

# MonthlyRequest.create!(requester_id:1,
#                         requested_id:2,
#                         request_month: "2020-09-01",
#                         state:2)

# MonthlyRequest.create!(requester_id:1,
#                         requested_id:3,
#                         request_month: "2020-10-01",
#                         state:2)