def pydef -params 3 %{ %sh{
    file=$(mktemp --suffix=.py)
    pyfifo="$file".pyfifo
    kakfifo="$file".kakfifo
    mkfifo "$pyfifo"
    mkfifo "$kakfifo"
    >$file echo "def line(stdin): $3"
    >>$file echo "while True:
        with open('$pyfifo', 'r') as f:
            for s in f:
                try:
                    reply = line(s)
                except Exception as e:
                    reply = 'echo -debug %~$1 error: {}~'.format(e)
                with open('$kakfifo', 'w') as r:
                    r.write(reply)"
    (python $file) > /dev/null 2>&1 </dev/null &
    pypid=$!
    echo "
        def -allow-override $1 %{
            eval -save-regs r -no-hooks -draft %{
                reg r \"$2\"
                edit -debug -scratch *pydef*
                exec \\%di<c-r>r<esc>
                write $pyfifo
            }
            source $kakfifo
        }
        hook -group pydef global KakEnd .* %{ %sh{kill "$pypid"; rm -f "$file" "$pyfifo" "$kakfifo"} }
    "
} }

face EasyMotionBackground rgb:aaaaaa
face EasyMotionForeground red+b

try %{
    decl range-specs em_fg
    decl str em_jumpchars abcdefghijklmnopqrstuvwxyz
}

# e: forward, g: backward
def easy-motion-w -params 0..1 %{ easy-motion-on-regex '\b\w+\b' 'e' %arg{1} }
def easy-motion-W -params 0..1 %{ easy-motion-on-regex '\s\K\S+' 'e' %arg{1} }
def easy-motion-j -params 0..1 %{ easy-motion-on-regex '^[^\n]+$' 'e' %arg{1} }

def easy-motion-b -params 0..1 %{ easy-motion-on-regex '\b\w+\b' 'g' %arg{1} }
def easy-motion-B -params 0..1 %{ easy-motion-on-regex '\s\K\S+' 'g' %arg{1} }
def easy-motion-k -params 0..1 %{ easy-motion-on-regex '^[^\n]+$' 'g' %arg{1} }

def easy-motion-on-regex -params 1..3 %{
    exec -no-hooks <space>G %arg{2} <a-\;>s %arg{1} <ret> ) <a-:>
    easy-motion-on-selections %arg{2} %arg{3}
}

pydef 'easy-motion-on-selections -params 0..2' '%opt{em_jumpchars}:%val{timestamp}:%arg{1}:%arg{2}:%val{selections_desc}' %{
    jumpchars, timestamp, direction, callback, *descs = stdin.strip().split(":")
    from collections import OrderedDict
    jumpchars = list(OrderedDict.fromkeys(jumpchars))
    if direction == 'g':
        descs.reverse()
    fg = timestamp
    jumps = []
    first = None
    for char, desc in zip(jumpchars, descs):
        a, h = desc.split(",")
        fg += ":" + a + "," + a + "|{EasyMotionForeground}" + char
        jumps.append(repr(char) + ") echo select " + desc + " ;;")
        if first is None:
            first = a + "," + a

    jumps.append("*) echo select " + first + " ;;")

    return "\n".join((
        "select " + first,
        "easy-motion-rmhl",
        "easy-motion-addhl",
        "set window em_fg " + repr(fg),
        "on-key %< %sh< case $kak_key in " + "\n".join(jumps) + "esac >; easy-motion-rmhl; " + callback + " >"))
}

def easy-motion-addhl %{
    try %{ addhl window fill EasyMotionBackground }
    try %{ addhl window replace-ranges em_fg }
}

def easy-motion-rmhl %{
    rmhl window/fill_EasyMotionBackground
    rmhl window/replace_ranges_em_fg
}

# user modes can't have dash (yet)
declare-user-mode easymotion
map global easymotion w ':easy-motion-w<ret>' -docstring 'word →'
map global easymotion W ':easy-motion-W<ret>' -docstring 'WORD →'
map global easymotion j ':easy-motion-j<ret>' -docstring 'line ↓'
map global easymotion b ':easy-motion-b<ret>' -docstring 'word ←'
map global easymotion B ':easy-motion-B<ret>' -docstring 'WORD ←'
map global easymotion k ':easy-motion-k<ret>' -docstring 'line ↑'
