# If you come from bash you might have to change your $PATH.
# export PATH=$HOME/bin:/usr/local/bin:$PATH

# Set name of the theme to load --- if set to "random", it will
# load a random theme each time oh-my-zsh is loaded, in which case,
# to know which specific one was loaded, run: echo $RANDOM_THEME
# See https://github.com/ohmyzsh/ohmyzsh/wiki/Themes
ZSH_THEME="bira"

# Set list of themes to pick from when loading at random
# Setting this variable when ZSH_THEME=random will cause zsh to load
# a theme from this variable instead of looking in $ZSH/themes/
# If set to an empty array, this variable will have no effect.
# ZSH_THEME_RANDOM_CANDIDATES=( "robbyrussell" "agnoster" )

# Uncomment the following line to use case-sensitive completion.
# CASE_SENSITIVE="true"

# Uncomment the following line to use hyphen-insensitive completion.
# Case-sensitive completion must be off. _ and - will be interchangeable.
# HYPHEN_INSENSITIVE="true"

# Uncomment one of the following lines to change the auto-update behavior
# zstyle ':omz:update' mode disabled  # disable automatic updates
# zstyle ':omz:update' mode reminder  # just remind me to update when it's time
# zstyle ':omz:update' mode auto      # update automatically without asking

# Uncomment the following line to change how often to auto-update (in days).
# zstyle ':omz:update' frequency 13

# Uncomment the following line if pasting URLs and other text is messed up.
# DISABLE_MAGIC_FUNCTIONS="true"

# Uncomment the following line to disable colors in ls.
# DISABLE_LS_COLORS="true"

# Uncomment the following line to disable auto-setting terminal title.
# DISABLE_AUTO_TITLE="true"

# Uncomment the following line to enable command auto-correction.
# ENABLE_CORRECTION="true"

# Uncomment the following line to display red dots whilst waiting for completion.
# You can also set it to another string to have that shown instead of the default red dots.
# e.g. COMPLETION_WAITING_DOTS="%F{yellow}waiting...%f"
# Caution: this setting can cause issues with multiline prompts in zsh < 5.7.1 (see #5765)
# COMPLETION_WAITING_DOTS="true"

# Uncomment the following line if you want to disable marking untracked files
# under VCS as dirty. This makes repository status check for large repositories
# much, much faster.
# DISABLE_UNTRACKED_FILES_DIRTY="true"

# Uncomment the following line if you want to change the command execution time
# stamp shown in the history command output.
# You can set one of the optional three formats:
# "mm/dd/yyyy"|"dd.mm.yyyy"|"yyyy-mm-dd"
# or set a custom format using the strftime function format specifications,
# see 'man strftime' for details.
# HIST_STAMPS="mm/dd/yyyy"

# Would you like to use another custom folder than $ZSH/custom?
# ZSH_CUSTOM=/path/to/new-custom-folder

# Which plugins would you like to load?
# Standard plugins can be found in $ZSH/plugins/
# Custom plugins may be added to $ZSH_CUSTOM/plugins/
# Example format: plugins=(rails git textmate ruby lighthouse)
# Add wisely, as too many plugins slow down shell startup.
plugins=(
    git
    zsh-autosuggestions
    ssh-agent
    zsh-syntax-highlighting
)

export ZSH="$HOME/.oh-my-zsh"
source "$ZSH/oh-my-zsh.sh"

# User configuration

# export MANPATH="/usr/local/man:$MANPATH"

# You may need to manually set your language environment
# export LANG=en_US.UTF-8

# Preferred editor for local and remote sessions
# if [[ -n $SSH_CONNECTION ]]; then
#   export EDITOR='vim'
# else
#   export EDITOR='mvim'
# fi

# Compilation flags
# export ARCHFLAGS="-arch x86_64"

# Set personal aliases, overriding those provided by oh-my-zsh libs,
# plugins, and themes. Aliases can be placed here, though oh-my-zsh
# users are encouraged to define aliases within the ZSH_CUSTOM folder.
# For a full list of active aliases, run `alias`.
#
# Example aliases
# alias zshconfig="mate ~/.zshrc"
# alias ohmyzsh="mate ~/.oh-my-zsh"

