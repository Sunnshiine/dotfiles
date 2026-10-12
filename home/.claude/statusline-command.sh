#!/bin/bash
# Claude Code status line — Starship-style: directory, git branch/status, model.
# Colors are dimmed variants since the status line renders in a dimmed context.

input=$(cat)

model=$(echo "$input" | jq -r '.model.display_name // empty')
cwd=$(echo "$input" | jq -r '.workspace.current_dir // .cwd // empty')

# Directory: show ~ for home, else basename-style path Starship typically shows
if [ -n "$cwd" ]; then
  dir="${cwd/#$HOME/\~}"
else
  dir="$(basename "$(pwd)")"
fi

# Git info: branch name + dirty marker, skipping optional locks for speed/safety.
git_segment=""
if git -C "$cwd" --no-optional-locks rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  branch=$(git -C "$cwd" --no-optional-locks symbolic-ref --short HEAD 2>/dev/null)
  if [ -z "$branch" ]; then
    branch=$(git -C "$cwd" --no-optional-locks rev-parse --short HEAD 2>/dev/null)
  fi
  if [ -n "$branch" ]; then
    if [ -n "$(git -C "$cwd" --no-optional-locks status --porcelain 2>/dev/null)" ]; then
      dirty=" \033[2;33m✗\033[0m"
    else
      dirty=""
    fi
    git_segment=" \033[2;90mon\033[0m \033[2;35m${branch}\033[0m${dirty}"
  fi
fi

# Session cost / rate-limit status: prefer $ cost, else 5h/7d subscription usage.
cost=$(echo "$input" | jq -r '.cost.total_cost_usd // empty')
five=$(echo "$input" | jq -r '.rate_limits.five_hour.used_percentage // empty')
week=$(echo "$input" | jq -r '.rate_limits.seven_day.used_percentage // empty')

status_str=""
if [ -n "$cost" ]; then
  status_str=$(printf '$%.2f' "$cost")
fi
if [ -n "$five" ]; then
  seg=$(printf '5h:%.0f%%' "$five")
  status_str="${status_str:+$status_str }${seg}"
fi
if [ -n "$week" ]; then
  seg=$(printf '7d:%.0f%%' "$week")
  status_str="${status_str:+$status_str }${seg}"
fi

# Context window usage %.
ctx_pct=$(echo "$input" | jq -r '.context_window.used_percentage // empty')
ctx_str=""
if [ -n "$ctx_pct" ]; then
  ctx_str=$(printf 'ctx:%.0f%%' "$ctx_pct")
fi

extra=""
combined="${status_str}"
if [ -n "$ctx_str" ]; then
  combined="${combined:+$combined }${ctx_str}"
fi
if [ -n "$combined" ]; then
  extra=" \033[2;90m|\033[0m \033[2;32m${combined}\033[0m"
fi

printf "\033[2;36m%s\033[0m%b \033[2;90m|\033[0m \033[2;34m%s\033[0m%b\n" "$dir" "$git_segment" "$model" "$extra"
