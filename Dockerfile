# それぞれの言語の拡張 vim用
RUN apt-get update && apt-get install -y \
  libperl-dev \
  python-dev python3-dev  \
  python-pip \
  python3-pip \
  ruby-dev \
  lua5.2 liblua5.2-dev  \
  luajit libluajit-5.1
RUN pip install --upgrade pip
RUN pip3 install --upgrade pip
RUN pip3 install neovim
# NeoVim
RUN apt-get -y install software-properties-common
RUN add-apt-repository ppa:neovim-ppa/unstable
RUN apt-get update && apt-get install -y neovim


#deinvim
RUN mkdir -p /home/enxajt/.cache/dein
RUN cd /home/enxajt/.cache/dein && \
  curl -f https://raw.githubusercontent.com/Shougo/dein.vim/master/bin/installer.sh > installer.sh && \
  sh ./installer.sh /home/enxajt/.cache/dein

USER enxajt
WORKDIR /home/enxajt

# vim dotfiles
RUN mkdir -p /home/enxajt/.config
RUN git clone https://github.com/enxajt/nvim.git /home/enxajt/.config/nvim
RUN nkf -Lu --overwrite /home/enxajt/.config/nvim/init.vim
#RUN sudo ln -s /home/enxajt/.vim/.vimrc /root/neovim/share/nvim/sysinit.vim
RUN ln -nfs /home/enxajt/shared/virtualbox/vim/backup /home/enxajt/.config/nvim/backup
RUN ln -nfs /home/enxajt/shared/virtualbox/vim/swp /home/enxajt/.config/nvim/swp
RUN ln -nfs /home/enxajt/shared/virtualbox/vim/undo /home/enxajt/.config/nvim/undo

#deinvim install plugins
RUN nvim +":silent call dein#install()" +:q
RUN nvim +":silent UpdateRemotePlugins" +:q
#RUN nvim -E -u NONE -S > /dev/null