# Functions
function activate-venv { # activate the virtualenv in the current directory if exists
    venv=$(find . -maxdepth 1 -type d -name '*venv*')

    if [[ -n "$venv" ]]; then
        . "$venv/bin/activate"
        return 1
    else
        echo "No venv found!"
        return 0
    fi
}

function calculate-percentual-increase { # calculate percentual increase between two values
    initial_value=$1
    actual_value=$2

    percent_increase=$(echo "scale=2; ((${actual_value} - ${initial_value}) / ${initial_value}) * 100" | bc)

    echo "$percent_increase%"
}

function check-conflicts-with-branch { # check for conflicts between actual branch with other branch (default: main)
    branch_name=${1:-main}
    actual_branch="$(command git rev-parse --abbrev-ref HEAD)"

    command git pull origin "$branch_name" --no-rebase --no-commit
    command git commit -m ":handshake: Merge branch '$branch_name' into '$actual_branch'"
}

function checkout { # checkout to specified branch
    command git checkout "$@"
}

function confirm { # prompts for user confirmation [y/n]
    local prompt="$1"
    local response

    # Print the prompt and options
    echo -n "$prompt [y/n]: "

    # Read the user's response
    read -r response

    case $response in
        [Yy]) return 0 ;;
        [Nn]) return 1 ;;
        *) return 2 ;;
    esac
}

function copy-file { # copy content of a file to clipboard
    if ! command -v xclip >/dev/null 2>&1; then
        echo "Installing 'xclip'"
        sudo apt-get install xclip -y > /dev/null
    fi

    xclip -selection clipboard -i "$1"
}

function clear-swap { # clear swap if has available RAM
    free_data="$(free)"
    mem_data="$(echo "$free_data" | grep 'Mem:')"
    free_mem="$(echo "$mem_data" | awk '{print $4}')"
    buffers="$(echo "$mem_data" | awk '{print $6}')"
    cache="$(echo "$mem_data" | awk '{print $7}')"
    total_free=$((free_mem + buffers + cache))
    used_swap="$(echo "$free_data" | grep 'Swap:' | awk '{print $3}')"
    
    echo -e "Free memory:\t$total_free kB ($((total_free / 1024)) MB)\nUsed swap:\t$used_swap kB ($((used_swap / 1024)) MB)"
    if [[ $used_swap -eq 0 ]]; then
        echo "Congratulations! No swap is in use."
    elif [[ $used_swap -lt $total_free ]]; then
        echo "Freeing swap..."
        sudo swapoff -a
        sudo swapon -a
    else
        echo "Not enough free memory. Exiting."
        exit 1
    fi
}

function help-create-venv { #@dont-show
    echo ""
    echo "Create an virtualenv in current directory"
    echo ""
    echo "Usage:"
    echo "  create-venv [--options]"
    echo ""
    echo "Options:"
    echo "  --venv-name             Name of the virtualenv"
    echo "  --python-version        Python version to use in virtualenv"
    echo "  --pip                   Pip version to use in virtualenv"
    echo ""
    echo "Note:"
    echo "  All options available in 'virtualenv' are also available here"
    echo ""
}

