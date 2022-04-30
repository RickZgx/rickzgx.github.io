---
title: My Vim Note
date: 2022-03-19 12:04:00 Z
categories:
- Tool
tags:
- Tool
- Vim
---

本文记录Vim个人常用操作和配置，并持续更新中！

# 准备
vim 8.0+
```
git clone https://github.com/vim/vim.git
make distclean
./configure --with-features=huge --enable-python3interp --enable-pythoninterp --with-python-config-dir=/usr/lib/python2.7/config-x86_64-linux-gnu/ --enable-rubyinterp --enable-luainterp --enable-perlinterp --with-python3-config-dir=config-3.6m-x86_64-linux-gnu --enable-multibyte --enable-cscope   
make
sudo make install
sudo cp vim /usr/bin
```

# 配置
## 基本配置
```
autocmd BufWritePost $MYVIMRC source $MYVIMRC

set nocompatible " 关闭兼容模式
set nu " 设置行号
set cursorline " 突出显示当前行
" set cursorcolumn " 突出显示当前列
set showmatch " 显示括号匹配

" tab 缩进
set tabstop=4 " 设置Tab长度为4空格
set shiftwidth=4 " 设置自动缩进长度为4空格
set autoindent " 继承前一行的缩进方式，适用于多行注释

" 定义快捷键的前缀，即<Leader>
let mapleader=";" 

" ==== 系统剪切板复制粘贴 ====
" v 模式下复制内容到系统剪切板
vmap <Leader>c "+yy
" n 模式下复制一行到系统剪切板
nmap <Leader>c "+yy
" n 模式下粘贴系统剪切板的内容
nmap <Leader>v "+p

" 开启实时搜索
set incsearch
" 搜索时大小写不敏感
set ignorecase
syntax enable
syntax on                    " 开启文件类型侦测
filetype plugin indent on    " 启用自动补全

" 退出插入模式指定类型的文件自动保存
au InsertLeave *.go,*.sh,*.php write

" 解决中文乱码
set fileencodings=utf-8,ucs-bom,gb18030,gbk,gb2312,cp936
set termencoding=utf-8
set encoding=utf-8
```

## Golang插件配置
安装[vim-plug](https://github.com/junegunn/vim-plug)
###### Unix

```sh
curl -fLo ~/.vim/autoload/plug.vim --create-dirs \
    https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
```

You can automate the process by putting the command in your Vim configuration
file as suggested [here][auto].

[auto]: https://github.com/junegunn/vim-plug/wiki/tips#automatic-installation

###### Windows (PowerShell)

```powershell
iwr -useb https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim |`
    ni $HOME/vimfiles/autoload/plug.vim -Force
```

#### Neovim

###### Unix, Linux

```sh
sh -c 'curl -fLo "${XDG_DATA_HOME:-$HOME/.local/share}"/nvim/site/autoload/plug.vim --create-dirs \
       https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim'
```

###### Linux (Flatpak)

```sh
curl -fLo ~/.var/app/io.neovim.nvim/data/nvim/site/autoload/plug.vim --create-dirs \
    https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
```

###### Windows (PowerShell)

```powershell
iwr -useb https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim |`
    ni "$(@($env:XDG_DATA_HOME, $env:LOCALAPPDATA)[$null -eq $env:XDG_DATA_HOME])/nvim-data/site/autoload/plug.vim" -Force
```

.vimrc配置安装插件
```
call plug#begin()
Plug 'fatih/vim-go'
Plug 'majutsushi/tagbar'
Plug 'scrooloose/nerdtree'
Plug 'Valloric/YouCompleteMe'
call plug#end()
```

命令行输入`vim`后输入`:PlugInstall`就可以开始安装了。

# 实践
- 刚开始使用vim使用可以`vimtutor`，按照上面的例子实践一遍


# refs
> [https://github.com/junegunn/vim-plug
](https://github.com/junegunn/vim-plug)  
> [https://www.cnblogs.com/standardzero/p/10727689.html
](https://www.cnblogs.com/standardzero/p/10727689.html)  
> [https://www.jianshu.com/p/8426cef1f4f5](https://www.jianshu.com/p/8426cef1f4f5)  
> [https://www.cnblogs.com/starfish29/p/11156333.html
](https://www.cnblogs.com/starfish29/p/11156333.html)
