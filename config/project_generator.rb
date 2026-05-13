# Usage:
# ruby project_generator.rb create my_project

require "thor"
require "fileutils"

class ProjectGenerator < Thor
  include Thor::Actions

  desc "create NAME", "Create a Ruby project with Bundler and RSpec"

  def create(name)
    say "Creating project: #{name}", :green

    FileUtils.mkdir_p("#{name}/spec")

    inside(name) do
      create_gemfile
      create_dotenv_file
      create_gitignore
      create_readme(name)

      run "bundle install"
      run "bundle exec rspec --init"

      create_structure

      run "git init"
      run "git add ."
      run 'git commit -m "Initial commit"'
    end

    say "\nProject #{name} created successfully!", :green
  end

  private

  def create_gemfile
    create_file "Gemfile", <<~RUBY
      source "https://rubygems.org"

      gem "dotenv"
      gem "faraday"
      gem "zeitwerk"

      group :development, :test do
        gem "amazing_print"
        gem "pry-byebug"
        gem "faker"
      end

      group :test do
        gem "rspec"
        gem "factory_bot"
        gem "stub_env"
        gem "webmock"
      end
    RUBY
  end

  def create_dotenv_file
    create_file ".env", <<~CONTENT
    CONTENT
  end

  def create_gitignore
    create_file ".gitignore", <<~CONTENT
      .env
      .DS_Store
      .byebug_history
      .tags*
      tmux-*.log
    CONTENT
  end

  def create_readme(project_name)
    create_file "README.md", <<~MARKDOWN
      # #{project_name.upcase}

      ## Setup
      ```shell
      cd #{project_name}
      bundle
      ```

      ## Running
      ```shell
      ruby boot.rb
      ```

      ## Tests
      ```shell
      bundle exec rspec
      ```
    MARKDOWN
  end

  def create_structure
    create_file "boot.rb", <<~RUBY
      require "dotenv/load"

      require "bundler/setup"
      Bundler.require(:default, :development)

      loader = Zeitwerk::Loader.new
      loader.push_dir("app")
      loader.setup
    RUBY

    create_file "app/main.rb", <<~RUBY
      class Main
        def add(a, b)
          a + b
        end
      end
    RUBY

    create_file "app/request.rb", <<~RUBY
      class Request
        class << self
          private

          def connection
            @_connection ||= Faraday.new(url: base_url) do |builder|
              builder.request :json
              builder.response :json
              builder.response :logger, nil, {headers: false, bodies: true, errors: true}
              builder.adapter Faraday.default_adapter
            end
          end

          def base_url
            raise NotImplementedError
          end
        end
      end
    RUBY

    prepend_to_file "spec/spec_helper.rb", <<~RUBY
      require_relative "../boot"

    RUBY

    create_file "spec/app/main_spec.rb", <<~RUBY
      RSpec.describe Main do
        describe "#add" do
          it "adds even numbers" do
            expect(subject.add(2, 4)).to eq(6)
          end

          it "adds odd numbers" do
            expect(subject.add(1, 3)).to eq(4)
          end
        end
      end
    RUBY
  end
end

ProjectGenerator.start(ARGV)
