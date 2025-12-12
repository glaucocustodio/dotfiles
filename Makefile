force_update:
	stow config --override='.zshrc' --verbose=2

update:
	stow config --verbose=2

remove:
	stow -D config --verbose=2
