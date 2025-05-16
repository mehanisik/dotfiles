# Turn off fish greeting
set -e  fish_greeting

# Abbreviations
abbr -a x 'exit'

# Directory Shortcuts
abbr -a de 'cd ~/Desktop'
abbr -a do 'cd ~/Documents'
abbr -a pic 'cd ~/Pictures'
abbr -a dw 'cd ~/Downloads'
abbr -a dr 'cd ~/repos'
abbr -a dt 'cd ~/.config'


# Docker abbreviations
abbr -a dc 'docker-compose'

# Git Abbreviations
abbr -a k 'kubectl'

# Git Abbreviations
abbr -a g 'git'
abbr -a ga 'git add'
abbr -a gc 'git commit -m'
abbr -a gco 'git checkout'
abbr -a gd 'git diff'
abbr -a gl 'git log'
abbr -a gs 'git status'
abbr -a gp 'git push'
abbr -a gpl 'git pull'

abbr -a tx 'tmuxinator'


function fish_prompt
    echo -n "mehanisik ~> "
end