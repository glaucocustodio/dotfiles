.PHONY: link_file

# Usage ex: make link_file file=asdfrc
link_file:
	ln -s ~/dotfiles/config/$(file) ~/.$(file)
