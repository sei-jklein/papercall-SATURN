#!/bin/bash

realpath_osx() {
    path=`eval echo "$1"`
    folder=$(dirname "$path")
    echo $(cd "$folder"; pwd)/$(basename "$path");
}

print_help() {
    printf "Commands are:\n"
    printf "build : Build the Docker container.\n"
    printf "do <papercall action> : run the action in the Docker container\n"
    printf "help : prints this information.\n"
}

build_container() {
    docker build -t saturn_papercall .
}

do_action() {
    case $1 in
        "get")
            ruby_script="get_for_assignment.rb"
        ;;
        "status")
            ruby_script="review_status.rb"
        ;;
        "program")
            ruby_script="accepted_program.rb"
        ;;
        "addresses")
            ruby_script="get_submitter_emails.rb"
        ;;
        "analysis")
            ruby_script="feedback_analysis.rb"
        ;;
        "notifications")
            ruby_script="decision_notification.rb"
        ;;
        "abstracts")
            ruby_script="elevator_pitch.rb"
        ;;
        *)
            printf "Unknown PaperCall action\n"
            exit 2
        ;;
    esac
    docker run -v "$(pwd)":/app saturn_papercall /bin/bash -c "cd /app; ruby -E 'UTF-8' ./src/$ruby_script"
}

base_path=$(dirname $(realpath_osx $0))
cd ${base_path}

if [ $# -lt 1 ]; then
    printf "This script requires a command.\n"
    print_help
    exit 2
fi

case $1 in
    "build")
        printf "Building Docker container.\n"
        build_container
        exit
    ;;
    "do")
        shift || true
        if [[ -n $1 ]]; then
            action="$1"
            printf "Doing PaperCall $action \n"
            do_action $action
        else
            printf "You must include an action name.\n"
            exit 2
        fi
    ;;
    "help")
        print_help
    ;;
    *)
        printf "You have entered an invalid action\n"
        print_help
        exit 2
    ;;
esac
