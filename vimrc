syntax enable
set tabstop=4
set expandtab
set shiftwidth=4

set ruler

syntax match Tab /\t/
hi Tab gui=underline guifg=blue ctermbg=blue
set list listchars=tab:··,trail:·

set hlsearch
