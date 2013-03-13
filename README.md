## Intro

This bash completion module performs "fuzzy" matching similar to
textmate's "Go to File" fuzzy matching, "flex matching" in emacs' ido
mode, etc.


## Usage
### Set up your shell

You need to have the `show-all-if-ambiguous` readline variable enabled
for this to work. Put the following in your `~/.inputrc`:

    set show-all-if-ambiguous on

### Load the fuzzy functions

    source fuzzy_bash_completion

### Set up completion
#### Using an easy-setup function

    fuzzy_replace_filedir_xspec

(Good if you're using the `bash_completion` package).

#### For individual commands

Set up fuzzy completion for cd:

    fuzzy_setup_for_command cd

#### Replace compspec functions directly

Replace all compspecs that use _cd

    fuzzy_setup_replace_compspec_function _cd

### Revert back to original completion specs

You can list all the compspecs currently using fuzzy completion with:

    fuzzy_list_replaced_specs

You can revert back to the original completion specs with:

    fuzzy_restore_all_specs


## Known issues, Quirks, etc

* Doesn't yet play nicely with default bash completion for variable
  names.

* UPDATE: [Issue #1](https://github.com/mgalgs/fuzzy_bash_completion/issues/1)
  appears to be resolved by setting the `show-all-if-ambiguous`
  readline option!
