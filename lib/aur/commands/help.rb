# frozen_string_literal: true

module Aur
  module Command
    #
    # Call the static #help method built into all the command classes
    #
    class Help
      def initialize(command)
        require_relative command
        puts "\n" + command_class(command).help + "\n"
      end

      def command_class(command)
        Object.const_get("Aur::Command::#{command.capitalize}")
      end
    end
  end
end
