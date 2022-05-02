filetype indent off
syntax on
colorscheme iceberg

" CPP
" let g:cpp_class_scope_highlight = 1
" let g:cpp_member_variable_highlight = 1
" let g:cpp_class_decl_highlight = 1
" let g:cpp_experimental_simple_template_highlight = 1
" let g:cpp_concepts_highlight = 1

" JavaScript
let g:javascript_plugin_jsdoc = 1

"hidden chars
set list
set listchars=tab:▸▸
set listchars+=extends:⇢
set listchars+=precedes:⇠
set listchars+=space:∙
set listchars+=trail:◦
set listchars+=eol:⦙

" Directory
set directory^=$HOME/.vim/tmp/

" CtrlP 
let g:ctrlp_map = '<c-p>'
let g:ctrlp_cmd = 'CtrlP'
let g:ctrlp_working_path_mode = 'ra'


" For gitgutter
set updatetime=500
set signcolumn=yes

let g:gitgutter_sign_added              = '⇉'
let g:gitgutter_sign_modified           = '⇋'
let g:gitgutter_sign_removed            = '⇇'
let g:gitgutter_sign_removed_first_line = '⟵'
let g:gitgutter_sign_modified_removed   = '⤒'
let g:gitgutter_highlight_lines = 1
let g:gitgutter_diff_base = 'head'


fun! TrimWhitespace()
    let l:save = winsaveview()
    keeppatterns %s/\s\+$//e
    call winrestview(l:save)
endfun

noremap <Leader>t :call TrimWhitespace()<CR>
noremap <Leader><Space> :noh<CR>

" Status line
set laststatus=2
set noshowmode

" Tabs
set tabstop=4
set softtabstop=4
set shiftwidth=4
set expandtab
set noautoindent

" UI
set number
set showcmd
set cursorline

set wildmenu
set showmatch
set incsearch
set hlsearch
set ignorecase

set nocompatible
set bs=2

" Share clipboard with OS X
set clipboard=unnamed

" fzf
set rtp+=/usr/local/opt/fzf
