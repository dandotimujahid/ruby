require_relative '../spec_helper'

require 'rubygems'
require 'rubygems/command_manager'

describe "CVE-2019-8325 is resisted by" do
  describe "sanitising error message components" do
    silent_ui = Module.new do
      attr_accessor :ui
      def self.extended(obj)
        obj.ui = Gem::SilentUI.new
      end
    end

    it "for the 'while executing' message" do
      manager = Gem::CommandManager.new
      manager.extend(silent_ui)
      def manager.process_args(args, build_args)
        raise StandardError, "\e]2;nyan\a"
      end
      def manager.terminate_interaction(n)
      end
      manager.should_receive(:alert_error).with("While executing gem ... (StandardError)\n    .]2;nyan.")
      manager.run nil, nil
    end

    it "for the 'invalid option' message" do
      manager = Gem::CommandManager.new
      def manager.terminate_interaction(n)
      end
      manager.should_receive(:alert_error).with("Invalid option: --.]2;nyan.. See 'gem --help'.")
      manager.process_args ["--\e]2;nyan\a"], nil
    end

    it "for the 'loading command' message" do
      manager = Gem::CommandManager.new
      manager.extend(silent_ui)
      def manager.require(x)
        raise 'foo'
      end
      manager.should_receive(:alert_error).with("Loading command: .]2;nyan. (RuntimeError)\n\tfoo")
      manager.send :load_and_instantiate, "\e]2;nyan\a"
    end
  end
end
