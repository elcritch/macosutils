# Mac OS Utils

A simple package with some wrapper for a few core MacOS system utilities. Currently only a few items needed from `CoreFoundation` are added for [dmon](https://github.com/elcritch/dmon-nim).

It's easy to add more, and I'll accept PR's if people want to wrap more.

Note I've been using Claude and it works really well for creating Nim wrappers for these sort of well utility functions. Usually it only requires a slight modification. I ask it to "Please write idiomatic Nim wrapper for `CFStringCreateWithCString` from MacOS."
