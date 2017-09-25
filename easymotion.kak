
face EasyMotionBackground rgb:aaaaaa
face EasyMotionForeground red+b

try %{
    decl range-specs em_fg
    decl -hidden str _em_jumps
    decl -hidden str _em_jump
    decl -hidden str _em_seen
    decl str em_jumpchars abcdefghijklmnopqrstuvwxyz
}

def easy-motion-word %{ easy-motion-on-regex '\b\w+\b' }
def easy-motion-WORD %{ easy-motion-on-regex '\s\K\S+' }
def easy-motion-line %{ easy-motion-on-regex '^[^\n]+$' }

def easy-motion-on-regex -params 1 %{
    easy-motion-on "exec \'/%arg{1}<ret>%sh{echo ${#kak_opt_em_jumpchars}}N\'"
}

def easy-motion-on -params 1 %{
    eval -save-regs em "
        exec '\"mZ'
        %arg{1}
        easy-motion-on-selections
    "
}

def easy-motion-on-selections -hidden %{
    easy-motion-setup-alphabet
    eval -no-hooks -draft %{
        easy-motion-set-initial-char
        exec <a-K>\A~<ret>
        set window em_fg "%val{timestamp}"
        set window _em_jumps 'on-key %{ %sh{ case $kak_key in'
        set window _em_seen ""
        eval -itersel %{
            set window _em_jump %val{selection_desc}
            exec '<a-:><a-;>;'
            try %{
                exec "<a-K>[~%opt{_em_seen}]<ret>"
                set -add window _em_seen %val{selection}
                set -add window em_fg "%val{selection_desc}|{EasyMotionForeground}%val{selection}"
                set -add window _em_jumps "
                    %val{selection}) echo \"select %opt{_em_jump}\" ;;"
            }
        }
        set -add window _em_jumps "esac }; easy-motion-rmhl }"
    }
    exec 'u"mz<space>;'
    easy-motion-rmhl
    addhl fill EasyMotionBackground
    addhl replace-ranges em_fg
    eval "%opt{_em_jumps}"
}

def easy-motion-rmhl %{
    rmhl fill_EasyMotionBackground
    rmhl replace_ranges_em_fg
}

def easy-motion-setup-alphabet -hidden %{
    eval -draft %{
        reg '"' "%opt{em_jumpchars}~"
        exec '<a-p>s.<ret>"eyd'
    }
}

def easy-motion-set-initial-char -hidden %{
    try %{
        exec '<a-K>^$<ret>'
    }
    exec '"eP<a-:><a-;>Ha<backspace><esc>'
}

