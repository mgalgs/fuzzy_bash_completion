#!/bin/bash
#
# fuzzy_bash_completion - fuzzy bash completion
#
# Requires bash >= 4


# set to 0 to disable logging output
_fuzzy_debug=${_fuzzy_debug:-0}
# ignoring case slows things down a bit
_fuzzy_ignore_case=1

### First, some debugging routines ###
_fuzzy_log()
{
    [[ $_fuzzy_debug -ne 1 ]] && return
    echo $1 >> ~/.fuzzy_complete_log.txt
}

# Helper function to log the value of an array. Associative arrays are
# not supported.
_fuzzy_log_arr()
{
    local -a thearray=("${!1}")
    local k arrname=${1/'[@]'/}
    for k in ${!thearray[@]}; do
        _fuzzy_log "${arrname}[$k] is ${thearray[$k]}"
    done
}

# Helper function to log the value of a variable
_fuzzy_log_var()
{
    [[ $_fuzzy_debug -ne 1 ]] && return
    _fuzzy_log "$1 is ${!1}"
}
### End debugging routines ###

### Helpers ###
_fuzzy_upcase()
{
    echo ${1^^}
}

_fuzzy_complete_find_matches()
{
    local allfiles match_pattern target_dir
    local -a filteredfiles
    allfiles=$1
    match_pattern=$2
    if [[ $3 == "." || "$3" == "" ]]; then
        target_dir=""
    elif [[ $3 =~ ^/+$ ]]; then
        target_dir=/
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
    local files cur prev target_dir target_word filteredfiles allfiles match_pattern tails cnt tmp
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

    # bail if there's nothing to complete
    if [[ -z "$cur" ]]; then
        COMPREPLY=""
        return 1
    fi

    if [[ -d $cur ]]; then
        # hack to deal with trailing spaces and such: use dirname with
        # a phoney basename. We might be adding an extra / but dirname
        # deals with all that. However, if $cur is just `/', then
        # basename leaves a `trailing slash' (it's the only slash,
        # leading and trailing).
        if [[ $cur =~ ^/+$ ]]; then
            _fuzzy_log "rooting around"
            target_dir=/
        else
            target_dir=$(dirname "$cur/phoney")
        fi
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


    allfiles=$( command ls -B $target_dir )
    _fuzzy_log_var allfiles
    filteredfiles=( $( _fuzzy_complete_find_matches "$allfiles" "$match_pattern" "$target_dir" ) )
    # _fuzzy_log_arr filteredfiles[@]
    COMPREPLY=( ${filteredfiles[@]} )
    _fuzzy_log ""               # some logfile spacing
    # COMPREPLY=( $filteredfiles ) 
}
### End main completion routine ###




################################################################################
# From here down:
# fuzzy_setup_functions - a set of functions to facilitate setting
# up fuzzy completion
################################################################################

declare -A _fuzzy_replaced_specs

# the options used to set up the completion:
_fuzzy_complete_options="-o bashdefault -o default -o filenames -o nospace -v -F _fuzzy_complete"

# function _fuzzy_find_compspec_by_pattern
#
# find existing compspec by regex pattern
#
# params :
# 1      : the regex to search for (e.g. " -F _filedir_xspec")
#
# return values :
#  - echo       : the compspec
#  - return     : 0 on success, 1 on failure
_fuzzy_find_compspec_by_pattern()
{
    local the_pattern="$1"
    complete | {
        while read myline; do
            # see if the function matches
            if [[ $myline =~ $the_pattern ]]; then
                echo $myline
                return 0
            fi
        done
    }
    return 1
}

# function _fuzzy_find_compspec_by_function
#
# find existing compspec by function
#
# params :
# 1      : the function to search for (e.g. _filedir_xspec)
#
# return values :
#  - echo       : the compspec
#  - return     : 0 on success, 1 on failure
_fuzzy_find_compspec_by_function()
{
    local stuff retval
    stuff=$( _fuzzy_find_compspec_by_function " -F $1" )
    retval=$?
    echo $stuff
    return $retval
}


# function _fuzzy_find_compspec_by_command
#
# find existing compspec by command
#
# params :
# 1      : the command to search for (e.g. ls)
#
# returns   :
#  - echo   : the compspec
#  - return : 0 on success, 1 on failure
_fuzzy_find_compspec_by_command()
{
    local stuff retval
    stuff=$( _fuzzy_find_compspec_by_function "$1\$" )
    retval=$?
    echo $stuff
    return $retval
}

# function _fuzzy_re_extract_first
#
# Extracts the first match of the regex
#
# params :
# 1      : the text against which we'll test our regex
# 2      : the regex (should contain one match group)
#
# returns :
#  - echo : the matched text
_fuzzy_re_extract_first()
{
    if [[ "$1" =~ $2 ]]; then
        echo -n ${BASH_REMATCH[1]}
    fi
}

# function _fuzzy_extract_command_from_compspec
#
# Extracts the command out of a compspec (the last word in the compspec)
#
# params :
# 1      : the compspec line (e.g. "complete -o default -F _longopt mv")
#
# returns :
#  - echo : the command
_fuzzy_extract_command_from_compspec()
{
    echo -n $( _fuzzy_re_extract_first "$1" ".*( [^ ]+$)" )
}

