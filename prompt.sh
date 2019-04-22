find_git_branch() {
  # Based on: http://stackoverflow.com/a/13003854/170413
  local branch
  if branch=$(git rev-parse --abbrev-ref HEAD 2> /dev/null); then
    local color=$txtwht
    if [[ "$branch" == "HEAD" ]]
    then
      color=$bldred
      branch='detached*'
    elif [[ "$branch" == *"feature"* ]]
    then
      color=$txtcyn
    elif [[ "$branch" == "master" ]]
    then
      color=$txtpur
    elif [[ "$branch" == "develop" ]]
    then
      color=$txtwht
    elif [[ "$branch" == *"bugfix"* ]]
    then
      color=$txtred
    elif [[ "$branch" == *"release"* ]]
    then
      color=$txtylw
    elif [[ "$branch" == *"hotfix"* ]]
    then
      color=$txtylw
    fi

    git_branch="$color$branch"
  else
    git_branch=""
  fi
}

find_git_dirty() {
  local status=$(git status --porcelain 2> /dev/null)
  if [[ "$status" != "" ]]; then
    git_dirty="🔥"
  else
    git_dirty=''
  fi
}

find_git_ahead_behind() {

  local local_branch=$(git rev-parse --abbrev-ref HEAD 2> /dev/null)

  if [[ -n "$local_branch" ]]; then
    local upstream_branch=$(git rev-parse --abbrev-ref "@{upstream}" 2> /dev/null)
    # If the branch is not tracking a specific remote branch, then assume we are tracking origin/[this_branch_name]
    [[ -z "$upstream_branch" ]] && upstream_branch="origin/$local_branch"
    if [[ -n "$upstream_branch" ]]; then
      local  ahead=$(git rev-list --left-right ${local_branch}...${upstream_branch} 2> /dev/null | grep -c '^<')
      local behind=$(git rev-list --left-right ${local_branch}...${upstream_branch} 2> /dev/null | grep -c '^>')
      if [[ "$ahead" = 0 ]] && [[ "$behind" = 0 ]]; then
        git_ahead_behind=''
      else
        git_ahead_behind=""
        [[ "$ahead"  != 0 ]] && git_ahead_behind="$git_ahead_behind$bldgrn$ahead"
        [[ "$behind" != 0 ]] && git_ahead_behind="$git_ahead_behind$bldred$behind"
      fi
    fi
  else
    git_ahead_behind=''
  fi
}

PROMPT_COMMAND="find_git_branch; find_git_dirty; find_git_ahead_behind; $PROMPT_COMMAND"

# Default Git enabled prompt with dirty state
# export PS1="\u@\h \w \[$txtcyn\]\$git_branch\[$txtred\]\$git_dirty\[$txtrst\]\$ "

# Another variant:
# export PS1="\[$bldgrn\]\u@\h\[$txtrst\] \w \[$bldylw\]\$git_branch\[$txtcyn\]\$git_dirty\[$txtrst\]\$ "

# Default Git enabled root prompt (for use with "sudo -s")
# export SUDO_PS1="\[$bakred\]\u@\h\[$txtrst\] \w\$ "