function create-venv { # create an virtualenv in current directory
    has_venv_in_current_folder=$(find . -maxdepth 1 -type d -name '*venv*')

    if [[ -n "$has_venv_in_current_folder" ]]; then
        echo "Already venv in current folder!"
        return 0
    fi

    current_folder_name="${PWD##*/}"
    default_python_version=$(default-python-version)
    pip="23.0.1"

    venv_name="${current_folder_name}"
    python_version="${default_python_version}"
    virtualenv_args=()

    while [[ $# -gt 0 ]]; do
        case "$1" in
            -n|--venv-name)
                venv_name="$2"
                shift 2
                ;;
            -v|--python-version)
                python_version="$2"
                shift 2
                ;;
            -p|--pip)
                pip="$2"
                shift 2
                ;;
            -h|--help)
                help-create-venv
                return 0
                ;;
            *)
                virtualenv_args+=("$1")
                shift
                ;;
        esac
    done

    venv_name=$(echo "$venv_name" | tr - _)
    python_version=$(echo "$python_version" | awk -F'.' '{print $1"."$2}')

    if [[ "$venv_name" != "$current_folder_name" ]]; then
        venv_full_name="${venv_name}_py${python_version}"
    else
        venv_full_name="venv_${venv_name}_py${python_version}"
    fi

    virtualenv "$venv_full_name" --python="$python_version" --pip="$pip" "${virtualenv_args[@]}"
}

function confirm { # prompts for user confirmation [y/n] #@dont-show
    local prompt="$1"
    local response

    # Print the prompt and options
    echo -n "$prompt [y/n]: "

    # Read the user's response
    read -r response

    case $response in
        [Yy]) return 0 ;;
        [Nn]) return 1 ;;
        *) return 2 ;;
    esac
}

function copy-file { # copy content of a file to clipboard
    if ! command -v xclip >/dev/null 2>&1; then
        echo "Installing 'xclip'"
        sudo apt-get install xclip -y > /dev/null
    fi

    xclip -selection clipboard -i "$1"
}

function create-lambda-layer { # create AWS lambda layer from current directory
    venv=$(find . -maxdepth 1 -type d -name '*venv*')
    requirements=$(find . -maxdepth 1 -type f -name 'requirements.txt')
    layer_name=${1-"my-layer"}
    python_runtime=${2-"python3.10"}
    python_runtime=$(echo "$python_runtime" | grep -oP "\d+\.\d+(?:\.\d+)?")
    site_packages="python/lib/python${python_runtime}/site-packages"

    if [ -z "$venv" ]; then
        echo "ERROR: Could not find an virtualenv"
        return 1
    fi

    if [ -z "$requirements" ]; then
        echo "ERROR: Could not find 'requirements.txt' file"
        return 1
    fi

    eval mkdir -p "$site_packages"

    echo "* Activating virtualenv"
    if activate-venv; then
        sleep 2
    else
        return 1
    fi

    echo "* Installing dependencies"
    if command pip install -q -r "$requirements" --upgrade --disable-pip-version-check --target "$site_packages"; then
        sleep 2
    else
        return 1
    fi

    echo "* Creating layer '$layer_name.zip'"
    if eval zip -r -x "$requirements" "$venv/\*" -q "$layer_name.zip" .; then
        :
    else
        return 1
    fi

    echo "* Cleaning temps"
    if rm -rf "python"; then
        sleep 2
    else
        return 1
    fi

    echo "* Deactivating virtualenv"
    if deactivate-venv; then
        sleep 2
        echo "Done!"
    else
        return 1
    fi
}

function create-lambda-zip { # create AWS lambda zip from current directory
    original_dir=$PWD

    venv=$(find . -maxdepth 1 -type d -name '*venv*')
    runner=$(find . -maxdepth 1 -type f -name 'runner.py')

    if [ -z "$runner" ]; then
        echo "ERROR: Could not find runner.py"
        return 1
    fi

    if [ -z "$venv" ]; then
        echo "ERROR: Could not find an virtualenv"
        return 1
    fi

    package_name=${1-"my-lambda-package"}
    site_packages="${venv}/lib/python3*/site-packages"

    echo "* Creating '$package_name.zip'"
    eval cd "$site_packages"
    eval zip -r -q "../../../../$package_name.zip" .

    cd "$original_dir" || return 1

    echo "* Adding '$runner' to $package_name.zip"
    if eval zip -g -q "$package_name".zip "$runner"; then
        echo "Done!"
    else
        return 1
    fi
}

