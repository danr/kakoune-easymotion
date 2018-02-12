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

def easy-motion-word -params 0..1 %{ easy-motion-on-regex '\b\w+\b' %arg{1} }
def easy-motion-WORD -params 0..1 %{ easy-motion-on-regex '\s\K\S+' %arg{1} }
def easy-motion-line -params 0..1 %{ easy-motion-on-regex '^[^\n]+$' %arg{1} }

def easy-motion-on-regex -params 1..2 %{
    exec -no-hooks <space>GE<a-\;>s %arg{1} <ret> "'" <a-:>
    easy-motion-on-selections %arg{2}
}

pydef 'easy-motion-on-selections -params 0..1' '%opt{em_jumpchars}:%val{timestamp}:%arg{1}:%val{selections_desc}' %{
    jumpchars, timestamp, callback, *descs = stdin.strip().split(":")
    from collections import OrderedDict
    jumpchars = list(OrderedDict.fromkeys(jumpchars))
    fg = timestamp
    jumps = []
    first = None
    for char, desc in zip(jumpchars, descs):
        a, h = desc.split(",")
        fg += ":" + a + "," + a + "|{EasyMotionForeground}" + char
        jumps.append(char + ") echo select " + desc + " ;;")
        if first is None:
            first = a + "," + a

    jumps.append("*) echo select " + first + " ;;")

    return "\n".join((
        "select " + first,
        "easy-motion-rmhl",
        "easy-motion-addhl",
        "set window em_fg " + fg,
        "on-key %{ %sh{ case $kak_key in " + "\n".join(jumps) + "esac }; easy-motion-rmhl; " + callback + " }"))
}

def easy-motion-addhl %{
    try %{ addhl window fill EasyMotionBackground }
    try %{ addhl window replace-ranges em_fg }
}

def easy-motion-rmhl %{
    rmhl window/fill_EasyMotionBackground
    rmhl window/replace_ranges_em_fg
}

