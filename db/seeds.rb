# coding: utf-8

User.create!(name: "Sample User",
  email: "sample@email.com",
  employee_number: "1",
  uid:"admin-1",
  password: "password",
  password_confirmation: "password",
  admin: true)

User.create!(name: "SuperiorA ",
   email:"superior-a@email.com",
   employee_number: "2",
   uid:"sperior-1",
   password: "password",
   password_confirmation: "password",
   superior: true)

User.create!(name: "SuperiorB ",
   email:"superior-b@email.com",
   employee_number: "3",
   uid:"sperior-2",
   password: "password",
   password_confirmation: "password",
   superior: true)

60.times do |n|
   name  = Faker::Name.name
   email = "sample-#{n+1}@email.com"
   employee_number = "#{n+4}"
   uid = "user-#{n+1}"
   password = "password"
   User.create!(name: name,
                email: email,
                employee_number: employee_number,
                uid: uid,
                password: password,
                password_confirmation: password)
 end