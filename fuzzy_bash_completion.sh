# set to 1 to enable logging output:
_fuzzy_debug=0


### First, some debugging routines ###
_fuzzy_log()
{
    [[ $_fuzzy_debug -ne 1 ]] && return
    echo $1 >> ~/fuzzy_complete_log.txt
}

_fuzzy_log_var()
{
    [[ $_fuzzy_debug -ne 1 ]] && return
    _fuzzy_log "$1 is ${!1}"
}
### End debugging routines ###

### The main completion routine ###
_fuzzy_complete()
{
    local files current_word prev_word target_dir
    # Available variables:
    # COMP_LINE COMP_POINT COMP_KEY COMP_TYPE COMP_WORDS COMP_CWORD
    # $1 : name of command whose arguments are being completed
    # $2 : the word being completed
    # $3 : the word preceding the word being completed
    current_word="$2"
    prev_word="$1"

    # if they're expanding a variable get out of here:
    if [[ ${current_word:0:1} == '$' ]]; then
	COMPREPLY=""
	return 1
    fi

    if [[ -d $current_word ]]; then
	# hack to deal with trailing spaces and such: use dirname with
	# a phoney basename. We might be adding an extra / but dirname
	# deals with all that
	target_dir=$(dirname "$current_word/phoney")
	target_word=""
    else
	target_dir=$(dirname $current_word)
	target_word=$(basename $current_word | tr -d -C '[a-zA-Z0-9_\-]')
    fi
    # make sure everything (like ~) is expanded:
    eval target_dir=$target_dir
    _fuzzy_log_var target_dir
    _fuzzy_log_var target_word

    # default match pattern is .* between every letter:
    match_pattern=""
    for (( i=0; i < ${#target_word}; i++ )); do
	# append the ith character to the match pattern along with another .*
	match_pattern="${match_pattern}.*${target_word:${i}:1}"
    done
    # trailing .*
    match_pattern="${match_pattern}.*"
    _fuzzy_log_var match_pattern

    if [[ ! -d $target_dir ]]; then
	_fuzzy_log "$target_dir is not a dir"
	COMPREPLY=""
	return 1
    fi

    # allfiles=$(\ls -A $target_dir)
    allfiles=$(\ls $target_dir)
    filteredfiles=""
    _fuzzy_log_var allfiles
    for f in $allfiles; do
	if [[ $f =~ $match_pattern ]]; then
	    _fuzzy_log "$f matches, appending..."
	    newguy="${target_dir}/$f"
	    if [[ -d $newguy ]]; then
		# hack to make sure there is 1 (and only 1) trailing
		# slash if this is a directory:
		# newguy="$(dirname ${newguy}/phoney)/"
		:
	    fi
	    filteredfiles="${filteredfiles}${newguy} "
	fi
    done
    _fuzzy_log_var filteredfiles
    COMPREPLY=($filteredfiles)
}
### End main completion routine ###

# set up the bash completion machinery
complete -D -o bashdefault -o default -o filenames -o nospace -F _fuzzy_complete
# complete -D -o bashdefault -o default -o nospace -F _fuzzy_complete
