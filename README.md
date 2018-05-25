# kakoune-easymotion
​
[![IRC][IRC Badge]][IRC]

[kakoune](http://kakoune.org) plugin for navigating like the easymotion vim mode

[![demo](https://asciinema.org/a/139545.png)](https://asciinema.org/a/139545)

## Setup

Add `easymotion.kak` to your autoload directory,`~/.config/kak/autoload`, or source it manually.

## Usage

The script defines a few commands:
  - `easy-motion-f`
  - `easy-motion-w`
  - `easy-motion-W`
  - `easy-motion-j`
  - `easy-motion-alt-f`
  - `easy-motion-b`
  - `easy-motion-B`
  - `easy-motion-k`
  - `easy-motion-on-regex`
 
It uses one option, `em_jumpchars` which defaults to `a..z`,
and two faces, `EasyMotionForeground` and `EasyMotionBackground`.
They default to red and light grey.

I don't suggest any particular mappings, but you could try:
```
map global user w :easy-motion-w<ret>
map global user W :easy-motion-W<ret>
map global user j :easy-motion-j<ret>
```

or use the provided `easymotion` user-mode.

## License

Unlicense

[IRC]: https://webchat.freenode.net?channels=kakoune
[IRC Badge]: https://img.shields.io/badge/IRC-%23kakoune-blue.svg
