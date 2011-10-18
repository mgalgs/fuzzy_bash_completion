## Intro

This bash completion module performs "fuzzy" matching similar to
textmate's "Go to File" fuzzy matching, "flex matching" in emacs' ido
mode, etc.


## Usage
    source fuzzy_bash_completion.sh


## Known issues, Quirks, etc

When matches are found, the longest common substring starting from the
beginning of each match is placed at your cursor. This results in
undesired behavior like deleting backward as you try to complete.
