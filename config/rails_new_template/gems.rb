def install_gems(options)
  gem "haml-rails" unless options["api"]
  gem "dotenv"
  gem "faraday"

  gem_group :development, :test do
    gem "amazing_print"
    gem "faker"
    gem "factory_bot_rails"
    gem "pry-byebug"
    gem "rspec-rails"
    gem "standard"
    gem "standard-rails"
    gem "stub_env"
    gem "webmock"
  end
end
