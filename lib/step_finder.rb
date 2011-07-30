class StepFinder
  attr_accessor :step_files, :steps, :features

  def initialize args= []
    @args = args
    @feature_files = Dir['features/**/*.feature']    
    @step_files =    Dir['features/**/*.rb']    
  end

  def handle_args
    @output = ""
    if @args[0].eql?("--find")
      find_step_in_file 
    else
      read_and_compaire_features
      @output << present_data   
    end
    @output
  end

  def find_step_in_file
    line = @args[1]
    while line.match(/^\s/)  ##remove whitespace at start of line
      line = line.sub(/^\s/,"")  
    end
    step, type = find_step_which_matches(line) #find the step which would be triggered by the given line
    if step.nil?
      @output << "not found"
    else
      @output << "found:\t#{step[:line]}"
      @output << "line:\t#{step[:line_number]} in #{step[:file].sub("step_definitions/", "")}"
    end
  end

  #returns Given When Then or And if the given line starts with either of those strings
  def determine_line_type line
    return "Given" if line.match(/^Given/)
    return "When" if line.match(/^When/)
    return "Then" if line.match(/^Then/)
    return "And" if line.match(/^And/)
    return nil
  end

  #Find the step in Step which has the regexp that will match the given line.
  def find_step_which_matches line
    type = determine_line_type(line)  #Determin type Given When Then or And
    steps = @steps.select{|s| s[:regexp].match(line.gsub("#{type} ","").chomp) } #Find the step which match the feature line
    raise "more than one match found" if steps.size >= 2
    return [steps.first, type] 
  end

  #parse @step_files for lines with Given When and Then at the start and create an entry in @steps.
  #each entry inclues a regexp that will function as the regexp defined by the step as will as file and linenuber info.
  def read_steps
    @steps = []
    @step_files.each do |file|
      lines = File.open(file, "r"){|f| f.readlines}     #for each step_definition file, read the lines
      lines.each_with_index do |line, index|            #for each line
        next unless line.match(/^Given|^When|^Then/)    #Only interested in lines defining steps
        type = determine_line_type(line)                #Get the type (Given, When Then) of the step
        l = line.split(" do")[0].gsub(/^#{type} /,"")   #ignore everything after and including ' do' and remove Given, When or Then from start
        l = l.sub("/","").reverse.sub("/","").reverse   #remove / from begining and end of string so it will convert to regexp correctly
        r_exp = Regexp.new(l)                           #create the regexp that will match lines in features
        @steps << {:file => file, :line_number => index + 1, :line => line, :regexp => r_exp, :type => type} #add step info to @steps
      end
    end
  end

  #Parse each .feature file and for the lines with Given When Then or And, find the step which matches that line. 
  #Each feature that matches a step is added to that steps' :features array.  So later a step can display the features which use it.
  def read_and_compaire_features
    @unmatched_features = []
    @feature_files.each do |file|
      lines = File.open(file, "r"){|f| f.readlines}
      last_type = ""
      lines.each_with_index do |line, index|  
        line.gsub!("  ","") #remove tab spacing (from line start) - bit iffy :(
        next unless line.match(/^Given|^When|^Then|^And/) 
        step, type = find_step_which_matches line
        last_type = type unless type.eql?("And") #last_type is used to assign meaning to 'And'
        line_inf = {:line => line, :type => last_type, :file => file, :line_number => index + 1} #type is last_type        
        if step.nil?
          @unmatched_features << line_inf
        else
          step[:features] ||= []
          step[:features] << line_inf #Add the line_inf to an array on the step. So each step has many :features.
        end
      end
    end
  end


  def present_data
    output = ""
    note = ":"
    note = " for Unused Steps:" if @args[0].eql?("--notused")
    note = " for Specific Step:" if @args[0].eql?("--useof")
    output << "\n\nStepper Results#{note}"

    if @args[0].eql?("--useof")
      steps = @steps.select{|step| 
        step[:file].include?(@args[1]) && step[:line_number].to_i.eql?(@args[2].to_i)
      }
      if steps.empty?
        step, type = find_step_which_matches @args[1]
        steps = [step]
      end
    else
      steps = @steps
    end

    file_name = ""
    steps.each do |step|
      if @args[0].eql?("--notused")
        next if step[:features] 
      end

      f_name = step[:file].sub("features/step_definitions/", "")
      if file_name != f_name
        file_name = f_name
        output << "\n\nFile: #{file_name}"
      end
      output << "\n#{step[:line_number]}\t#{step[:line]}".chomp
      if step[:features] && !step[:features].empty?
        output << "\tUsed in #{step[:features].size} features"
        ffile = ""
        line_nos = []
        step[:features].each do |f|
          if ffile != f[:file]
            output << "\n\t#{ffile}:\n\tlines: #{line_nos.join(",")}" unless line_nos.empty?
            ffile = f[:file]
            line_nos = []
          end
          line_nos << f[:line_number]
        end
        output << "\n\t#{ffile}:\n\tlines: #{line_nos.join(",")}" unless line_nos.empty?

        output << "\n"
      else
        output << "\n\tSTEP NOT USED\n\n" unless @args[0].eql?("--notused")
      end
    end
    if @args.join.include?("--undefined")
      output << "\n\nUnmatched Features"
      @unmatched_features.each do |f|
        output << "\n#{f[:line].chomp}"
        output << "\n\t#{f[:file]}, #{f[:line_number]}"
      end
    end
    output
  end

end

