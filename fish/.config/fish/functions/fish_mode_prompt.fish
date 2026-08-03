function fish_mode_prompt
    # Mode indicator is rendered by the custom fish_prompt (gated on helix
    # bindings). Suppress fish's automatic one to avoid a duplicated indicator.
    return 0
end