function create-venv { # create an virtualenv in current directory
    has_venv_in_current_folder=$(find . -maxdepth 1 -type d -name '*venv*')
    current_folder_name="${PWD##*/}"
    default_python_version=$(default-python-version)

    venv_name="${current_folder_name}"
    python_version="${default_python_version}"
    virtualenv_args=()

    while [[ $# -gt 0 ]]; do
        case "$1" in
            -n|--venv-name)
                venv_name="$2"
                shift 2
                ;;
            -v|--python-version)
                python_version="$2"
                shift 2
                ;;
            -h|--help)
                help-create-venv
                return 0
                ;;
            *)
                virtualenv_args+=("$1")
                shift
                ;;
        esac
    done

    venv_name=$(echo "$venv_name" | tr - _)
    python_version=$(echo "$python_version" | grep -oP "\d.*")
    venv_full_name="venv_${venv_name}_py${python_version}"

    if [[ -n "$has_venv_in_current_folder" ]]; then
        echo "Already venv in current folder!"
        return 0
    else
        virtualenv "$venv_full_name" --python="$python_version" "${virtualenv_args[@]}"
    fi
}

function deactivate-venv { # deactivate the virtualenv in the current directory if exists
    venv=$(find . -maxdepth 1 -type d -name '*venv*')

    if [[ -z "$VIRTUAL_ENV" ]]; then
        echo "Venv already deactivated!"
        return 1

    elif [[ -n "$VIRTUAL_ENV" ]]; then
        deactivate
        return 1

    elif ! deactivate >/dev/null 2>&1; then
        echo "Not inside venv."
        return 0

    elif [[ -z "$venv" ]]; then
        echo "No venv found!"
        return 0

    fi
}

function default-python-version { # list the default python3 version
    python3 --version | grep -oP "\d+\.\d+(?:\.\d+)?"
}

function def { # output the function definition
    function_name="$1"
    file="$HOME/.zshrc"

    function_def=$(sed -n "/function $function_name /,/^[[:space:]]*}/p" "$file")

    if [[ -z "${function_def}" ]]; then
        echo "ERROR: Function '${function_name}' not found"
        return 1
    fi

    echo -e
    echo -e "${function_def}" | pygmentize -l sh -P style=dracula_refined
    echo -e
}

function default-python-version { # list the default python3 version
    python3 --version | grep -oP "\d+\.\d+(?:\.\d+)?"
}

function delete-branches { # delete local branches except for 'main', 'master', 'beta' AND any specified branches
    current_branch="$(command git rev-parse --abbrev-ref HEAD)"
    protected_branches=("master" "main" "beta")
    branches_to_keep=("$@")

    all_branches_to_keep=("${current_branch[@]}" "${protected_branches[@]}" "${branches_to_keep[@]}")

    # Loop through all local branches
    for branch in $(git branch | sed 's/*//'); do
        if [[ ! "${all_branches_to_keep[@]}" =~ "${branch}" ]]; then
            git branch -d "$branch"
        fi
    done
}

function gdrive { # mount google drive using rclone
    # TODO: implement 'mount all' and 'unmount all'

    if [[ "$1" == mount ]]; then
        gdrive-mount "$2"

    elif [[ "$1" == unmount ]]; then
        gdrive-unmount "$2"
    fi
}

function gdrive-mount { #@dont-show
    gdrive_name="gdrive-$1"

    # Always unmount before mount
    fusermount -uzq "$HOME/$gdrive_name"

    # Create folder to mount in
    mkdir -p "$HOME/$gdrive_name"

    # Mount driver
    (&>/dev/null nohup rclone mount "$gdrive_name:" "$HOME/$gdrive_name" &)
    echo "Mounted '$gdrive_name'"
    return 0
}

function gdrive-unmount { #@dont-show
    gdrive_name="gdrive-$1"

    if ! command fusermount -uzq "$HOME/$gdrive_name"; then
        echo "Already unmounted '$gdrive_name'"
        return 0
    else
        echo "Unmounted '$gdrive_name'"
        return 1
    fi
}

