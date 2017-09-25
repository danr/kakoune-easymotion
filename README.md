# kakoune-easymotion

[kakoune](http://kakoune.org) plugin for navigating like the easymotion vim mode

[![demo](https://asciinema.org/a/139545.png)](https://asciinema.org/a/139545)

## Setup

Add `easymotion.kak` to your autoload directory,`~/.config/kak/autoload`, or source it manually.

## Usage

The script defines a few commands `easy-motion-word`, `easy-motion-WORD`, `easy-motion-line` and `easy-motion-on-regex`,
and uses one option, `em_jumpchars` which defaults to `a..z`,
and two faces, `EasyMotionForeground` and `EasyMotionBackground`.
They default to red and light grey.

I don't suggest any particular mappings, but you could try:
```
map global user w :easy-motion-word<ret>
map global user W :easy-motion-WORD<ret>
map global user l :easy-motion-line<ret>
```

## License

Unlicense
