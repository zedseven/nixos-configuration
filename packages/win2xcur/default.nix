{win2xcur, ...}:
win2xcur.overrideAttrs (_: {
  # Remove the version check that seems misguided - I'm fairly certain that
  # the version of an Xcursor file is the version of the file itself, and not
  # the format version.
  # https://www.x.org/archive/X11R7.7/doc/man/man3/Xcursor.3.xhtml#heading4
  patches = [./remove-version-check.patch];
})
