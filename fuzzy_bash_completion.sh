# set to 0 to disable logging output:
_fuzzy_debug=0
# ignoring case slows things down a bit
_fuzzy_ignore_case=1

### First, some debugging routines ###
_fuzzy_log()
{
    [[ $_fuzzy_debug -ne 1 ]] && return
    echo $1 >> ~/.fuzzy_complete_log.txt
}

_fuzzy_log_var()
{
    [[ $_fuzzy_debug -ne 1 ]] && return
    _fuzzy_log "$1 is ${!1}"
}
### End debugging routines ###

### Helpers ###
_fuzzy_upcase()
{
    if [[ ${BASH_VERSINFO[0]} -ge 4 ]]; then
        echo ${1^^}
    else
        tr '[:upper:]' '[:lower:]' <<<${1}
    fi
}

_fuzzy_complete_matches()
{
    local allfiles filteredfiles match_pattern target_dir
    allfiles=$1
    match_pattern=$2
    if [[ $3 == "." || "$3" == "" ]]; then
        target_dir=""
    else
        target_dir="$(dirname ${3}/phoney)/"
    fi
    filteredfiles=""
    [[ $_fuzzy_ignore_case -eq 1 ]] && match_pattern=$( _fuzzy_upcase $match_pattern )
    _fuzzy_log_var match_pattern
    _fuzzy_log_var target_dir
    _fuzzy_log_var allfiles
    for f in $1; do
        f_t=$f
        [[ $_fuzzy_ignore_case -eq 1 ]] && f_t=$( _fuzzy_upcase $f )
        # _fuzzy_log_var f
        # _fuzzy_log_var f_t
        if [[ ${f_t} =~ $match_pattern ]]; then
            _fuzzy_log "$f (${f_t}) matches, appending..."
            newguy="${target_dir}$f"
            filteredfiles="${filteredfiles}${newguy} "
        fi
    done
    echo $filteredfiles
}
### End Helpers ###

### The main completion routine ###
_fuzzy_complete()
{
    local files cur prev target_dir target_word filteredfiles allfiles match_pattern
    # Available variables:
    # COMP_LINE COMP_POINT COMP_KEY COMP_TYPE COMP_WORDS COMP_CWORD
    # $1 : name of command whose arguments are being completed
    # $2 : the word being completed
    # $3 : the word preceding the word being completed
    _get_comp_words_by_ref cur prev
    # cur="$2"
    # prev="$1"

    # if they're expanding a variable get out of here:
    if [[ ${cur:0:1} == '$' ]]; then
        COMPREPLY=""
        return 1
    fi

    if [[ -d $cur ]]; then
    # hack to deal with trailing spaces and such: use dirname with
    # a phoney basename. We might be adding an extra / but dirname
    # deals with all that
        target_dir=$(dirname "$cur/phoney")
        target_word=""
    else
        target_dir=$(dirname $cur)
        target_word=$(basename $cur | tr -d -C '[a-zA-Z0-9_\-]')
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

    # allfiles=$( command ls -A $target_dir )
    allfiles=$( command ls $target_dir )
    _fuzzy_log_var allfiles
    filteredfiles=$( _fuzzy_complete_matches "$allfiles" "$match_pattern" "$target_dir" )
    _fuzzy_log_var filteredfiles
    COMPREPLY=($filteredfiles)
}
### End main completion routine ###

# set up the bash completion machinery
complete -D -o bashdefault -o default -o filenames -o nospace -F _fuzzy_complete
# complete -D -o bashdefault -o default -o nospace -F _fuzzy_complete
