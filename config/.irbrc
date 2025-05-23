unless defined?(Reline::ANSI::ANSI_CURSOR_KEY_BINDINGS)
  # source: https://github.com/ruby/irb/issues/330#issuecomment-1132017233
  require 'reline/ansi'
end

if defined?(Reline::ANSI::CAPNAME_KEY_BINDINGS) # make sure you're using an affected version
  # Fix insert, delete, pgup, and pgdown.
  Reline::ANSI::CAPNAME_KEY_BINDINGS.merge!({
    "kich1" => :ed_ignore,
    "kdch1" => :key_delete,
    "kpp" => :ed_ignore,
    "knp" => :ed_ignore
  })

  Reline::ANSI.singleton_class.prepend(
    Module.new do
      def set_default_key_bindings(config)
        # Fix home and end.
        set_default_key_bindings_comprehensive_list(config)
        # Fix iTerm2 insert.
        key = [239, 157, 134]
        func = :ed_ignore
        config.add_default_key_binding_by_keymap(:emacs, key, func)
        config.add_default_key_binding_by_keymap(:vi_insert, key, func)
        config.add_default_key_binding_by_keymap(:vi_command, key, func)
        # The rest of the behavior.
        super
      end
    end
  )
end

def pbcopy(str)
  IO.popen('pbcopy', 'r+') {|io| io.puts str }
end

# for more IRB conf options check https://docs.ruby-lang.org/en/master/IRB.html
# IRB.conf[:USE_AUTOCOMPLETE] = false

IRB.conf[:COMMAND_ALIASES] ||= {}
IRB.conf[:COMMAND_ALIASES][:w] = :whereami
# https://github.com/ruby/irb/issues/992#issuecomment-2343517994
IRB.conf[:COMMAND_ALIASES][:n] = :irb_next
IRB.conf[:COMMAND_ALIASES][:c] = :continue
IRB.conf[:COMMAND_ALIASES][:h] = :help
IRB.conf[:COMMAND_ALIASES][:q] = :exit!
