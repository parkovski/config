cp gitconfig ~/.gitconfig
cp vimrc ~/.vimrc
cp tmux-conf ~/.tmux.conf
mkdir -p ~/.vim/colors
cp github.vim ~/.vim/colors

# install pathogen
mkdir -p ~/.vim/autoload ~/.vim/bundle && \
curl -LSso ~/.vim/autoload/pathogen.vim https://tpo.pe/pathogen.vim

git clone https://github.com/scrooloose/syntastic.git ~/.vim/bundle/syntastic
git clone https://github.com/pangloss/vim-javascript.git ~/.vim/bundle/vim-javascript
#omnisharp vim looks interesting
git clone https://github.com/fsharp/vim-fsharp.git ~/.vim/bundle/vim-fsharp
echo "to install fsharp syntax checker, go to ~/.vim/bundle/vim-fsharp and run make"
