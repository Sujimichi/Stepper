require 'spec_helper'

#The behaviour depends on having step definition files and feature files within a feature directory.
#These tests assume the presence and makeup of some step def and feature files in a fake_app dir of the spec folder. 
#The expected output of the tests are based on the contents of the files in spec/fake_app/features

describe Stepper do
  before(:all) do 
    @init_d = Dir.getwd
    Dir.chdir("spec/fake_app")    
  end
  after(:all) do 
    Dir.chdir(@init_d)
  end
  before(:each) do   
    
  end

  #called with no args
  it 'should display info about each step definition' do 
    Stepper.process.should == Expected.summary_output
  end

  #Called with --find and an example usage of a step from a feature file
  #returns the file name and line number for that step definition
  it 'should display the line number and file name where a step definition is defined when given the step as it is used in a feature' do 
    output = Stepper.process ["--find", "Given the registered user \"test_user\" with the password \"foobar\""]
    output.should be_include("features/user_steps.rb")
    output.should be_include("line:\t1")
  end
  #As above only And instead of Given to asert the same step will be found
  it 'should display the line number and file name where a step definition is defined when given the step as it is used in a feature' do 
    output = Stepper.process ["--find", "And the registered user \"test_user\" with the password \"foobar\""]
    output.should be_include("features/user_steps.rb")
    output.should be_include("line:\t1")
  end
  
  #Called with --useof followed by a step_definition file and line number
  #returns a list of the feature steps that call then given step definition.
  it 'should display info for a step definition when given as it is used in a feature' do 
    output = Stepper.process ["--useof", "user_steps", "1"]
    output.should == Expected.specific_resutls_for_given_the_registered_user
  end
  #Called with --useof followed by an example usage of a step from a feature file
  #returns a list of the feature steps that call then given step definition.
  it 'should display info for a step definition when given as it is used in a feature' do 
    output = Stepper.process ["--useof", "Given the registered user \"test_user\" with the password \"foobar\""]
    output.should == Expected.specific_resutls_for_given_the_registered_user
  end


  #called with --notused
  #returns a list of the steps whcih do not get called by the features
  it 'should return a list of all tests that are not used by any feature steps' do 
    output = Stepper.process ["--notused"]
    output.should == Expected.results_for_unused_steps.chomp
  end

end



class Expected

  def self.results_for_unused_steps
<<EOF
\n\nStepper Results for Unused Steps:\n
File: login_steps.rb
5\tGiven /^I am logged in$/ do |arg1|
21\tWhen /^I login as "([^"]*)" with "([^"]*)"$/ do |arg1, arg2|

File: user_steps.rb
5\tGiven /^there is a user called "([^"]*)"$/ do |arg1|
9\tGiven /^there is a registered user/ do 
EOF
  end

  def self.specific_resutls_for_given_the_registered_user
<<EOF
\n\nStepper Results for Specific Step:\n
File: user_steps.rb
1\tGiven /^the registered user "([^"]*)" with the password "([^"]*)"$/ do |arg1, arg2|	Used in 2 features
\tfeatures/login.feature:
\tlines: 5,11
EOF
  end

  def self.summary_output
<<EOF
\n\nStepper Results:

File: login_steps.rb
1	Given /^I am logged in as "([^"]*)"$/ do |arg1|	Used in 1 features
	features/sub_feature/user_register.feature:
	lines: 12

5	Given /^I am logged in$/ do |arg1|
	STEP NOT USED


9	Given /^I am not logged in$/ do	Used in 1 features
	features/sub_feature/user_register.feature:
	lines: 7

13	Given /^(?:|I )am on (.+)$/ do |page_name|	Used in 3 features
	features/sub_feature/user_register.feature:
	lines: 6
	features/login.feature:
	lines: 6,12

17	When /^I sign in as "([^"]*)" with "([^"]*)"$/ do |arg1, arg2|	Used in 2 features
	features/login.feature:
	lines: 7,13

21	When /^I login as "([^"]*)" with "([^"]*)"$/ do |arg1, arg2|
	STEP NOT USED


25	Then /^I should be logged in$/ do	Used in 1 features
	features/login.feature:
	lines: 8

29	Then /^I should not be logged in$/ do	Used in 1 features
	features/login.feature:
	lines: 14


File: user_steps.rb
1	Given /^the registered user "([^"]*)" with the password "([^"]*)"$/ do |arg1, arg2|	Used in 2 features
	features/login.feature:
	lines: 5,11

5	Given /^there is a user called "([^"]*)"$/ do |arg1|
	STEP NOT USED


9	Given /^there is a registered user/ do 
	STEP NOT USED

EOF
  end
end
