## Intro

This bash completion module performs "fuzzy" matching similar to
textmate's "Go to File" fuzzy matching, "flex matching" in emacs' ido
mode, etc.


## Usage
### Load the fuzzy functions
    source fuzzy_bash_completion
    source fuzzy_log_setup_functions

### Set up completion
#### Using an easy-setup function
    fuzzy_replace_filedir_xspec # good if you're using the bash_completion package

#### For individual commands
    fuzzy_setup_for_command cd # set up fuzzy completion for cd

#### Replace compspec functions directly
    fuzzy_setup_replace_compspec_function _cd # replace all compspecs that use _cd

### Revert back to original completion specs
You can list all the compspecs currently using fuzzy completion with:

    fuzzy_list_replaced_specs

You can revert back to the original completion specs with:

    fuzzy_restore_all_specs


## Known issues, Quirks, etc

When matches are found, the longest common substring starting from the
beginning of each match is placed at your cursor. This results in
undesired behavior like deleting backward as you try to complete.

Doesn't yet play nicely with default bash completion for variable
names.