function generate-date-range { # generate date range based on start and end date (date format: "YYYY-MM-DD")
    start_date="$1"
    end_date="$2"

    while ! [[ $start_date > $end_date ]]; do
        echo "$start_date"
        start_date=$(date -d "$start_date + 1 day" +"%F")
    done
}

function get-aws-token { # get AWS MFA temp token
    # Install 'jq' for parse .json files
    if ! command -v jq >/dev/null 2>&1; then
        echo "Installing 'jq'..."
        sudo apt-get install jq
    fi

    # Identify and export location of shell configuration file
    if [ -z "$SHELL_CONFIG_FILE" ]; then
        if [[ "$SHELL" == "/bin/bash" || "$SHELL" == "/usr/bin/bash" ]]; then
            SHELL_CONFIG_FILE="$HOME/.bashrc"
        elif [[ "$SHELL" == "/bin/zsh" || "$SHELL" == "/usr/bin/zsh" ]]; then
            SHELL_CONFIG_FILE="$HOME/.zshrc"
        fi

        echo "export SHELL_CONFIG_FILE=\"$SHELL_CONFIG_FILE\"" >> "$SHELL_CONFIG_FILE"

    fi

    # Request for the AWS ARN if environment variable AWS_ARN is empty
    if [ -z "$AWS_ARN" ]; then
        echo "Insert your AWS ARN (example: arn:aws:iam::123:mfa/personal_device): "
        read -r aws_arn

        echo "export AWS_ARN=\"$aws_arn\"" >> "$SHELL_CONFIG_FILE"
    else
        aws_arn="$AWS_ARN"
    fi

    # Request the authentication token
    echo -n "Insert the authenticator token: "
    read -r auth_token

    aws sts get-session-token \
        --duration-seconds 129600 \
        --serial-number "$aws_arn" \
        --token-code "$auth_token" \
        > "$HOME/.aws/tmp_mfa_credentials.json"

    # Set the new (and temporary) aws credentials
    new_aws_access_key_id=$(jq -r '.Credentials.AccessKeyId' "$HOME/.aws/tmp_mfa_credentials.json")
    new_aws_secret_access_key=$(jq -r '.Credentials.SecretAccessKey' "$HOME/.aws/tmp_mfa_credentials.json")
    new_aws_session_token=$(jq -r '.Credentials.SessionToken' "$HOME/.aws/tmp_mfa_credentials.json")

    aws configure set aws_access_key_id "$new_aws_access_key_id" --profile "mfa"
    aws configure set aws_secret_access_key "$new_aws_secret_access_key" --profile "mfa"
    aws configure set aws_session_token "$new_aws_session_token" --profile "mfa"

    exec "$SHELL"
}

function git { # override default git command by changing default 'git commit' for 'cz commit'
    blocked_branches=("main" "master")

    if command git rev-parse --is-inside-work-tree > /dev/null 2>&1; then
        actual_branch="$(command git branch --show-current)"
    fi

    if [[ $actual_branch == "" ]]; then
        is_inside_a_blocked_branch=false
    elif [[ ${blocked_branches[*]} =~ $actual_branch ]]; then
        is_inside_a_blocked_branch=true
    else
        is_inside_a_blocked_branch=false
    fi

    if [[ "$1" == "commit" ]]; then
        if [[ "$is_inside_a_blocked_branch" == true ]]; then
            echo "You cannot commit into '$actual_branch'."
            return 1
        fi

        if [[ -z "$2" ]]; then
            command cz commit
        else
            command git "$@"
    fi

    elif [[ "$1" == "add" ]]; then
        command git add --intent-to-add "${@:2}"
        command git add --patch "${@:2}"

    elif [[ "$1" == "status" ]]; then
        command git status

        if [ "$(command git --no-pager stash list | wc -w)" -gt 0 ]; then
            echo
            command git --no-pager stash list
        fi

    elif [[ "$1" == "push" ]]; then
        if [[ "$is_inside_a_blocked_branch" == true ]]; then
            echo "Branch '$actual_branch' does not allow direct pushes."
            echo "You need to create a feature branch and submit a pull request."
            return 1
        else
            command git "$@"
        fi

    else
        command git "$@"
    fi
}

