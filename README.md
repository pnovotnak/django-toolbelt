# Django Toolbelt

This repository keeps all of my Django tricks in one place.

It's just a little bit of kit that makes me a wee bit faster.

## Preliminary Steps

I've established that it saves me a *lot* of time if I add the following to my
bash profile.

First, it's nice to see if the directory I'm in is a git repository. If it is,
I like to know what branch I'm on. Now, I'm sure there are better ways to go 
about this, but this works alright for me.

    function parse_git_branch_and_add_brackets {
      echo -e "$(git branch --no-color 2> /dev/null | sed -e '/^[^*]/d' -e "s/* \(.*\)/\(\1\: $(parse_git_dirty)\)/")"
    }


    GIT_PROMPT_CLEAN=$'✓'
    GIT_PROMPT_DIRTY=$'δ'

    parse_git_dirty() {
      local SUBMODULE_SYNTAX=''
      local GIT_STATUS=''
      local CLEAN_MESSAGE='nothing to commit (working directory clean)'
      if [[ "$(git config --get oh-my-zsh.hide-status)" != "1" ]]; then
        if [[ $POST_1_7_2_GIT -gt 0 ]]; then
              SUBMODULE_SYNTAX="--ignore-submodules=dirty"
        fi
        if [[ "$DISABLE_UNTRACKED_FILES_DIRTY" != "true" ]]; then
            GIT_STATUS=$(git status -s ${SUBMODULE_SYNTAX} 2> /dev/null | tail -n1)
        else
            GIT_STATUS=$(git status -s ${SUBMODULE_SYNTAX} -uno 2> /dev/null | tail -n1)
        fi
        if [[ -n $(git status -s ${SUBMODULE_SYNTAX} -uno  2> /dev/null) ]]; then
          echo -e "$GIT_PROMPT_DIRTY"
        else
          echo -e "$GIT_PROMPT_CLEAN"
        fi
      else
        echo -e "$GIT_PROMPT_CLEAN"
      fi
    }


Then, somewhere along the line, you'll want to add 
`$(parse_git_branch_and_add_brackets)` to your PS1 variable.

Second, I find I like to have my Python environments initialized automatically.
I don't have any idea what you clowns call your environment folder, I call mine
`env`. Season to your wacky taste. I set `$h_c` and `$v_c` to something
beautiful.

    _virtualenv_auto_activate() {
        if [ -e "env" ]; then
            # Check to see if already activated to avoid redundant activating
            if [ "$VIRTUAL_ENV" != "$(pwd -P)/env" ]; then
                _VENV_NAME="$(basename `pwd`)"
                echo Activating virtualenv \"$_VENV_NAME\"...
                VIRTUAL_ENV_DISABLE_PROMPT=1
                source env/bin/activate
                _OLD_VIRTUAL_PS1="$PS1"
                PS1="$h_c [ $v_c$_VENV_NAME$h_c ]$PS1"
                export PS1
            fi
         else
             if [ "$VIRTUAL_ENV" != "" ]; then
                 echo deactivating VirtualEnv
                 deactivate
             fi
        fi
    }

Finally, add;

    export PROMPT_COMMAND=_virtualenv_auto_activate

somewhere and hope nothing breaks.

## Getting Started

1. clone this repository
2. update your `setup.sh` script's PROJECT variable to...
3. run `setup.sh`
4. change your git remote to something else, dammit.

## Next Steps

To really utilize this little wingdinger to it's fullest potential, I find
it's ideal to have a bash function in your .bashrc that reads something like...

    function django() {
        _FILE="/tmp/django-toolbelt-master.zip"
        _DIR="/tmp/django-toolbelt-master"

        pushd /tmp
        rm $_FILE;
        rm -r $_DIR;
        curl -L https://github.com/pnovotnak/django-toolbelt/archive/master.zip \
            > $_FILE;
        unzip $_FILE;
        popd

        mv $_DIR "$(pwd)/$1";
        cd $1

        $EDITOR ./setup.sh
        ./setup.sh
    }

Then, by typing `django <project folder>` you get a whole Django project set up
for you in short order.

