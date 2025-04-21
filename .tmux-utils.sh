#!/bin/bash

function rename_tmux_session_to_basename() {
    if [ -n "$TMUX" ]; then
        local session_name
        session_name=$(basename "$PWD")

        # Check if a session with this name already exists
        if tmux list-sessions | grep -q "^$session_name:"; then
            local counter=1
            while tmux list-sessions | grep -q "^${session_name}_$counter:"; do
                ((counter++))
            done
            session_name="${session_name}_$counter"
        fi

        tmux rename-session "$session_name"
    else
        echo "Not in a tmux session."
    fi
}

