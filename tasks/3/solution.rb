class Option
    attr_reader :short_name, :full_name, :description, :parameter
    def initialize(short_name, full_name, description, parameter = nil)
        @short_name = short_name
        @full_name = full_name
        @description = description
        @parameter = parameter
    end
    def is?(name)
        @short_name == name || @full_name == name
    end
    def to_s
        parameter_string = @parameter.nil? ? '' : "=#{@parameter}"
        "\n    -#{@short_name}, --#{@full_name}#{parameter_string} #{@description}"
    end
end
class StringExtractor
    def extract_option_names(argv)
        tuples = options_parameters(argv)
        tuples.map { |option, _| option.tr('-', '') }
    end
    def option?(string)
        string.include?('-')
    end
    def argument?(string)
        !string.nil? && !option?(string)
    end
    def option_with_parameter?(string)
        short_option_with_parameter?(string) || long_option_with_parameter?(string)
    end
    def short_option_with_parameter?(string)
        string.length > 2 && string[1] != '-'
    end
    def long_option_with_parameter?(string)
        string.include?('=')
    end
    def extract_arguments(argv)
        argv.select { |string| argument?(string) }
    end
    def extract_options(argv)
        argv.select { |string| option?(string) }
    end
    def extract_parameters(argv)
        with_parameters = argv.select { |string| option_with_parameter?(string) }
        with_parameters.map { |option| extract_parameter(option) }
    end
    def extract_parameter(string)
        option_parameter(string).last
    end
    def options_parameters(argv)
        options = extract_options(argv)
        options.map { |option| option_parameter(option) }
    end
    def option_parameter(string)
        option = string
        option = string[0..1] if short_option_with_parameter?(string)
        option = string.split('=').first if long_option_with_parameter?(string)
        parameter = nil
        parameter = string[2..-1] if short_option_with_parameter?(string)
        parameter = string.split('=').last if long_option_with_parameter?(string)
        [option, parameter]
    end
end
class CommandParser < StringExtractor
    def initialize(command_name)
        @command_name = command_name
        @arguments = []
        @options = []
        @parameters = []
        @blocks = {}
    end
    def argument(argument_name, &block)
        @arguments << argument_name
        @blocks[argument_name] = block
    end
    
    def option(short_name, full_name, description, &block)
        self.option_with_parameter(short_name, full_name, description, nil, &block)
    end
    def option_with_parameter(name, full_name, description, parameter, &block)
        option_entry = Option.new(name, full_name, description, parameter)
        @options << option_entry
        @parameters << parameter unless parameter.nil?
        @blocks[option_entry] = block
    end
    def parse(command_runner, argv)
        parse_arguments(argv, command_runner)
        parse_options(argv, command_runner)
        parse_parameters(argv, command_runner)
    end
    def help
        "Usage: #{@command_name} #{arguments_string}#{options_string}"
    end
    private
    def arguments_string
        @arguments.map { |argument| "[#{argument}]" }.join(' ')
    end
    def options_string
        @options.map { |option| option.to_s }.join('')
    end
    def parse_arguments(argv, command_runner)
        input_arguments = extract_arguments(argv)
        return if input_arguments.empty?
        tuples = @arguments.zip(input_arguments)
        tuples.each { |first, second| @blocks[first].call command_runner, second }
    end
    def parse_options(argv, command_runner)
        option_names = extract_option_names(argv)
        return if option_names.empty?
        options = option_names.map { |name| get_option_with_name(name) }.compact
        options.each { |option| @blocks[option].call command_runner, true }
    end
    
    def parse_parameters(argv, command_runner)
        parameters = extract_parameters(argv)
        return if parameters.empty?
        
        tuples = extract_option_names(argv).zip(parameters)
        tuples.each do |option_name, parameter|
            option = get_option_with_name(option_name)
            @blocks[option].call command_runner, parameter
        end
    end
    
    def get_option_with_name(name)
        selected = @options.select { |option| option.is?(name) }
        selected.first
    end
end
