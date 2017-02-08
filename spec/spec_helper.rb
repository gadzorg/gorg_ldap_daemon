
require "bundler/setup"
require "simplecov"
SimpleCov.start
APP_PATH = File.expand_path('../../config/boot', __FILE__)

require APP_PATH


ENV["RAKE_ENV"]="test"

RSpec.configure do |config|
  config.mock_with :rspec do |mocks|

    # This option should be set when all dependencies are being loaded
    # before a spec run, as is the case in a typical spec helper. It will
    # cause any verifying double instantiation for a class that does not
    # exist to raise, protecting against incorrectly spelt names.
    mocks.verify_doubled_constant_names = true

  end
end