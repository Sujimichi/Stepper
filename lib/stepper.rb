module Stepper
  def self.process args = []
    finder = StepFinder.new(args)
    finder.read_steps
    result = finder.handle_args
    puts result
    result
  end
end
