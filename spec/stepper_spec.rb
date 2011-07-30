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
    puts Stepper.process
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


describe StepFinder do 
  before(:all) do 
    Dir.chdir("spec/fake_app")    
  end
  before(:each) do   
    @finder = StepFinder.new
  end

  it 'should list all step definition files'do 
    @finder.step_files.should be_a(Array)
    @finder.step_files.size.should == 2
    @finder.step_files.should == ["features/step_definitions/login_steps.rb", "features/step_definitions/user_steps.rb"]
  end 

  describe "read steps" do 
    before(:each) do 
      @finder.read_steps
    end
    it 'should have an array of steps with an entry for each step definition in the fake_app' do 
      @finder.steps.should be_a(Array)
      @finder.steps.size.should == 11
    end
    it 'should have a hash for each step' do 
      @finder.steps.map{|s| s.is_a?(Hash)}.all?.should be_true
    end

    it 'should have found the file and line number for each step' do 
      @finder.steps[0..7].map{|s| s[:file]}.uniq.should == ["features/step_definitions/login_steps.rb"]   #First 8 steps from one file
      @finder.steps[8..10].map{|s| s[:file]}.uniq.should == ["features/step_definitions/user_steps.rb"]   #Other 3 in a different file
      @finder.steps.map{|step| step[:line_number]  }.should == [1, 5, 9, 13, 17, 21, 25, 29, 1, 5, 9]
    end

    it "should have the correct 'type' for each step" do 
      @finder.steps.map{|step| step[:type]  }.should == ["Given", "Given", "Given", "Given", "When", "When", "Then", "Then", "Given", "Given", "Given"]
    end

    it 'should have a regexp for each step that will match the same strings as the step definition' do 
      test_strings = [
        ["I am logged in as \"Tim\"", "I am logged in as \"another name\""],
        "I am logged in",
        "I am not logged in",
        ["I am on the front page", "I am on the users page", "I am on the moon"],
        "I sign in as \"mr chips\" with \"boguspassword\"",
        "I login as \"mr chips\" with \"boguspassword\"",
        "I should be logged in",
        "I should not be logged in",
        "the registered user \"bob\" with the password \"whatever\"",
        "there is a user called \"moe\""        
      ]

      test_strings.each_with_index{|s, i| 
        if s.is_a?(Array)
          s.each{|sub_s| 
            @finder.steps[i][:regexp].match(sub_s).should_not be_nil  
          }
        else
          @finder.steps[i][:regexp].match(s).should_not be_nil  
        end
      }
    end

    #Could do this for each example step but I think the above test covers it ok.
    it 'should create a regexp that behavies as the step definition would' do 
      step = @finder.steps.first
      step[:line].should == "Given /^I am logged in as \"([^\"]*)\"$/ do |arg1|\n"
      step[:regexp].should  == /^I am logged in as "([^"]*)"$/
      step[:regexp].match("I am logged in as \"tim\"").should_not be_nil
      step[:regexp].match("I am beaten up by \"tim\"").should be_nil
    end
  end

  describe "compaire steps with features" do 
    before(:each) do 
      @finder.read_steps
      @finder.read_and_compaire_features
    end

    it 'should have found the correct number of features for each step' do 
      @finder.steps.map{|step| (step[:features] || []).size }.should == [1, 0, 1, 3, 2, 0, 1, 1, 2, 0, 0]
    end

    it 'should match step_definitions which are refered to with And' do 
      step = @finder.steps[2]
      step[:line].should == "Given /^I am not logged in$/ do\n"
      step[:features][0][:file].should == "features/sub_feature/user_register.feature"
      step[:features][0][:line].should == "And I am not logged in\n"      
    end


  end

  describe "determine type" do 
  
    it 'should match Given lines' do 
      @finder.determine_line_type("Given I am somthing").should == "Given"
      @finder.determine_line_type(" Given I am somthing").should be_nil
      @finder.determine_line_type("I am Given somthing").should be_nil
    end
    it 'should match When lines' do 
      @finder.determine_line_type("When I am late").should == "When"
      @finder.determine_line_type(" When I am late").should be_nil
      @finder.determine_line_type("I am late When").should be_nil
    end
    it 'should match Then lines' do 
      @finder.determine_line_type("Then I am").should == "Then"
      @finder.determine_line_type(" Then I am").should be_nil
      @finder.determine_line_type("I am Then").should be_nil
    end
    it 'should match And lines' do 
      @finder.determine_line_type("And I am").should == "And"
      @finder.determine_line_type(" And I am").should be_nil
      @finder.determine_line_type("I am And").should be_nil
    end
  end

  describe "find_step_which_matches" do 
    before(:each) do 
      @finder.read_steps
    end

    it 'should find a step that matches a plain feature line' do 
      line = "Given I am logged in"
      step, type = @finder.find_step_which_matches line
      step[:line].should == "Given /^I am logged in$/ do |arg1|\n"
      type.should == "Given"
    end

    it 'should find a step that matches a feature line with an argument' do 
      line = "Given I am logged in as \"you\""
      step, type = @finder.find_step_which_matches line
      step[:line].should == "Given /^I am logged in as \"([^\"]*)\"$/ do |arg1|\n"
      type.should == "Given"
    end

    it 'should find a step that matches a feature line with multiple arguments' do 
      line = "When I sign in as \"some dude\" with \"apassword\""
      step, type = @finder.find_step_which_matches line
      step[:line].should == "When /^I sign in as \"([^\"]*)\" with \"([^\"]*)\"$/ do |arg1, arg2|\n"
      type.should == "When"
    end

    it 'should find a step when it is reference with And' do 
      line = "And I sign in as \"some dude\" with \"apassword\""
      step, type = @finder.find_step_which_matches line
      step[:line].should == "When /^I sign in as \"([^\"]*)\" with \"([^\"]*)\"$/ do |arg1, arg2|\n"
      type.should == "And" #type is of the line given, not of the matching step.
    end


  end


end

class Expected

  def self.results_for_unused_steps
<<EOF
\n\nStepper Results for Unused Steps:\n
File: features/login_steps.rb
5\tGiven /^I am logged in$/ do |arg1|
21\tWhen /^I login as "([^"]*)" with "([^"]*)"$/ do |arg1, arg2|

File: features/user_steps.rb
5\tGiven /^there is a user called "([^"]*)"$/ do |arg1|
9\tGiven /^there is a registered user/ do 
EOF
  end

  def self.specific_resutls_for_given_the_registered_user
<<EOF
\n\nStepper Results for Specific Step:\n
File: features/user_steps.rb
1\tGiven /^the registered user "([^"]*)" with the password "([^"]*)"$/ do |arg1, arg2|	Used in 2 features
\tfeatures/login.feature:
\tlines: 5,11
EOF
  end

  def self.summary_output
<<EOF
\n\nStepper Results:

File: features/login_steps.rb
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


File: features/user_steps.rb
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
