# Install command-line tools using Homebrew
# Usage: `brew bundle Brewfile`

# Make sure we’re using the latest Homebrew
update

# Upgrade any already-installed formulae
upgrade

# Install GNU core utilities (those that come with OS X are outdated)
# Don’t forget to add `$(brew --prefix coreutils)/libexec/gnubin` to `$PATH`.
install coreutils

install moreutils
install findutils
install gnu-sed --default-names
install bash
install bash-completion
install wget --enable-iri

install vim --override-system-vi
install homebrew/dupes/grep

install nmap

# Install other useful binaries
install ack
install git
install node # This installs `npm` too using the recommended installation method
install p7zip
install pigz
install pv
install rename
install tree
install webkit2png
install siege
install proxychains-ng
install libxml2
install htop-osx
install brew-cask
install tor

# Remove outdated versions from the cellar
cleanup
