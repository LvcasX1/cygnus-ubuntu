#!/bin/bash
# App launcher - uses rofi drun with require-input for empty start

THEME="$HOME/.config/rofi/cygnus-ubuntu-apps.rasi"

rofi -show drun -theme "$THEME"
