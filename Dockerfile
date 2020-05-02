FROM ubuntu:16.04

ENV DEBIAN_FRONTEND noninteractive

RUN sed -i 's/# deb-src/deb-src/' "/etc/apt/sources.list" && \
    apt update && \
    apt install -y gawk gcc-multilib build-essential vim curl openssh-server wget nmap python python-pip python3 python3-pip gdb gcc libc6-dev libc6-i386 git tmux zsh sudo language-pack-zh-hans ltrace strace cmake && \
    localedef -i en_US -c -f UTF-8 -A /usr/share/locale/locale.alias en_US.UTF-8

RUN pip install --upgrade pip && \
    pip install ROPgadget pwntools pycrypto ipython
        
RUN git clone https://github.com/pwndbg/pwndbg ~/tools/pwndbg && \       
    git clone https://github.com/robbyrussell/oh-my-zsh.git ~/.oh-my-zsh && \
    git clone https://github.com/longld/peda.git ~/tools/peda && \
    git clone https://github.com/radare/radare2.git ~/tools/radare2

RUN cd ~/tools/pwndbg && ./setup.sh && \
    echo "source ~/tools/peda/peda.py" >> ~/.gdbinit && \ 
    cp ~/.oh-my-zsh/templates/zshrc.zsh-template ~/.zshrc && \       
    chsh -s /bin/zsh && \       
    sed -i 's/ZSH_THEME=\"robbyrussell\"/ZSH_THEME=\"ys\"/' ~/.zshrc && \
    sh ~/tools/radare2/sys/install.sh && \
    radare2 -v && \
    ln -s /usr/local/bin/radare2 /bin/r2 && \
    rm -rf /tools/radare2

RUN mkdir -p ~/source && \
    cd ~/source && apt source libc6-dev && \
    rm -rf glibc_* && \
    cd glibc* && mkdir build_x64 && mkdir build_x86 && \
    mkdir -p /glibc/x64 && mkdir -p /glibc/x86 && \
    cd build_x64 && ../configure --prefix=/glibc/x64 --disable-werror --enable-debug=yes && make -j6 && make install && \
    cd ../build_x86 && ../configure --prefix=/glibc/x86 --disable-werror --enable-debug=yes --host=i686-linux-gnu --build=i686-linux-gnu CC="gcc -m32" CXX="g++ -m32" && make -j6 && make install && \
    cd .. && rm -rf build* && \
    apt clean && apt autoremove

RUN wget https://raw.githubusercontent.com/zero-MK/7th-vim/master/install.sh && bash install.sh -i && rm install.sh 

WORKDIR /root
