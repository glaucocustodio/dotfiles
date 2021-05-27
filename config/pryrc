# .pryrc inspiration: https://gist.github.com/justin808/1fe1dfbecc00a18e7f2a

# Using these pry gems -- copy to your Gemfile
# group :development, :test do
#   gem 'amazing_print' # pretty print ruby objects
#   gem 'pry-byebug' # Integrates pry with byebug
#   gem 'pry-doc' # Provide MRI Core documentation
#   gem 'pry-rails' # Causes rails console to open pry. `DISABLE_PRY_RAILS=1 rails c` can still open with IRB
#   gem 'pry-rescue' # Start a pry session whenever something goes wrong.
# end

Pry.config.editor = 'subl'

# == Pry-Nav ==
Pry.config.commands.alias_command 'c', 'continue' rescue nil
Pry.config.commands.alias_command 's', 'step' rescue nil
Pry.config.commands.alias_command '?', 'show-source -d' rescue nil
Pry.config.commands.alias_command 'n', 'next' rescue nil
Pry.config.commands.alias_command 'q', 'quit' rescue nil
Pry.config.commands.alias_command 'a', 'abort' rescue nil
Pry.config.commands.alias_command 'w', 'whereami' rescue nil

if defined?(PryByebug)
  Pry.commands.alias_command 'c', 'continue'
  Pry.commands.alias_command '?', 'show-source -d'
  Pry.commands.alias_command 's', 'step'
  Pry.commands.alias_command 'n', 'next'
  Pry.commands.alias_command 'w', 'whereami'
  Pry.commands.alias_command 'q', 'quit'
end

# https://gist.github.com/hotchpotch/1978295
def pbcopy(str)
  IO.popen('pbcopy', 'r+') {|io| io.puts str }
end

Pry.config.commands.command "copy", "Copy to clipboard" do |str|
  unless str
    str = "#{_pry_.input_array[-1]}#=> #{_pry_.last_result}\n"
  end
  pbcopy str
end

Pry.config.commands.command "lastcopy", "Last result copy to clipboard" do
  pbcopy pry_instance.last_result.to_s.chomp
end

if defined?(Rails)
  # only Rails 6+ has `module_parent_name`
  parent_name = Rails.application.class.try(:module_parent_name) || Rails.application.class.parent_name
  Pry.config.prompt_name = parent_name.underscore.dasherize
end

puts %{
  $             : show whole method of current context
  $ Model.create: show definition of #create method
  ? Model.create: show doc of #create method
  edit -c       : edit current line (need to save and close the file in editor to return)
  _             : return last output


}
