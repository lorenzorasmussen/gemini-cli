# Less Command Cheat Sheet

This cheat sheet summarizes the most important and frequently used commands for `less`, a powerful terminal pager.

## Moving

| Key(s)      | Description             |
|-------------|-------------------------|
| `e`, `j`, `CR` | Forward one line        |
| `y`, `k`      | Backward one line       |
| `f`, `SPACE`  | Forward one window      |
| `b`, `ESC-v`  | Backward one window     |
| `d`           | Forward one half-window |
| `u`           | Backward one half-window|

## Searching

| Key(s)      | Description             |
|-------------|-------------------------|
| `/pattern`  | Search forward          |
| `?pattern`  | Search backward         |
| `n`           | Repeat previous search  |
| `N`           | Repeat search (reverse) |

## Jumping

| Key(s)      | Description             |
|-------------|-------------------------|
| `g`, `<`      | Go to first line        |
| `G`, `>`      | Go to last line         |
| `p`, `%`      | Go to beginning of file |

## Exiting

| Key(s)      | Description             |
|-------------|-------------------------|
| `q`, `:q`     | Exit                    |
| `Q`, `:Q`     | Exit (force)            |
| `ZZ`          | Exit                    |

## Miscellaneous

| Key(s)      | Description             |
|-------------|-------------------------|
| `r`, `^R`     | Repaint screen          |
| `!command`    | Execute shell command   |
| `s file`      | Save input to file      |

## Options (Commonly Used)

| Option      | Description             |
|-------------|-------------------------|
| `-F`        | Quit if entire file fits on first screen |
| `-S`        | Chop long lines (don't wrap) |
| `-i`        | Ignore case in searches (unless uppercase in pattern) |
| `-R`        | Output "raw" control characters |

---

**Tip:** You can always press `h` or `H` within `less` to display its full help menu.
