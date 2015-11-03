cp gitconfig ~/.gitconfig
cp vimrc ~/.vimrc
cp tmux-conf ~/.tmux.conf
mkdir -p ~/.vim/colors
cp github.vim ~/.vim/colors

# install pathogen
mkdir -p ~/.vim/autoload ~/.vim/bundle && \
curl -LSso ~/.vim/autoload/pathogen.vim https://tpo.pe/pathogen.vim

./gitcommands.sh.ps1
