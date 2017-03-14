FROM ubuntu

RUN apt-get update && apt-get install -y \
  language-pack-ja-base \
  language-pack-ja \
  ibus-mozc \
  fonts-ipafont-gothic \
  fonts-ipafont-mincho \
  curl \
  git \
 && apt-get clean \
 && rm -rf /var/lib/apt/lists/*
RUN alias curl='curl --noproxy localhost,127.0.0.1'
RUN update-locale LANG=ja_JP.UTF-8 LANGUAGE=ja_JP:ja
ENV LC_ALL C.UTF-8

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

ENV USER enxajt
#RUN useradd -m -g sudo -s /bin/zsh $USER && echo "$USER:$USER" | chpasswd
RUN useradd -m -g sudo -s /bin/zsh $USER
USER $USER
WORKDIR /home/$USER

# Copy over private key, and set permissions
RUN mkdir /root/.ssh/
ADD id_rsa /root/.ssh/id_rsa
RUN touch /root/.ssh/known_hosts
RUN ssh-keyscan bitbucket.org >> /root/.ssh/known_hosts
RUN git clone git@bitbucket.org:enxajt/private-config.git
RUN ./private-config/git.sh
RUN ./private-config/user.sh

#deinvim
RUN mkdir -p /home/enxajt/.cache/dein
RUN cd /home/enxajt/.cache/dein \
  && curl -f https://raw.githubusercontent.com/Shougo/dein.vim/master/bin/installer.sh > installer.sh \
  && sh ./installer.sh /home/enxajt/.cache/dein

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
