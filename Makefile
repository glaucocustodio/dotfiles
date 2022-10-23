.PHONY: link_file

# Usage ex: make link_file file=asdfrc
link_file:
	rm ~/.$(file) 2> /dev/null || true
	ln -s ~/Projects/dotfiles/config/$(file) ~/.$(file)

link_nvim_config:
	rm ~/.config/nvim/init.vim
	ln -s ~/Projects/dotfiles/config/nvim/init.vim ~/.config/nvim