function help-create-venv { #@dont-show
    echo ""
    echo "Create an virtualenv in current directory"
    echo ""
    echo "Usage:"
    echo "  create-venv [--options]"
    echo ""
    echo "Options:"
    echo "  --venv-name             Name of the virtualenv"
    echo "  --python-version        Python version to use in virtualenv"
    echo ""
    echo "Note:"
    echo "  All options available in 'virtualenv' are also available here"
    echo ""
}

function install-dependencies { # install dependencies used by other functions @dont-show
    echo "Installing 'wslu'"
    sudo apt-get install wslu -y > /dev/null

    echo "Installing 'xclip'"
    sudo apt-get install xclip -y > /dev/null

    echo "Installing 'software-properties-common'"
    sudo apt-get install software-properties-common -y > /dev/null
}

function install-docker-with-compose { # install docker and docker-compose
    # Docker
    sudo apt-get install apt-transport-https ca-certificates curl software-properties-common -y
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
    sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
    sudo apt-get install docker-ce -y

    # Docker-compose
    mkdir -p ~/.docker/cli-plugins/
    curl -SL https://github.com/docker/compose/releases/download/v2.17.3/docker-compose-linux-x86_64 -o ~/.docker/cli-plugins/docker-compose
    chmod +x ~/.docker/cli-plugins/docker-compose

    # Permission error
    sudo chmod 666 /var/run/docker.sock
}

function install-or-update-git { # install or update git to last version
    sudo add-apt-repository ppa:git-core/ppa -y
    update
    sudo apt-get install git -y
}

function install-python-version { # install specified python version
    install-dependencies

    sudo add-apt-repository ppa:deadsnakes/ppa -y
    sudo apt-get update -y

    python_version="python$1"
    sudo apt-get install "$python_version" -y
    sudo apt-get install "$python_version-distutils" -y
}

function is-linux-native { # checks if system is linux native or not (like WSL)
    if grep -qi microsoft /proc/version; then
        echo false
    else
        echo true
    fi
}

function list-aliases { # list users aliases inside ~/.zshrc
    COLOR_OFF="\033[0m"
    DRACULA_PINK="\e[38;2;255;121;198m\e[1m" # \033[1;31m
    DRACULA_GRAY="\033[2;38m"

    file="$HOME/.zshrc"
    grep_term="$1"

    aliases_details=()
    sorted_aliases_details=()

    while IFS= read -r line; do
        aliases_details+=("$line")
    done < <(grep -E "^alias\s.*=" "$file")

    IFS=$'\n' sorted_aliases_details=($(sort <<<"${aliases_details[*]}"))

    for item in "${sorted_aliases_details[@]}"; do
        alias_name=$(echo "$item" | awk -F "#" '{print $1}' | grep -oP "alias\s+\K[^[:space:]]+" | awk -F "=" '{print $1}')
        alias_description=$(echo "$item" | awk -F "#" '{print $2}' | sed 's/^ *//g')

        echo "${DRACULA_PINK}$alias_name ${COLOR_OFF}${DRACULA_GRAY}# $alias_description${COLOR_OFF}" | grep -w "$grep_term" | grep -v grep | grep -v "@dont-show"
    done
}

function list-functions { # list users function inside ~/.zshrc
    COLOR_OFF="\033[0m"
    DRACULA_PINK="\e[38;2;255;121;198m\e[1m" # \033[1;31m
    DRACULA_GRAY="\033[2;38m"

    file="$HOME/.zshrc"
    grep_term="$1"

    function_details=()
    sorted_function_details=()

    while IFS= read -r line; do
        function_details+=("$line")
    done < <(grep -E "^function\s.*{" "$file")

    IFS=$'\n' sorted_function_details=($(sort <<<"${function_details[*]}"))

    for item in "${sorted_function_details[@]}"; do
        function_name=$(echo "$item" | awk -F "#" '{print $1}' | grep -oP "function\s+\K[^[:space:]]+")
        function_description=$(echo "$item" | awk -F "#" '{print $2}' | sed 's/^ *//g')

        echo "${DRACULA_PINK}$function_name ${COLOR_OFF}${DRACULA_GRAY}# $function_description${COLOR_OFF}" | grep "$grep_term" | grep -v grep | grep -v "@dont-show"
    done
}

