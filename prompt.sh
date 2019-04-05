LAST_GIT_PATH=""

find_git_branch() {
  local branch
  local CURRENT_PATH

  CURRENT_PATH="$(pwd)"

  if branch=$(git rev-parse --abbrev-ref HEAD 2> /dev/null); then

    if [ "$CURRENT_PATH" != "$LAST_GIT_PATH" ]; then
      (git remote update >/dev/null 2>&1 &)
    fi
    LAST_GIT_PATH="$CURRENT_PATH"

    if [[ "$branch" == "HEAD" ]]; then
      branch='detached*'
    fi
    git_branch=" ($branch):"
  else
    git_branch=""
  fi
}

find_git_dirty() {
  local status
  status="$(git status 2> /dev/null)"


  git_dirty=""

  if [[ "$status" == "" ]]; then
    git_status=""
    return

  else

    if [[ "$status" =~ "Untracked files" ]]; then
      git_dirty+="❗️"
    elif [[ "$status" =~ "Changes not staged for commit" ]]; then
      git_dirty+="🔺"
    fi

    if [[ "$status" =~ "Your branch is ahead of" ]]; then
      local num_a="$(git log --oneline @{u}.. 2> /dev/null | wc -l | tr -d ' ')"
      git_dirty+="⏫+${num_a}"
    fi

    if [[ "$status" =~ "Your branch is behind" ]]; then
      local num_b="$(git log --oneline ..@{u} 2> /dev/null | wc -l | tr -d ' ')"
      git_dirty+="⏬-${num_b}"
    fi

    if [[ $"$status" =~ "Changes to be committed" ]]; then
      git_dirty+="✳️ "
    fi

    if [[ $"$status" =~ "have diverged" ]]; then
      git_dirty+="🔀"
    fi

    local GIT_DIR="$(git rev-parse --git-dir 2> /dev/null)"

    if [ -n $GIT_DIR ] && test -r $GIT_DIR/MERGE_HEAD; then
      git_dirty+="🔄"
    fi

    if [[ "$status" =~ "Your branch is up to date with" ]] || \
       [[ "$status" =~ "Your branch is up-to-date with" ]] || \
       [[ "$status" =~ "nothing to commit" ]]; then
      if [ "$git_dirty" == "" ]; then
        git_dirty+="✅"
      fi
    fi

    local git_dirty_pfx="${txtwht}[${txtrst}"
    local git_dirty_sfx="${txtwht}]${txtrst}"
    git_status="${git_dirty_pfx}${git_dirty}${git_dirty_sfx}"

  fi
}

PROMPT_COMMAND="find_git_branch; find_git_dirty; $PROMPT_COMMAND"
