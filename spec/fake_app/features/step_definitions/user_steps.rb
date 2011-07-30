Given /^the registered user "([^"]*)" with the password "([^"]*)"$/ do |arg1, arg2|
  Factory.create(:user_with_attributes, :username => arg1, :password => arg2, :password_confirmation => arg2)
end

Given /^there is a user called "([^"]*)"$/ do |arg1|
  Factory.create(:user, :username => arg1, :email => "#{arg1.gsub(" ","_")}_mail@#{arg1.gsub(" ","")}sdomain.com")
end
