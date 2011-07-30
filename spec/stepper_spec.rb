require 'spec_helper'
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

  it 'should do stuff' do 
    expected = "\n\nStepper Results:\n\nFile: features/login_steps.rb1\tGiven /^I am logged in as \"([^\"]*)\"$/ do |arg1|\n\tUsed in 1 features\tfeatures/sub_feature/user_register.feature:\n\tlines: 12\n5\tGiven /^I am logged in$/ do |arg1|\n\tSTEP NOT USED\n\n9\tGiven /^I am not logged in$/ do\n\tUsed in 1 features\tfeatures/sub_feature/user_register.feature:\n\tlines: 7\n13\tGiven /^(?:|I )am on (.+)$/ do |page_name|\n\tUsed in 3 features\tfeatures/sub_feature/user_register.feature:\n\tlines: 6\tfeatures/login.feature:\n\tlines: 6,12\n17\tWhen /^I sign in as \"([^\"]*)\" with \"([^\"]*)\"$/ do |arg1, arg2|\n\tUsed in 2 features\tfeatures/login.feature:\n\tlines: 7,13\n21\tWhen /^I login as \"([^\"]*)\" with \"([^\"]*)\"$/ do |arg1, arg2|\n\tSTEP NOT USED\n\n25\tThen /^I should be logged in$/ do\n\tUsed in 1 features\tfeatures/login.feature:\n\tlines: 8\n29\tThen /^I should not be logged in$/ do\n\tUsed in 1 features\tfeatures/login.feature:\n\tlines: 14\n\n\nFile: features/user_steps.rb1\tGiven /^the registered user \"([^\"]*)\" with the password \"([^\"]*)\"$/ do |arg1, arg2|\n\tUsed in 2 features\tfeatures/login.feature:\n\tlines: 5,11\n5\tGiven /^there is a user called \"([^\"]*)\"$/ do |arg1|\n\tSTEP NOT USED\n\n"
    
    Stepper.process.should == expected
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
      @finder.steps.size.should == 10
    end
    it 'should have a hash for each step' do 
      @finder.steps.map{|s| s.is_a?(Hash)}.all?.should be_true
    end

    #Just testing the first step, assuming others ok.
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

    it 'should have added a features key to steps which are used by features' do 
      step = @finder.steps[0]
      step[:features].size.should == 1
      step[:features].first[:file].should == "features/sub_feature/user_register.feature"
    end

    it 'should not have a features key on steps which are not used' do 
      step = @finder.steps[1]
      step[:line].should == "Given /^I am logged in$/ do |arg1|\n"
      step[:features].should be_nil
    end

    it 'should match step_definitions which are refered to with And' do 
      step = @finder.steps[2]
      step[:line].should == "Given /^I am not logged in$/ do\n"
      step[:features][0][:file].should == "features/sub_feature/user_register.feature"
      step[:features][0][:line].should == "And I am not logged in\n"      
    end

  end

end
