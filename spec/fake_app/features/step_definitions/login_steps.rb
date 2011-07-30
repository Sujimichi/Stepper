Given /^I am logged in as "([^"]*)"$/ do |arg1|
  login(arg1, "foobar")
end

Given /^I am logged in$/ do |arg1|
  login(rand_name, "foobar")
end

Given /^I am not logged in$/ do
  given_logged_out
end

Given /^(?:|I )am on (.+)$/ do |page_name|
  visit path_to(page_name)
end

When /^I sign in as "([^"]*)" with "([^"]*)"$/ do |arg1, arg2|
  login(arg1,arg2)
end

When /^I login as "([^"]*)" with "([^"]*)"$/ do |arg1, arg2|
  login(arg1,arg2)
end

Then /^I should be logged in$/ do
  #stuff
end

Then /^I should not be logged in$/ do
  #stuff
end

 
def login username, p_word
  #login_suff
end

def register_and_login username, org_name = nil
  #reg_and_login_stuff
end

def set_up_current_user username, p_word = nil, org_name = nil
  #stuff
end

def given_logged_out
end


def sign_in(username, p_word)
  visit('/')
  within(".login_form") do
    fill_in 'user_session_username', :with => username
    fill_in 'user_session_password', :with => p_word
  end
  click_button 'Login'
end