# function _fuzzy_extract_function_from_compspec
#
# Extracts the function out of a compspec (the thing following a -F)
#
# params :
# 1      : the compspec line (e.g. "complete -o default -F _longopt mv")
#
# returns :
#  - echo : the function
_fuzzy_extract_function_from_compspec()
{
    echo -n $( _fuzzy_re_extract_first "$1" ".*-F ([^ ]+) .*" )
}


# function _fuzzy_replace_compspecs_by_function
# 
# replace existing completion spec functions with _fuzzy_complete. The
# replaced compspecs are saved in _fuzzy_replaced_specs for possible
# later restoration. If no existing compspecs are found for the given
# function, nothing happens.
#
# params :
# 1      : the existing compspec function to replace
#          (something like _filedir_xspec)
_fuzzy_replace_compspecs_by_function()
{
    local existing_spec="$1" this_command this_function

    while read myline; do
        this_function=$( _fuzzy_extract_function_from_compspec "$myline" )
        [[ -n "$this_function" && $this_function == $existing_spec ]] \
            || continue
        this_command=$( _fuzzy_extract_command_from_compspec "$myline" )
        # key will look something like: "_filedir_xspec xdvi"
        _fuzzy_replaced_specs["$this_function $this_command"]="$myline"
        # set up our new completion:
        complete $_fuzzy_complete_options $this_command
        # we might have more to replace. keep going...
    done < <( complete | grep $1 )
}

# function _fuzzy_replace_compspecs_by_command
#
# sets up fuzzy completion for a specific command. If no existing
# compsec is found for the given command, the completion is still set
# up.
#
# params :
# 1      : the command for which we want to set up fuzzy completion
#          (e.g. ls)
_fuzzy_replace_compspecs_by_command()
{
    local existing_command="$1" this_command this_function
    # foreach line in the output of `complete`
    while read myline; do
        this_command=$( _fuzzy_extract_command_from_compspec "$myline" )
        [[ -n "$this_command" && $this_command == $existing_command ]] \
            || continue
        this_function=$( _fuzzy_extract_function_from_compspec "$myline" )
        # key will look something like: "_filedir_xspec xdvi"
        _fuzzy_replaced_specs["$this_function $this_command"]="$myline"
        # set up our new completion:
        complete $_fuzzy_complete_options $existing_command
        # there should only be one compspec per command, so we're done
        return
    done < <( complete | grep $1 )
    echo "No existing compspecs for ${existing_command}. Setting up new compspec."
    complete $_fuzzy_complete_options $existing_command
}

# function fuzzy_list_replaced_specs
#
# Lists all compspecs that have been replaced by the functions found
# in fuzzy_setup_functions. If you just want to see the specs
# (without all the header and footer mumbo jumbo), just redirect
# stderr to /dev/null (i.e. fuzzy_list_replaced_specs 2>/dev/null )
fuzzy_list_replaced_specs()
{
    local compspec
    echo "    All replaced compspecs:" 1>&2
    echo "==============================="  1>&2
    echo "" 1>&2
    [[ ${#_fuzzy_replaced_specs[@]} -eq 0 ]] && echo " ...None..." && return
    for compspec in "${_fuzzy_replaced_specs[@]}"; do
        echo " :: $compspec"
    done
    echo ""  1>&2
    echo "==============================="  1>&2
    echo "To restore these compspecs, use"  1>&2
    echo "fuzzy_restore_all_specs" 1>&2
}

# function fuzzy_restore_all_specs
#
# Attempts to restore any specs that have been replaced by
# _fuzzy_replace_compspecs_by_function
fuzzy_restore_all_specs()
{
    local key
    for key in "${!_fuzzy_replaced_specs[@]}"; do
        echo "restoring ${_fuzzy_replaced_specs[$key]}"
        eval ${_fuzzy_replaced_specs["$key"]}
        unset _fuzzy_replaced_specs["$key"]
    done
}

# function fuzzy_setup_for_command
#
# Sets up fuzzy completion for the given command. This function is a
# shamelessly naive frontend to _fuzzy_replace_compspecs_by_command.
#
# params :
# 1      : the command for which we want to set up fuzzy completion
fuzzy_setup_for_command()
{
    _fuzzy_replace_compspecs_by_command $1
}

# function fuzzy_setup_replace_compspec_function
#
# Sets up fuzzy completion for the given command. This function is a
# shamelessly naive frontend to _fuzzy_replace_compspecs_by_function.
#
# params :
# 1      : the compspec function we want to replace with fuzzy
fuzzy_setup_replace_compspec_function()
{
    _fuzzy_replace_compspecs_by_function $1
}

# function fuzzy_replace_filedir_xspec
#
# Replaces the _filedir_xspec compspec function that ships with the
# bash_completion package and takes care of general filedir
# completion (a good candidate for fuzzy completion!)
fuzzy_replace_filedir_xspec()
{
    fuzzy_setup_replace_compspec_function _filedir_xspec
}

# Local variables:
# mode: shell-script
# sh-basic-offset: 4
# indent-tabs-mode: nil
# End:
# ex: ts=4 sw=4 et filetype=sh