function list-installed-python-versions { # list installed python versions
    find /usr/bin/python* ! -type l
}

function make-gif { # create an .gif using 'ffmpeg' based on a video file
    if ! command -v ffmpeg >/dev/null 2>&1; then
        echo "ERROR: Could not find 'ffmpeg' installed"
        return 1
    fi

    if ! command -v gifsicle >/dev/null 2>&1; then
        echo "ERROR: Could not find 'gifsicle' installed"
        return 1
    fi

    input_file="$1"
    temp_output_file=${2-"${input_file%.*}.gif"}
    output_file="${temp_output_file%.*}.gif"

    ffmpeg -hide_banner -loglevel warning -i "$input_file" -r 10 -filter_complex "[0:v] split [a][b];[a] palettegen [p];[b][p] paletteuse" -f gif - | gifsicle -O3 --lossy=100 > "$output_file"
}

function months-of { # list how many days each month has
    local year=$1

    # Validate the input year
    if ! [[ "$year" =~ ^[0-9]{4}$ ]]; then
        echo "Please provide a valid year (e.g., 2023)."
        return 1
    fi

    # Determine if it's a leap year
    local leap_year=false
    if (( (year % 4 == 0 && year % 100 != 0) || (year % 400 == 0) )); then
        leap_year=true
    fi

    # Arrays for months and days
    months=("January" "February" "March" "April" "May" "June" "July" "August" "September" "October" "November" "December")
    days=(31 28 31 30 31 30 31 31 30 31 30 31)

    # Adjust February for leap year
    if $leap_year; then
        days[2]=29
    fi

    # Display the days in each month
    for i in $(seq 1 12); do
        echo "($i) ${months[$i]}: ${days[$i]} days"
    done
}

function open-repo { # open the current repository in web browser
    is_linux_native=$(is-linux-native)
    repo_remote_url=$(command git remote get-url origin)

    # In case of github repository
    repo_url=$(echo "$repo_remote_url" | sed 's,git@github.com:,github.com/,')

    repo_url=$(echo "$repo_url" | cut -d '@' -f2 | sed 's/\.git$//')
    repo_url='https://'$repo_url

    if [[ $is_linux_native == true ]]; then
        open "$repo_url" > /dev/null 2>&1
    else
        wslview "$repo_url"
    fi
}

function pandas-df { # generate a sample pandas dataframe
    if ! command -v xclip >/dev/null 2>&1; then
        echo "Installing 'xclip'"
        sudo apt-get install xclip -y > /dev/null
    fi

    echo '
import pandas

data = {
    "id": [1, 2, 3],
    "salary": [10000, 15000, 17000],
    "height": [1.75, 1.68, 1.80],
    "is_student": [True, False, True],
    "city": ["New York", "London", "Tokyo"],
    "birthday_date": pandas.to_datetime(["1998-01-01", "2000-10-07", "2005-03-15"]),
    "duration": pandas.to_timedelta(["1 days", "2 days", "3 days"]),
    "last_login": pandas.to_datetime(["2023-01-01 10:00:00", "2023-01-02 08:30:00", "2023-01-03 15:45:00"]),
    "category": pandas.Categorical(["Sports", "Music", "Technology"]),
}

df = pandas.DataFrame(data)' | xclip -selection clipboard
}

function quick-test { # quickly open a temp dir to test scripts
    TMP_DIR="/home/marcosmartins/tmp"

    mkdir -p "$TMP_DIR"
    touch "$TMP_DIR/main.py" && code --new-window "$TMP_DIR"
}

