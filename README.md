## Intro

This bash completion module performs "fuzzy" matching similar to
textmate's "Go to File" fuzzy matching, "flex matching" in emacs' ido
mode, etc.

For example:

    mkdir pizza
    mkdir jazz
    cd zz<TAB>
    # displays `pizza' and `jazz'
    rm -r jazz
    cd zz<TAB>
    # completes the word `pizza'

## Requirements

  - `bash >= 4.0` (since we need
    [associative arrays](http://www.gnu.org/software/bash/manual/html_node/Arrays.html)).
  - The `bash-completion` package (could have a different name on your
    distro).  Please follow the instructions specific to your distro for
    installing and enabling `bash-completion`.

## Usage

Put the following in your `~/.inputrc`:

    set show-all-if-ambiguous on

Put the following in your `~/.bashrc`:

    source /path/to/fuzzy_bash_completion

Now you can start enabling fuzzy completion for individual commands like
so:

    fuzzy_setup_for_command cd

Either interactively or by adding it to your `~/.bashrc`.

There are a few helper functions to set up fuzzy completion for known
commands in bulk.  However, these helper functions only work on certain
versions of bash completion, so YMMV.

    fuzzy_replace_filedir_xspec

To list all commands currently using fuzzy completion, run:

    fuzzy_list_replaced_specs

## Troubleshooting

### List commands that are currently fuzzy

You can list all of the fuzzy compspecs with:

    fuzzy_list_replaced_specs

### Revert back to original completion specs (debugging and development)

If something doesn't seem right and you want to back out all fuzzy
completion, you can use:

    fuzzy_restore_all_specs

(and you should also file a bug report [on
GitHub](https://github.com/mgalgs/fuzzy_bash_completion/issues))


## Known issues, Quirks, etc

* Doesn't yet play nicely with default bash completion for variable
  names.

* Find something else? Report it [on
  GitHub](https://github.com/mgalgs/fuzzy_bash_completion/issues) and
  earn a cookie!
