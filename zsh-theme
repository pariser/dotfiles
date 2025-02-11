ZSH_THEME_GIT_PROMPT_PREFIX="%{$fg_bold[blue]%}git:(%{$fg[red]%}"
ZSH_THEME_GIT_PROMPT_SUFFIX="%{$reset_color%} "
ZSH_THEME_GIT_PROMPT_DIRTY="%{$fg[blue]%}) %{$fg[yellow]%}✗"
ZSH_THEME_GIT_PROMPT_CLEAN="%{$fg[blue]%})"

git_prompt_in_large_repositories() {
  if [ "$(git rev-parse --is-inside-work-tree 2>/dev/null)" = "true" ]; then
    # this is faster than `_omz_git_prompt_info`
    GIT_BRANCH=$(git rev-parse --abbrev-ref HEAD)
    echo "%{$ZSH_THEME_GIT_PROMPT_PREFIX%}%{${GIT_BRANCH}%}%{$ZSH_THEME_GIT_PROMPT_CLEAN%}%{$ZSH_THEME_GIT_PROMPT_SUFFIX%}"
  else
    echo ""
  fi
}

rbenv_shell() {
  if (( ${+RBENV_VERSION} )); then
    echo "%B%{$fg[yellow]%}rbenv@$RBENV_VERSION%{$reset_color%}%b "
  else
    echo ""
  fi
}

PROMPT='$(rbenv_shell)[%D{%F %r}] %(?:%{$fg_bold[green]%}➜:%{$fg_bold[red]%}➜)'
PROMPT+=' %{$fg[cyan]%}%~%{$reset_color%} $(git_prompt_in_large_repositories)'