function reorder-imports { # reorder python imports in specified file
    ORIGINAL_PYTHONPATH=$PYTHONPATH

    folder_or_file_to_reorder_imports=${1-"."}

    find "$folder_or_file_to_reorder_imports" -type f -name '*.py' -not -path '*venv*' | while read -r file; do
        files+=("$file")
    done

    for file in "${files[@]}"; do
        # Temporary unset PYTHONPATH to prevent warning:
        # https://github.com/asottile/reorder-python-imports/blob/main/reorder_python_imports.py#L817
        PYTHONPATH=''

        reorder-python-imports "$file"
    done

    PYTHONPATH="$ORIGINAL_PYTHONPATH"
}

function take { # create and change to directory
    mkdir -p "$1"
    cd "$1" || return 1
}

function show-pull-requests-changes { # show pull requests changes locally
    origin_branch=${1}
    feature_branch=${2}
    commit_hash=$(command git log origin/"$origin_branch"..origin/"$feature_branch" --no-merges --pretty=format:"%H" | tail -1)

    command git reset "$commit_hash"^
}

function start-airflow { # start Airflow locally
    docker compose -f "$HOME/bitbucket-repositories/airflow-local/docker-compose.yaml" up --detach

    open http://localhost:8080/home > /dev/null 2>&1
}

function stop-airflow { # stop locally Airflow
    docker stop $(docker ps -f "name=^airflow*" -q)
}

function take { # create and change to directory
    mkdir -p "$1"
    cd "$1" || return 1
}


# Aliases
alias cp='cp -i' # 'cp' command with flag '-i' for safety copy files and folders
alias gs='git status' # shortcut for 'git status'
alias la='list-aliases' # shortcut for 'list-aliases' function
alias lf='list-functions' # shortcut for 'list-functions' function
alias list-fonts='fc-list : family | sort | uniq' # fc-list : family | sort | uniq
alias ls='ls -lahF --color=auto' # shortcut for 'ls -lahF --color=auto'
alias mv='mv -i' # 'mv' command with flag '-i' for safety move files and folders
alias repo='cd $HOME/git-repositories' # change to 'git-repositories' folder
alias rm='rm -i' # 'rm' command with flag '-i' for safety remove files and folders
alias update='sudo apt-get update -y & sudo apt-get upgrade -y' # update and upgrade system
alias zshrc='micro ~/.zshrc' # shortcut for 'micro ~/.zshrc'


# Exports
export PATH=$PATH:/usr/local/bin
export PATH=$PATH:$HOME/.local/bin
export PATH=$PATH:$HOME/bin
export PATH=$PATH:$HOME/.cargo/bin
export PATH=$PATH:/usr/local/go/bin
export OH_MY_ZSH="$HOME/.oh-my-zsh"
export MICRO_TRUECOLOR=1

export SPARK_HOME=/opt/spark
export PYSPARK_PYTHON=/usr/bin/python3.7
export PYSPARK_DRIVER_PYTHON=/usr/bin/python3.7
export HADOOP_HOME=/opt/hadoop
export JAVA_HOME=/usr/lib/jvm/java-8-openjdk-amd64
export PYTHONPATH=/opt/spark/python:/opt/spark/python/lib/py4j-0.10.9-src.zip
export PYTHONPATH=/opt/spark/python:/opt/spark/python/lib/py4j-0.10.9-src.zip:/opt/spark/python:/opt/spark/python/lib/py4j-0.10.9-src.zip
export PATH=$PATH:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/games:/usr/local/games:/snap/bin:/bin:/sbin:/opt/hadoop/bin:/opt/hadoop/sbin:/opt/hadoop/bin:/opt/hadoop/sbin:/home/marcosmartins/.local/bin
export PATH=$PATH:/home/marcosmartins/rio/target/release
export PATH=$PATH:$HOME/.pyenv/bin
export PATH=$PATH:$HOME/.pyenv/versions/3.6.15/bin
export PATH=$PATH:$HOME/.dotnet/tools
export PATH=$PATH:/usr/share/code
export PATH=$PATH:$HOME/.local/pipx/venvs/pygments/bin

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion
