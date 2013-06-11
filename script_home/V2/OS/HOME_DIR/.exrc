filetype plugin indent on
syntax on

"vim7.3" if version >= 730
"vim7.3"	set cryptmethod=blowfish
"vim7.3" endif
set encoding=utf-8
set fileencoding=utf-8
set fileformat=unix
"
set ruler
set modelines=0
set nrformats=hex
"
set sw=4
set autoindent
" set expandtab
set shiftround
set smartindent
set smarttab
"
set ignorecase
set smartcase
set showmatch
set incsearch
set scrollbind
"
" set mouse=a

set dictionary=/usr/share/dict/french

" Pas de double espace avec la commande 'J'
set nojoinspaces

" Alignement automatique des énumérations qui sont considérées comme des commentaires
" Par défaut: comments=s1:/*,mb:*,ex:*/,://,b:#,:%,:XCOMM,n:>,fb:-
set comments=b:#,://,:%,fb:-,fn:*,fb:=>
set formatoptions=tcqnor

"
"	Redéfinition de touches :
"	- ^F : en mode insertion, completion sur les noms de fichiers
inoremap <C-F> <C-X><C-F>
"	- ^K : en mode insertion, completion sur le dictionnaire
inoremap <C-K> <C-X><C-K>
"	- ^L : en mode insertion, completion sur les lignes du fichier actuel
inoremap <C-L> <C-X><C-L>


"	Switch mode PASTE <-> mode normal (:help paste)
set pastetoggle=<INS>

"
"	F2 insère le nom complet du fichier et la date puis cadre le tout à droite
map <F2> O<ESC>:.!date +"$(readlink -f "%") - \%d.\%m.\%Y"<CR>:ri<CR>
"
"	F3 insère le nom complet du fichier
map <F3> a<CR><CR><ESC><UP>:.!readlink -f "%"<CR><UP>JJ
"
"	F4 insère la date sous la forme dd.mm.yyyy
map <F4> a<CR><CR><ESC><UP>:.!date +"\%d.\%m.\%Y"<CR><UP>JJ
"
"       F5 : soulignement de la ligne avec '.'
map <F5> :let @t = @/<CR>YpI <ESC>0d^:s/\s*$//<CR>:s/./+/g<CR>Px:let @/ = @t<CR><DOWN>
"
"       F6 : soulignement de la ligne avec '.'
map <F6> :let @t = @/<CR>YpI <ESC>0d^:s/\s*$//<CR>:s/./^/g<CR>Px:let @/ = @t<CR><DOWN>
"
"       F7 : soulignement de la ligne avec '~'
map <F7> :let @t = @/<CR>YpI <ESC>0d^:s/\s*$//<CR>:s/./\~/g<CR>Px:let @/ = @t<CR><DOWN>
"
"       F8 : soulignement de la ligne avec '-'
map <F8> :let @t = @/<CR>YpI <ESC>0d^:s/\s*$//<CR>:s/./-/g<CR>Px:let @/ = @t<CR><DOWN>
"
"       Shift-F8 : encadrement de la ligne avec '-'
map <S-F8> <F8><UP>Y<UP>P<DOWN><DOWN><DOWN>
"
"       F9 : soulignement de la ligne avec '='
map <F9> :let @t = @/<CR>YpI <ESC>0d^:s/\s*$//<CR>:s/./=/g<CR>Px:let @/ = @t<CR><DOWN>
"
"       Shift-F9 : encadrement de la ligne avec '='
map <S-F9> <F9><UP>Y<UP>P<DOWN><DOWN><DOWN>
"
"	F12 convertit le texte (un programme source idéalement) en HTML avec colorisation syntaxique
map <F12> :so/usr/share/vim/vimcurrent/syntax/2html.vim<NL>
"
"	Tab commente une ligne avec '#'
map <TAB> :let @t = @/<CR>:s/^<BSLASH>s*/&# /<CR>:let @/ = @t<CR><DOWN>
"
"	Shift-Tab décommente une ligne commençant par '#'
map <S-TAB> :let @t = @/<CR>:s/^<BSLASH>(<BSLASH>s*<BSLASH>)#<BSLASH>s*/<BSLASH>1/<CR>:let @/ = @t<CR><DOWN>
"
"	Shift-F1 encadre un mot par des guillemets français (« et »)
map <S-F1> <LEFT>Ea »<ESC>Bi« <ESC>EE
"
"	F9 ajoute un en-tête Doxygen à une méthode
" map <F9> O/**<CR> *  @brief<TAB>BlablaDesc<CR>*<CR>*  @param x<TAB>BlablaX<CR>*<CR>*  @return<TAB>BlablaRet<CR>*/<ESC>
"
"	F10 doxygénise un commentaire situé après une méthode (projet Comtrack)
" map <F10> <F9><DOWN><DOWN>mm}:'m,-1<LT><LT><CR>:'m,.s,^\(\s*\)//\s*,\1 *  <CR>"md'm?BlablaDesc?+1<CR>Yp"mP

"	Force l'aide à s'ouvrir dans une fenêtre verticale à gauche (~= à la place) de la fenêtre consultée
nnoremap :help :vert lefta help


""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
"
"	Commandes personnelles (à appeler avec ':' comme n'importe quelle commande ex)
"
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

"	Transformation caractères accentués => caractères non accentués
command -range=% -nargs=0 -bar DelAccents <line1>,<line2>s,[[=A=]]\&[^A],A,eg|<line1>,<line2>s,[[=a=]]\&[^a],a,eg|<line1>,<line2>s,[[=C=]]\&[^C],C,eg|<line1>,<line2>s,[[=c=]]\&[^c],c,eg|<line1>,<line2>s,[[=E=]]\&[^E],E,eg|<line1>,<line2>s,[[=e=]]\&[^e],e,eg|<line1>,<line2>s,[[=I=]]\&[^I],I,eg|<line1>,<line2>s,[[=i=]]\&[^i],i,eg|<line1>,<line2>s,[[=O=]]\&[^O],O,eg|<line1>,<line2>s,[[=o=]]\&[^o],o,eg|<line1>,<line2>s,[[=U=]]\&[^U],U,eg|<line1>,<line2>s,[[=u=]]\&[^u],u,eg

"	Enlève les espaces en fin de ligne et remplace les tabs par des espaces dans les indentations uniquement
command -range=% -nargs=0 -bar ExpandIndent <line1>,<line2>s,[[:space:]]\+$,,e|<line1>,<line2>!expand -i

"	Écriture après remplacement des tabs par des espaces dans les indentations uniquement
command -range=% -nargs=? -bar WW <line1>,<line2>ExpandIndent|w <args>
command WN %WW|n
command WP %WW|N

"	Sauvegarde et fin après remplacement des tabs par des espaces dans les indentations uniquement
command -range=% -nargs=? -bar XX <line1>,<line2>ExpandIndent|x <args>
" map Q :XX<CR>

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

if filereadable(glob("~/.exrc.local"))
    source ~/.exrc.local
endif
