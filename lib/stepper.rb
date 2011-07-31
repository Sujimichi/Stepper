require 'stepper/step_finder.rb'
module Stepper
  def self.process args = []
    finder = StepFinder.new(args)
    finder.read_steps
    finder.handle_args
  end

end
