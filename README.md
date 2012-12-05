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

When matches are found, the longest common leading substring starting
from the beginning of each match is placed at your cursor. Sometimes
this is the empty string, which results in undesired behavior like
deleting backward as you try to complete. More info on this issue
below. Honestly, this issue makes fuzzy_bash_completion unsuitable for
day-to-day use, so any help figuring out a solution would be great :).

Doesn't yet play nicely with default bash completion for variable
names.

### Details on the longest common substring thing

Here are some more details about the issue with the longest common
leading substring. Maybe someone has some ideas on how to deal with
this...

The key is that the longest common leading substring of all the words
matching the fuzzy pattern might actually be *the empty string*. By
"leading substring" I mean that the substring has to be located at the
beginning of each of the words. That's just how bash does it (although
I should probably read the bash source to make sure...). So, for
example, say I have a directory with 3 files in it: `pizza, fuzz,
pizzaz` and I type `zz` and try do a fuzzy completion on that. The
fuzzy completion pattern will match all three words, so the script
says, "Hey bash, here are the completions we found", and hands bash
all three words. Bash then tries to find the longest common substring
anchored at the front of these words. Well in this case (because of
our friend `fuzz`) the longest common substring anchored at the
beginning of the words is the empty string (i.e. they have no common
leading substring)! Bash then replaces our current word with the
completion it found (""), which makes it look like our current word
was simply deleted.

The ideal behavior would be to offer all of the fuzzy completions to
the user (all three words, in this case) but I think that would
require a patch to Bash (maybe a variable you could set that would say
"just use any completions I give you, don't do any further processing
on them")... The other option is if fuzzy_bash_completion could detect
this condition, maybe it could offer up to bash the current word (`zz`
in our example) as the *only* completion. This would prevent bash from
deleting your current word but would have the negative side effect of
the user not knowing if there really aren't any matches or if you're
hitting this "no common leading substring" condition...

Maybe there's a way to do it with the `compgen` builtin command.

And maybe (hopefully) there are other ways... If you have any ideas
please head over to [Issue #1](/mgalgs/fuzzy_bash_completion/issues/1)
and leave a comment (or better yet, leave some code :)).
