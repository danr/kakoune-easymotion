def pydef -params 3 %{ %sh{
    file=$(mktemp --suffix=.py)
    echo "if True: $3" > $file
    echo "
        def -allow-override $1 %{ %sh{
            echo \"$2\" | python $file
        } }
        hook -group pydef global KakEnd .* %{ %sh{rm $file} }
    "
    echo "$file" >/dev/stderr
} }

face EasyMotionBackground rgb:aaaaaa
face EasyMotionForeground red+b

try %{
    decl range-specs em_fg
    decl str em_jumpchars abcdefghijklmnopqrstuvwxyz
}

def easy-motion-word %{ easy-motion-on-regex '\b\w+\b' }
def easy-motion-WORD %{ easy-motion-on-regex '\s\K\S+' }
def easy-motion-line %{ easy-motion-on-regex '^[^\n]+$' }

def easy-motion-on-regex -params 1 %{
    exec GE<a-\;>s %arg{1} <ret> <a-:>
    easy-motion-on-selections
}

pydef easy-motion-on-selections $kak_opt_em_jumpchars:$kak_timestamp:$kak_selections_desc '
    import sys
    jumpchars, timestamp, *descs = sys.stdin.read().strip().split(":")
    fg = timestamp
    jumps = []
    first = None
    for char, desc in zip(jumpchars, descs):
        a, h = desc.split(",")
        fg += ":" + a + "," + a + "|{EasyMotionForeground}" + char
        jumps.append(char + ") echo select " + desc + " ;;")
        if first is None:
            first = a + "," + a

    print("select " + first)
    print("easy-motion-rmhl")
    print("easy-motion-addhl")
    print("set window em_fg " + fg)
    print("on-key %{ %sh{ case $kak_key in " + "\n".join(jumps) + " esac; echo easy-motion-rmhl } }")
'

def easy-motion-addhl %{
    try %{ addhl window fill EasyMotionBackground }
    try %{ addhl window replace-ranges em_fg }
}

def easy-motion-rmhl %{
    rmhl window/fill_EasyMotionBackground
    rmhl window/replace_ranges_em_fg
}

